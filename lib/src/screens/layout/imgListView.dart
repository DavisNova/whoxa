// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:whoxachat/src/global/global.dart';

class ImgListView extends StatefulWidget {
  String imgs;
  String groupName;
  ImgListView({super.key, required this.imgs, required this.groupName});

  @override
  State<ImgListView> createState() => _ImgListViewState();
}

class _ImgListViewState extends State<ImgListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [gradient1, gradient2],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          AppBar(
            toolbarHeight: 60,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: appColorWhite,
                    size: 24,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      const SizedBox(width: 10),
                      CapitalizedText(
                          widget.groupName.toString(),
                          const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20))
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
                height: 500,
                width: MediaQuery.sizeOf(context).width,
                child: CustomCachedNetworkImage(
                    imageUrl: widget.imgs,
                    placeholderColor: chatownColor,
                    errorWidgeticon: const Icon(Icons.person))),
          ),
        ]),
      ),
    );
  }
}
