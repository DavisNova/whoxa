import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:whoxachat/Models/pinned_message_model.dart';

import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';

class PinMessageController extends GetxController {
  Rx<PinMessageModel?> pinMessageModel =
      Rx<PinMessageModel?>(PinMessageModel());
  RxBool isLoading = false.obs;
  RxBool isPinningMessage = false.obs;
  RxBool isRemovingPin = false.obs;
  RxBool isExpanded = false.obs;

  bool isMessagePinned(String messageId) {
    if (pinMessageModel.value?.pinnedMessages == null) return false;

    return pinMessageModel.value!.pinnedMessages!.any(
        (pinnedMessage) => pinnedMessage.messageId.toString() == messageId);
  }

  // Get the pin ID for a message (useful for unpinning)
  String? getPinIdForMessage(String messageId) {
    if (pinMessageModel.value?.pinnedMessages == null) return null;

    final pinnedMessage = pinMessageModel.value!.pinnedMessages!.firstWhere(
      (message) => message.messageId.toString() == messageId,
      orElse: () => PinnedMessage(),
    );

    return pinnedMessage.pinMessageId?.toString();
  }

  // Fetch pinned messages for a conversation
  Future<void> getPinnedMessages(String conversationId) async {
    try {
      debugPrint("conversationId: ${conversationId}");
      debugPrint(
        'Bearer ${Hive.box(userdata).get(authToken)}',
      );
      isLoading(true);
      final uri = Uri.parse('${ApiHelper.baseUrl}/pin-message-list');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Accept': 'application/json',
        },
        body: {
          'conversation_id': conversationId,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        log("pin list: ${data}");
        pinMessageModel.value = PinMessageModel.fromJson(data);
        debugPrint(
            "Pinned messages loaded: ${pinMessageModel.value?.pinnedMessages?.length}");
      } else {
        debugPrint("Failed to load pinned messages: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading pinned messages: $e");
    } finally {
      isLoading(false);
    }
  }

  // Add a message to pinned messages
  Future<bool> addPinMessage(
      String conversationId, String messageId, String duration) async {
    print('convoid: $conversationId');
    try {
      isPinningMessage(true);
      final uri = Uri.parse('${ApiHelper.baseUrl}/add-to-pin-message');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Accept': 'application/json',
        },
        body: {
          'conversation_id': conversationId,
          'message_id': messageId,
          'duration': duration,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          // Refresh pinned messages
          await getPinnedMessages(conversationId);
          showCustomToast(data['message'] ?? 'Message Added to Pin');
          return true;
        } else {
          showCustomToast(data['message'] ?? 'Failed to pin message');
          return false;
        }
      } else {
        showCustomToast('Failed to pin message');
        return false;
      }
    } catch (e) {
      debugPrint("Error pinning message: $e");
      showCustomToast('An error occurred while pinning message');
      return false;
    } finally {
      isPinningMessage(false);
    }
  }

  // Remove a message from pinned messages
  Future<bool> removePinMessage(String conversationId, String messageId) async {
    try {
      debugPrint("convo id: $conversationId,\nmid: $messageId");
      debugPrint("m id: $messageId");
      isRemovingPin(true);
      final uri = Uri.parse('${ApiHelper.baseUrl}/add-to-pin-message');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Accept': 'application/json',
        },
        body: {
          'message_id': messageId,
          'remove_from_pin': 'true',
          'conversation_id': conversationId,
          'duration': 'lifetime',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('print data of remove pin : $data');
        if (data['success'] == true) {
          // Refresh pinned messages
          await getPinnedMessages(conversationId);
          showCustomToast(data['message'] ?? 'Message removed from pins');
          return true;
        } else {
          showCustomToast(data['message'] ?? 'Failed to unpin message');
          return false;
        }
      } else {
        showCustomToast('Failed to unpin message');
        return false;
      }
    } catch (e) {
      debugPrint("Error unpinning message: $e");
      showCustomToast('An error occurred while unpinning message');
      return false;
    } finally {
      isRemovingPin(false);
    }
  }

  // Clear all resources when controller is closed
  @override
  void onClose() {
    pinMessageModel.value = PinMessageModel();
    super.onClose();
  }
}
