import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

typedef ShowOptionsCallback = Function();

class CoverImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String placeholderText;
  final Color placeholderBackgroundColor;
  final Color placeholderTextColor;
  final Color loaderColor;
  final int? cacheHeight;
  final File? localImage;
  final ShowOptionsCallback? onTap;

  const CoverImageWidget({
    Key? key,
    this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholderText = 'Please upload cover image',
    this.placeholderBackgroundColor = Colors.grey,
    this.placeholderTextColor = Colors.white,
    this.loaderColor = Colors.blue,
    this.cacheHeight,
    this.localImage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double defaultHeight = height ?? Get.height * 0.27;
    final double defaultWidth = width ?? double.infinity;

    // Display priority: 1. Local image, 2. Network image, 3. Placeholder

    // If we have a local image, show it
    if (localImage != null) {
      return SizedBox(
        height: defaultHeight,
        width: defaultWidth,
        child: Image.file(
          localImage!,
          fit: fit,
          height: defaultHeight,
          width: defaultWidth,
        ),
      );
    }

    // If no local image but URL is provided, show network image
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        imageUrl !=
            'https://control.whoxamessenger.com/uploads/not-found-images/profile-banner.png') {
      return SizedBox(
        height: defaultHeight,
        width: defaultWidth,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: fit,
          memCacheHeight: cacheHeight,
          placeholder: (context, url) => Container(
            color: placeholderBackgroundColor.withValues(alpha: 0.3),
            child: Center(
              child: CircularProgressIndicator(
                color: loaderColor,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.red.withValues(alpha: 0.2),
            child: const Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        ),
      );
    }

    // No image at all - show placeholder with text

    return SizedBox(
      height: defaultHeight,
      width: defaultWidth,
      child: Image.asset(
        'assets/images/98.png',
        fit: fit,
        height: defaultHeight,
        width: defaultWidth,
      ),
    );

    // return SizedBox(
    //   height: defaultHeight,
    //   width: defaultWidth,
    //   child: Container(
    //     color: placeholderBackgroundColor,
    //     child: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text(
    //             placeholderText,
    //             style: TextStyle(
    //               color: placeholderTextColor,
    //               fontWeight: FontWeight.bold,
    //               fontSize: 16,
    //             ),
    //             textAlign: TextAlign.center,
    //           ),
    //           const SizedBox(height: 10),
    //           Icon(
    //             Icons.add_photo_alternate_outlined,
    //             color: placeholderTextColor,
    //             size: 32,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
