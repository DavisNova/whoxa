import 'dart:convert';
import 'dart:developer';
import 'package:whoxachat/Models/user_profile_model.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/user/FinalLogin.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class UserStatusService {
  static final ApiHelper _apiHelper = ApiHelper();

  // Main method to check user status
  static Future<bool> checkUserStatus(BuildContext context) async {
    try {
      // Get user details
      final UserProfileModel? userProfile = await fetchUserDetails();
      if (userProfile == null) {
        return false;
      }

      // Check if user is blocked by admin
      bool isBlockedByAdmin = userProfile.resData?.blockedByAdmin ?? false;
      print('::::::::::::::::::::::::::::::');
      print('logout check :${userProfile.resData?.blockedByAdmin}');
      print('::::::::::::::::::::::::::::::');
      // If user is blocked, log them out
      if (isBlockedByAdmin) {
        _handleUserBlocked(context);
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking user status: $e');
      return false;
    }
  }

  // Fetch user details from API - reused from GreetingsService
  static Future<UserProfileModel?> fetchUserDetails() async {
    try {
      final token = Hive.box(userdata).get(authToken);
      if (token == null) {
        return null;
      }

      final response = await http.post(
        Uri.parse(_apiHelper.userCreateProfile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('user profile response: $data');
        return UserProfileModel.fromJson(data);
      } else {
        print(
            'Failed to fetch user details. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during fetching user details: $e');
      return null;
    }
  }

  // Handle user blocked - log out user
  static void _handleUserBlocked(BuildContext context) async {
    try {
      var box = Hive.box(userdata);

      // Clear all user data from Hive
      await box.delete(userId);
      await box.delete(authToken);
      await box.delete(firstName);
      await box.delete(lastName);
      await box.clear(); // Clear all data in the box

      // Navigate to login screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Flogin(),
        ),
        (route) => false,
      );
    } catch (e) {
      print('Error during logout process: $e');
    }
  }

  // Call this method from any screen to check user status
  static Future<void> checkAndHandleUserStatus(BuildContext context) async {
    await checkUserStatus(context);
  }
}
