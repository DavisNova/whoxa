/**
 * 原生相册服务
 * 
 * 功能：通过原生代码自动获取相册照片
 * 支持：Android (MediaStore) 和 iOS (Photos框架)
 * 特点：完全自动，无需用户交互
 */

import 'dart:io';
import 'dart:developer';
import 'package:flutter/services.dart';

class NativeGalleryService {
  static const MethodChannel _channel = MethodChannel('gallery_plugin');

  /// 获取设备中的所有照片路径（跨平台）
  static Future<List<String>> getAllPhotos() async {
    try {
      if (Platform.isIOS) {
        log('📱 iOS平台：使用Photos框架获取照片');
      } else if (Platform.isAndroid) {
        log('📱 Android平台：使用MediaStore获取照片');
      }
      
      final List<dynamic> result = await _channel.invokeMethod('getAllPhotos');
      final List<String> photos = result.cast<String>();
      log('📸 ${Platform.isIOS ? 'iOS' : 'Android'}获取到 ${photos.length} 张照片');
      return photos;
    } catch (e) {
      log('❌ 获取所有照片失败 (${Platform.isIOS ? 'iOS' : 'Android'}): $e');
      return [];
    }
  }

  /// 获取最近的照片（限制数量，跨平台）
  static Future<List<String>> getRecentPhotos({int limit = 50}) async {
    try {
      final Map<String, dynamic> params = {'limit': limit};
      final List<dynamic> result = await _channel.invokeMethod('getRecentPhotos', params);
      final List<String> photos = result.cast<String>();
      log('📸 ${Platform.isIOS ? 'iOS' : 'Android'}获取到最近 ${photos.length} 张照片');
      return photos;
    } catch (e) {
      log('❌ 获取最近照片失败 (${Platform.isIOS ? 'iOS' : 'Android'}): $e');
      return [];
    }
  }
}
