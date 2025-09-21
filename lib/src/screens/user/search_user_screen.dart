import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whoxachat/controller/search_user_controller.dart';
import 'package:whoxachat/controller/launguage_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/screens/chat/single_chat.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final SearchUserController searchController = Get.put(SearchUserController());
  final TextEditingController searchTextController = TextEditingController();
  final LanguageController languageController = Get.find();
  final Dio dio = Dio();
  final ApiHelper apiHelper = ApiHelper();

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          languageController.textTranslate('Search Users'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchTextController,
              decoration: InputDecoration(
                hintText: languageController.textTranslate('Search by username'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchTextController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchTextController.clear();
                          searchController.clearSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: chatownColor),
                ),
              ),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  searchController.searchUsers(value.trim());
                } else {
                  searchController.clearSearch();
                }
              },
            ),
          ),
          
          // 搜索结果
          Expanded(
            child: Obx(() {
              if (searchController.isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (searchController.searchText.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageController.textTranslate('Search for users by username'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (searchController.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageController.textTranslate('No users found'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: searchController.searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchController.searchResults[index];
                  return _buildUserTile(user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: user['profile_image'] != null && user['profile_image'].isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user['profile_image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.person),
                )
              : const Icon(Icons.person, size: 30),
        ),
      ),
      title: Text(
        user['user_name'] ?? 'Unknown User',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user['bio'] != null && user['bio'].isNotEmpty)
            Text(
              user['bio'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          if (user['email_id'] != null && user['email_id'].isNotEmpty)
            Text(
              user['email_id'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          // TODO: 实现添加用户到联系人的功能
          _showAddContactDialog(user);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: chatownColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          languageController.textTranslate('Add'),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void _showAddContactDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageController.textTranslate('Add Contact')),
        content: Text(
          '${languageController.textTranslate('Add')} ${user['user_name']} ${languageController.textTranslate('to your contacts?')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageController.textTranslate('Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现添加联系人的API调用
              _addContact(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: chatownColor),
            child: Text(
              languageController.textTranslate('Add'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _addContact(Map<String, dynamic> user) async {
    try {
      // 显示加载状态
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final token = Hive.box(userdata).get(authToken);
      log("🔗 Adding contact: ${user['user_name']} (${user['phone_number']})");
      log("🔑 Using token: Bearer $token");

      final response = await dio.post(
        apiHelper.addContact,
        data: {
          'phone_number': user['phone_number'],
          'full_name': user['user_name'] ?? user['first_name'] ?? user['phone_number'],
        },
        options: Options(
          headers: {
            "Accept": "application/json",
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log("📊 Add Contact API Response Status: ${response.statusCode}");
      log("📊 Add Contact API Response Data: ${response.data}");

      Get.back(); // 关闭加载对话框

      if (response.statusCode == 200 && response.data['success'] == true) {
        Get.snackbar(
          languageController.textTranslate('Success'),
          '${languageController.textTranslate('Added')} ${user['user_name']} ${languageController.textTranslate('to contacts')}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // 添加成功后直接跳转到聊天界面
        Get.back(); // 关闭搜索页面
        Get.to(() => SingleChatMsg(
          conversationID: '', // 空字符串表示创建新对话
          username: user['user_name'] ?? user['first_name'] ?? user['phone_number'],
          userPic: user['profile_image'] ?? '',
          mobileNum: user['phone_number'],
          index: 0,
          userID: user['user_id'].toString(),
          verificationBadge: '', // 可以根据需要添加验证徽章
        ));
      } else {
        Get.snackbar(
          languageController.textTranslate('Error'),
          response.data['message'] ?? 'Failed to add contact',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // 关闭加载对话框
      log("Error adding contact: $e");
      Get.snackbar(
        languageController.textTranslate('Error'),
        'Failed to add contact: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
