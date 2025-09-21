// sticker_bottom_sheet.dart - WITH SUBSCRIPTION CHECK LOADER
import 'package:whoxachat/src/screens/chat/sticker/data/models/sticker_model.dart';
import 'package:whoxachat/src/screens/chat/sticker/data/sticker_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class StickerBottomSheet extends StatefulWidget {
  final Function(StickerItem, String) onItemSelected;
  final VoidCallback? onCancel;

  const StickerBottomSheet({
    Key? key,
    required this.onItemSelected,
    this.onCancel,
  }) : super(key: key);

  @override
  State<StickerBottomSheet> createState() => _StickerBottomSheetState();
}

class _StickerBottomSheetState extends State<StickerBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StickerService stickerService = Get.find<StickerService>();
  int _selectedTabIndex = 0;

  // Subscription check states
  bool _isCheckingSubscription = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab controller changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });

    // Check subscription status on init
    _checkSubscriptionAndInitialize();
  }

  // Check subscription status and then initialize
  Future<void> _checkSubscriptionAndInitialize() async {
    try {
      setState(() {
        _isCheckingSubscription = true;
      });

      // Always check subscription status with await
      await stickerService.checkSubscriptionStatus();

      setState(() {
        _isCheckingSubscription = false;
      });
    } catch (e) {
      print('Error checking subscription: $e');
      setState(() {
        _isCheckingSubscription = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Column(
        children: [
          const Text(
            'Select Sticker or GIF',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Show loader while checking subscription
          if (_isCheckingSubscription)
            const Column(
              children: [
                CupertinoActivityIndicator(),
                SizedBox(height: 8),
                Text(
                  'Checking subscription...',
                  style: TextStyle(
                      fontSize: 14, color: CupertinoColors.systemGrey),
                ),
              ],
            )
          else
            // Tab bar - only show when subscription check is complete
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CupertinoSlidingSegmentedControl<int>(
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Stickers'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('GIFs'),
                  ),
                },
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTabIndex = value;
                    });
                    _tabController.animateTo(value);
                  }
                },
                groupValue: _selectedTabIndex,
              ),
            ),
        ],
      ),
      message: Container(
        height: 400,
        child: _isCheckingSubscription
            ? _buildSubscriptionLoader()
            : TabBarView(
                controller: _tabController,
                children: [
                  // Stickers tab
                  _buildStickerGrid(),
                  // GIFs tab
                  _buildGifGrid(),
                ],
              ),
      ),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          if (widget.onCancel != null) widget.onCancel!();
        },
        child: const Text('Cancel'),
      ),
    );
  }

  // Subscription check loader widget
  Widget _buildSubscriptionLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 20),
          SizedBox(height: 16),
          Text(
            'Verifying subscription status...',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (stickerService.stickers.isEmpty &&
                stickerService.isStickerLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (stickerService.stickerError.value.isNotEmpty) {
              return _buildErrorWidget(
                stickerService.stickerError.value,
                () => stickerService.refreshStickers(),
              );
            }

            if (stickerService.stickers.isEmpty) {
              return const Center(child: Text('No stickers available'));
            }

            return _buildGrid(
              items: stickerService.stickers,
              hasMore: stickerService.stickerHasMore.value,
              isLoading: stickerService.isStickerLoading.value,
              onLoadMore: () => stickerService.loadMoreStickers(),
              onItemTap: (item) => widget.onItemSelected(item, 'sticker'),
              contentType: 'sticker',
            );
          }),
        ),
        _buildRefreshButton(() => stickerService.refreshStickers()),
      ],
    );
  }

  Widget _buildGifGrid() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (stickerService.gifs.isEmpty &&
                stickerService.isGifLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (stickerService.gifError.value.isNotEmpty) {
              return _buildErrorWidget(
                stickerService.gifError.value,
                () => stickerService.refreshGifs(),
              );
            }

            if (stickerService.gifs.isEmpty) {
              return const Center(child: Text('No GIFs available'));
            }

            return _buildGrid(
              items: stickerService.gifs,
              hasMore: stickerService.gifHasMore.value,
              isLoading: stickerService.isGifLoading.value,
              onLoadMore: () => stickerService.loadMoreGifs(),
              onItemTap: (item) => widget.onItemSelected(item, 'gif'),
              contentType: 'gif',
            );
          }),
        ),
        _buildRefreshButton(() => stickerService.refreshGifs()),
      ],
    );
  }

  Widget _buildGrid({
    required List<StickerItem> items,
    required bool hasMore,
    required bool isLoading,
    required VoidCallback onLoadMore,
    required Function(StickerItem) onItemTap,
    required String contentType,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            hasMore &&
            !isLoading) {
          onLoadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final item = items[index];
          final isPremium = item.isPremium ?? false;
          final hasSubscription = stickerService.hasSubscription.value;

          return GestureDetector(
            onTap: () {
              if (isPremium && !hasSubscription) {
                _showSubscriptionRequiredDialog(contentType);
                return;
              }
              Navigator.of(context).pop();
              onItemTap(item);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CachedNetworkImage(
                      imageUrl: item.fileLocation ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: CupertinoColors.systemGrey6,
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: CupertinoColors.systemGrey6,
                        child: const Icon(
                          CupertinoIcons.photo,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ),
                  // Premium badge (top-right corner)
                  if (isPremium)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasSubscription
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hasSubscription ? '✓' : '★',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Lock overlay for premium items without subscription
                  if (isPremium && !hasSubscription)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: CupertinoColors.black.withValues(alpha: 0.6),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.lock_fill,
                              color: CupertinoColors.white,
                              size: 20,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            style: const TextStyle(color: CupertinoColors.systemRed),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(VoidCallback onRefresh) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoButton(
        onPressed: onRefresh,
        child: const Text('Refresh'),
      ),
    );
  }

  void _showSubscriptionRequiredDialog(String contentType) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Subscription Required'),
        content: Text(
          'You need to subscribe first to use this ${contentType}. Upgrade to premium to access all ${contentType}s and GIFs.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}

// Updated StickerPicker class with subscription check
class StickerPicker {
  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    final Completer<Map<String, dynamic>?> completer =
        Completer<Map<String, dynamic>?>();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StickerBottomSheet(
          onItemSelected: (item, type) {
            completer.complete({
              'item': item,
              'type': type,
            });
          },
          onCancel: () {
            completer.complete(null);
          },
        );
      },
    );

    return completer.future;
  }
}
