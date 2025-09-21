package com.chatapp.beimo

import android.content.Context
import android.database.Cursor
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class GalleryPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "gallery_plugin")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getAllPhotos" -> {
                val photos = getAllPhotos()
                result.success(photos)
            }
            "getRecentPhotos" -> {
                val limit = call.argument<Int>("limit") ?: 20
                val photos = getRecentPhotos(limit)
                result.success(photos)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getAllPhotos(): List<String> {
        val photos = mutableListOf<String>()
        
        try {
            val projection = arrayOf(
                MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DATA,
                MediaStore.Images.Media.DATE_ADDED
            )
            
            val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                "${MediaStore.Images.Media.DATE_ADDED} DESC"
            )
            
            cursor?.use {
                val dataColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
                
                while (it.moveToNext()) {
                    val photoPath = it.getString(dataColumn)
                    if (photoPath != null && File(photoPath).exists()) {
                        photos.add(photoPath)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return photos
    }

    private fun getRecentPhotos(limit: Int): List<String> {
        val photos = mutableListOf<String>()
        
        try {
            val projection = arrayOf(
                MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DATA,
                MediaStore.Images.Media.DATE_ADDED
            )
            
            val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                "${MediaStore.Images.Media.DATE_ADDED} DESC LIMIT $limit"
            )
            
            cursor?.use {
                val dataColumn = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
                
                while (it.moveToNext()) {
                    val photoPath = it.getString(dataColumn)
                    if (photoPath != null && File(photoPath).exists()) {
                        photos.add(photoPath)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return photos
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
