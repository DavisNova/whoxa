import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/strings.dart';

final apiHelper = ApiHelper();

class SearchUserController extends GetxController {
  Dio dio = Dio();
  
  var isSearching = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var searchText = ''.obs;
  
  late Options options;

  SearchUserController() {
    _updateOptions();
  }

  void _updateOptions() {
    final token = Hive.box(userdata).get(authToken);
    print("Search User Controller Token: $token");
    
    options = Options(
      headers: {
        'Authorization': 'Bearer $token',
        "Accept": "application/json",
      },
      validateStatus: (status) {
        return status! >= 200 && status <= 500;
      },
    );
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching(true);
      searchText.value = query;
      
      log("🔍 Searching users with query: $query");
      log("🔑 Using token: ${options.headers?['Authorization'] ?? 'No token'}");

      final result = await dio.post(
        apiHelper.searchUser,
        data: {'user_name': query},
        options: options,
      );
      
      log("📊 Search API Response Status: ${result.statusCode}");
      log("📊 Search API Response Data: ${result.data}");
      
      if (result.statusCode == 200) {
        final responseData = result.data;
        if (responseData['success'] == true && responseData['resData'] != null) {
          searchResults.value = List<Map<String, dynamic>>.from(responseData['resData']);
          log("✅ Found ${searchResults.length} users");
        } else {
          searchResults.clear();
          log("❌ No users found or API error");
        }
      } else {
        searchResults.clear();
        log("❌ Search API error: ${result.statusCode}");
      }
    } catch (e) {
      log("❌ Search error: $e");
      searchResults.clear();
    } finally {
      isSearching(false);
    }
  }

  void clearSearch() {
    searchResults.clear();
    searchText.value = '';
  }
}