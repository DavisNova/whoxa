// sticker_service.dart - Updated for proper subscription checking
import 'dart:developer';

import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/chat/sticker/data/models/sticker_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'dart:typed_data';

class StickerService extends GetxService {
  // Constants
  static const int pageSize = 16; // Items per page

  // Sticker related observables
  final RxList<StickerItem> stickers = <StickerItem>[].obs;
  final RxBool isStickerLoading = false.obs;
  final RxBool stickerHasMore = true.obs;
  final RxInt stickerCurrentPage = 1.obs;
  final RxString stickerError = ''.obs;

  // GIF related observables
  final RxList<StickerItem> gifs = <StickerItem>[].obs;
  final RxBool isGifLoading = false.obs;
  final RxBool gifHasMore = true.obs;
  final RxInt gifCurrentPage = 1.obs;
  final RxString gifError = ''.obs;

  // User subscription status
  final RxBool hasSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't check subscription on init - let the bottom sheet handle it
    loadStickers();
    loadGifs();
  }

  // Check user subscription status - ALWAYS makes API call
  Future<void> checkSubscriptionStatus() async {
    try {
      final token = Hive.box(userdata).get(authToken);
      print('🔑 Token retrieved: ${token != null ? 'Present' : 'Null'}');

      if (token == null) {
        print('❌ No token found, setting hasSubscription to false');
        hasSubscription.value = false;
        return;
      }

      print('🌐 Making API request to: ${ApiHelper.baseUrl}/user-details');
      print('🔐 Authorization header: Bearer ${token.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/user-details'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(const Duration(seconds: 15)); // Add timeout for better UX

      print('📡 Response Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📦 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Success response received');

        final data = json.decode(response.body);
        print('🔍 Parsed JSON Data: $data');

        final userProfile = UserProfileModel.fromJson(data);
        print('👤 User Profile Created: ${userProfile.toString()}');

        final verificationType = userProfile.resData?.verificationType;
        print('🎫 Verification Type: $verificationType');
        print('📋 ResData: ${userProfile.resData}');

        hasSubscription.value = verificationType != null;
        print('💳 Final hasSubscription value: ${hasSubscription.value}');
      } else {
        print('❌ Non-200 status code received');
        print('🔍 Error Response Body: ${response.body}');
        hasSubscription.value = false;
        print('💳 hasSubscription set to: false (due to error response)');
      }
    } catch (e, stackTrace) {
      print('💥 Exception caught in checkSubscriptionStatus:');
      print('🚨 Error: $e');
      print('📍 Stack Trace: $stackTrace');
      hasSubscription.value = false;
      print('💳 hasSubscription set to: false (due to exception)');

      // Re-throw the exception so the UI can handle it
      throw e;
    }
  }

  // Method to refresh subscription status when user subscribes
  Future<void> refreshSubscriptionStatus() async {
    print('🔄 Refreshing subscription status...');
    await checkSubscriptionStatus();
  }

  // Load stickers - Show all stickers including premium ones
  Future<void> loadStickers({bool refresh = false}) async {
    if (refresh) {
      stickerCurrentPage.value = 1;
      stickers.clear();
      stickerHasMore.value = true;
    }

    if (isStickerLoading.value || !stickerHasMore.value) return;

    try {
      isStickerLoading.value = true;
      stickerError.value = '';

      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/list-all-stickers'),
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'type': 'sticker',
          'page': stickerCurrentPage.value,
          'limit': pageSize,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        log('loadStickers response: $responseData');
        final stickerResponse = StickerResponse.fromJson(responseData);

        if (stickerResponse.success == true &&
            stickerResponse.stickers != null) {
          List<StickerItem> allStickers = stickerResponse.stickers!;

          if (refresh) {
            stickers.value = allStickers;
          } else {
            stickers.addAll(allStickers);
          }

          if (stickerResponse.pagination != null) {
            stickerHasMore.value = stickerCurrentPage.value <
                (stickerResponse.pagination!.totalPages ?? 1);
          } else {
            stickerHasMore.value = false;
          }

          stickerCurrentPage.value++;
        } else {
          stickerError.value =
              stickerResponse.message ?? 'Failed to load stickers';
          stickerHasMore.value = false;
        }
      } else {
        stickerError.value = 'Server error: ${response.statusCode}';
        stickerHasMore.value = false;
      }
    } catch (e) {
      stickerError.value = 'Network error: ${e.toString()}';
      stickerHasMore.value = false;
    } finally {
      isStickerLoading.value = false;
    }
  }

  // Load GIFs - Show all GIFs including premium ones
  Future<void> loadGifs({bool refresh = false}) async {
    if (refresh) {
      gifCurrentPage.value = 1;
      gifs.clear();
      gifHasMore.value = true;
    }

    if (isGifLoading.value || !gifHasMore.value) return;

    try {
      isGifLoading.value = true;
      gifError.value = '';

      final response = await http.post(
        Uri.parse('${ApiHelper.baseUrl}/list-all-stickers'),
        headers: {
          'Authorization': 'Bearer ${Hive.box(userdata).get(authToken)}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'type': 'gif',
          'page': gifCurrentPage.value,
          'limit': pageSize,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final gifResponse = StickerResponse.fromJson(responseData);

        if (gifResponse.success == true && gifResponse.stickers != null) {
          List<StickerItem> allGifs = gifResponse.stickers!;

          if (refresh) {
            gifs.value = allGifs;
          } else {
            gifs.addAll(allGifs);
          }

          if (gifResponse.pagination != null) {
            gifHasMore.value = gifCurrentPage.value <
                (gifResponse.pagination!.totalPages ?? 1);
          } else {
            gifHasMore.value = false;
          }

          gifCurrentPage.value++;
        } else {
          gifError.value = gifResponse.message ?? 'Failed to load GIFs';
          gifHasMore.value = false;
        }
      } else {
        gifError.value = 'Server error: ${response.statusCode}';
        gifHasMore.value = false;
      }
    } catch (e) {
      gifError.value = 'Network error: ${e.toString()}';
      gifHasMore.value = false;
    } finally {
      isGifLoading.value = false;
    }
  }

  Future<void> refreshStickers() async {
    await loadStickers(refresh: true);
  }

  Future<void> loadMoreStickers() async {
    await loadStickers();
  }

  Future<void> refreshGifs() async {
    await loadGifs(refresh: true);
  }

  Future<void> loadMoreGifs() async {
    await loadGifs();
  }

  // Method to get sticker bytes for sending (if needed)
  Future<Uint8List?> getStickerBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error loading sticker bytes: $e');
    }
    return null;
  }

  void clearAllData() {
    stickers.clear();
    gifs.clear();
    stickerCurrentPage.value = 1;
    gifCurrentPage.value = 1;
    stickerHasMore.value = true;
    gifHasMore.value = true;
    stickerError.value = '';
    gifError.value = '';
  }
}
