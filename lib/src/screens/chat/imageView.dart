// ignore_for_file: must_be_immutable, file_names, deprecated_member_use

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whoxachat/src/global/global.dart';

class ImageView extends StatelessWidget {
  final String image;
  String userimg;
  ImageView({super.key, required this.image, required this.userimg});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Stack(
          children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: image,
                  placeholder: (context, url) => imagesloading(),
                ),
              ),
            )),
            Positioned(
              left: 10,
              top: 50,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: chatColor,
                  size: 24,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget imagesloading() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.transparent,
      child: const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: gradient1,
          ),
        ),
      ),
    );
  }
}
