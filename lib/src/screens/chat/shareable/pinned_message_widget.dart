// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:whoxachat/Models/pinned_message_model.dart';
// import 'package:whoxachat/controller/audio_controller.dart';
// import 'package:whoxachat/controller/pinned_message_controller.dart';
// import 'package:whoxachat/src/global/global.dart';
// import 'package:whoxachat/src/screens/chat/imageView.dart';
// import 'package:page_transition/page_transition.dart';

// class PinnedMessagesWidget extends StatelessWidget {
//   final PinMessageController controller;
//   final String conversationId;
//   final Function(String) scrollToMessage;
//   final AudioController audioController;

//   const PinnedMessagesWidget({
//     Key? key,
//     required this.controller,
//     required this.conversationId,
//     required this.scrollToMessage,
//     required this.audioController,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return Container(
//           height: 40,
//           alignment: Alignment.center,
//           child: const CupertinoActivityIndicator(),
//         );
//       }

//       final pinnedMessages = controller.pinMessageModel.value?.pinnedMessages;
//       if (pinnedMessages == null || pinnedMessages.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header bar
//           InkWell(
//             onTap: () {
//               // Toggle expansion state
//               controller.isExpanded.value = !controller.isExpanded.value;
//             },
//             child: Container(
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Back button
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: const Icon(Icons.push_pin, size: 20),
//                         ),

//                         // Message type avatar
//                         _buildMessageTypeAvatar(pinnedMessages.first),
//                         Text(
//                           _getMessageTypeLabel(pinnedMessages.first.chat),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Message content preview
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         '${pinnedMessages.length} messages',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),

//                       // Chevron icon for expansion
//                       Obx(() => Container(
//                             padding: const EdgeInsets.all(12),
//                             child: Icon(
//                               controller.isExpanded.value
//                                   ? Icons.keyboard_arrow_up
//                                   : Icons.keyboard_arrow_down,
//                               size: 22,
//                               color: Colors.grey.shade700,
//                             ),
//                           )),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Expanded list view
//           Obx(() {
//             if (!controller.isExpanded.value) {
//               return const SizedBox.shrink();
//             }

//             return Container(
//               constraints: const BoxConstraints(maxHeight: 300),
//               margin: const EdgeInsets.only(bottom: 8, right: 10, left: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(12),
//                   bottomRight: Radius.circular(12),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: ListView.separated(
//                 padding: const EdgeInsets.all(12),
//                 shrinkWrap: true,
//                 itemCount: pinnedMessages.length,
//                 separatorBuilder: (context, index) => const SizedBox(height: 8),
//                 itemBuilder: (context, index) {
//                   final pinnedMessage = pinnedMessages[index];

//                   // Get the message data from Chat property
//                   final chat = pinnedMessage.chat;
//                   if (chat == null) return const SizedBox.shrink();

//                   return _buildPinnedMessageCard(
//                     context,
//                     chat,
//                     pinnedMessage.user,
//                     pinnedMessage.messageId?.toString() ?? "",
//                   );
//                 },
//               ),
//             );
//           }),
//         ],
//       );
//     });
//   }

//   Widget _buildPinnedMessageCard(
//     BuildContext context,
//     Chat messageData,
//     User? sender,
//     String messageId,
//   ) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           if (messageData.messageId != null) {
//             controller.isExpanded.value = false;
//             scrollToMessage(messageData.messageId.toString());
//           }
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Ink(
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSenderInfo(messageData, sender),
//                     const SizedBox(height: 8),
//                     _buildMessageContent(context, messageData, sender),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(50),
//                   onTap: () async {
//                     if (!controller.isRemovingPin.value) {
//                       await controller.removePinMessage(
//                         conversationId,
//                         messageId,
//                       );
//                     }
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 3,
//                           offset: const Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: controller.isRemovingPin.value
//                         ? const SizedBox(
//                             width: 14,
//                             height: 14,
//                             child: CupertinoActivityIndicator(radius: 7),
//                           )
//                         : const Icon(Icons.push_pin,
//                             size: 14, color: Colors.black54),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageTypeAvatar(PinnedMessage pinnedMessage) {
//     // Check if we have a user with profile image
//     if (pinnedMessage.user?.profileImage != null &&
//         pinnedMessage.user!.profileImage!.isNotEmpty) {
//       return Container(
//         width: 30,
//         height: 30,
//         margin: const EdgeInsets.only(right: 10),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(15),
//           child: CachedNetworkImage(
//             imageUrl: pinnedMessage.user!.profileImage!,
//             fit: BoxFit.cover,
//             placeholder: (context, url) => Container(
//               color: Colors.amber.shade50,
//               child: Icon(Icons.person, size: 18, color: Colors.amber.shade700),
//             ),
//             errorWidget: (context, url, error) => Container(
//               color: Colors.amber.shade50,
//               child: Icon(Icons.person, size: 18, color: Colors.amber.shade700),
//             ),
//           ),
//         ),
//       );
//     }

//     // Default to message type icon
//     return Container(
//       width: 30,
//       height: 30,
//       margin: const EdgeInsets.only(right: 10),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.amber.shade100,
//       ),
//       child: Center(
//         child: _getMessageTypeIcon(pinnedMessage.chat),
//       ),
//     );
//   }

//   String _getMessageTypeLabel(Chat? chat) {
//     if (chat == null) return "Message";

//     // Determine message type based on messageType field
//     switch (chat.messageType) {
//       case 'image':
//         return "Photo";
//       case 'audio':
//         return "Audio";
//       case 'video':
//         return "Video";
//       case 'document':
//         return "Document";
//       case 'contact':
//         return "Contact";
//       case 'location':
//         return "Location";
//       default:
//         return "Message";
//     }
//   }

//   Widget _getMessageTypeIcon(Chat? chat) {
//     if (chat == null)
//       return Icon(Icons.push_pin, size: 16, color: Colors.amber.shade700);

//     // Return appropriate icon based on message type
//     switch (chat.messageType) {
//       case 'image':
//         return Icon(Icons.photo, size: 16, color: Colors.amber.shade700);
//       case 'audio':
//         return Icon(Icons.audiotrack, size: 16, color: Colors.amber.shade700);
//       case 'video':
//         return Icon(Icons.videocam, size: 16, color: Colors.amber.shade700);
//       case 'document':
//         return Icon(Icons.insert_drive_file,
//             size: 16, color: Colors.amber.shade700);
//       case 'contact':
//         return Icon(Icons.contact_phone,
//             size: 16, color: Colors.amber.shade700);
//       case 'location':
//         return Icon(Icons.location_on, size: 16, color: Colors.amber.shade700);
//       default:
//         return Icon(Icons.push_pin, size: 16, color: Colors.amber.shade700);
//     }
//   }

//   Widget _buildSenderInfo(Chat messageData, User? sender) {
//     final senderName = sender != null
//         ? "${sender.firstName ?? ''} ${sender.lastName ?? ''}"
//         : "User";

//     return Row(
//       children: [
//         // User avatar
//         if (sender?.profileImage != null && sender!.profileImage!.isNotEmpty)
//           Container(
//             width: 28,
//             height: 28,
//             margin: const EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border:
//                   Border.all(color: chatownColor.withOpacity(0.3), width: 2),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(14),
//               child: CachedNetworkImage(
//                 imageUrl: sender.profileImage!,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => const Center(
//                   child: CupertinoActivityIndicator(radius: 8),
//                 ),
//                 errorWidget: (context, url, error) => CircleAvatar(
//                   backgroundColor: chatownColor.withOpacity(0.1),
//                   child: Text(
//                     senderName.isNotEmpty ? senderName[0].toUpperCase() : "U",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: chatownColor,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         else
//           Container(
//             width: 28,
//             height: 28,
//             margin: const EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: chatownColor.withOpacity(0.1),
//               border:
//                   Border.all(color: chatownColor.withOpacity(0.3), width: 2),
//             ),
//             child: Center(
//               child: Text(
//                 senderName.isNotEmpty ? senderName[0].toUpperCase() : "U",
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: chatownColor,
//                 ),
//               ),
//             ),
//           ),

//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 senderName.trim().isEmpty ? "User" : senderName,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: chatownColor,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 formatTimeDifference(messageData.createdAt ?? ''),
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMessageContent(
//       BuildContext context, Chat messageData, User? sender) {
//     final messageType = messageData.messageType ?? '';

//     switch (messageType) {
//       case 'image':
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.photo, size: 20, color: chatownColor),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'Photo',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );

//       case 'video':
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.videocam, size: 20, color: chatownColor),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'Video',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );

//       case 'audio':
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.audiotrack, size: 20, color: chatownColor),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'Audio',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );

//       case 'document':
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.insert_drive_file, size: 20, color: chatownColor),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   _extractFilenameFromUrl(messageData.url ?? ''),
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         );

//       case 'contact':
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.contact_phone, size: 20, color: chatownColor),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   messageData.sharedContactName ?? 'Contact',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         );

//       case 'location':
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.location_on, size: 20, color: chatownColor),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'Location',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );

//       default:
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Text(
//             messageData.message ?? 'Message',
//             style: const TextStyle(fontSize: 14),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         );
//     }
//   }

//   // Helper function to extract filename from URL
//   String _extractFilenameFromUrl(String url) {
//     if (url.isEmpty) return 'document';

//     try {
//       // Split the URL by '/' and get the last part
//       String filename = url.split('/').last;

//       // If the filename contains a query string, remove it
//       if (filename.contains('?')) {
//         filename = filename.split('?').first;
//       }

//       // URL-decode the filename
//       filename = Uri.decodeComponent(filename);

//       return filename;
//     } catch (e) {
//       return 'document';
//     }
//   }

//   String formatTimeDifference(String dateString) {
//     if (dateString.isEmpty) return '';

//     try {
//       final messageDate = DateTime.parse(dateString);
//       final now = DateTime.now();
//       final difference = now.difference(messageDate);

//       if (difference.inDays > 7) {
//         // Format as "Apr 18" or similar
//         return '${_getMonthShort(messageDate.month)} ${messageDate.day}';
//       } else if (difference.inDays > 0) {
//         return difference.inDays == 1
//             ? 'Yesterday'
//             : '${difference.inDays}d ago';
//       } else if (difference.inHours > 0) {
//         return '${difference.inHours}h ago';
//       } else if (difference.inMinutes > 0) {
//         return '${difference.inMinutes}m ago';
//       } else {
//         return 'Just now';
//       }
//     } catch (e) {
//       return '';
//     }
//   }

//   String _getMonthShort(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return months[month - 1];
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:whoxachat/Models/pinned_message_model.dart';
import 'package:whoxachat/controller/audio_controller.dart';
import 'package:whoxachat/controller/pinned_message_controller.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinnedMessagesWidget extends StatelessWidget {
  final PinMessageController controller;
  final String conversationId;
  final Function(String) scrollToMessage;
  final AudioController audioController;

  const PinnedMessagesWidget({
    Key? key,
    required this.controller,
    required this.conversationId,
    required this.scrollToMessage,
    required this.audioController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          height: 40,
          alignment: Alignment.center,
          child: const CupertinoActivityIndicator(),
        );
      }

      final pinnedMessages = controller.pinMessageModel.value?.pinnedMessages;
      if (pinnedMessages == null || pinnedMessages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bar with message preview
          InkWell(
            onTap: () {
              // Toggle expansion state
              controller.isExpanded.value = !controller.isExpanded.value;
            },
            child: Container(
              height: 56, // Made taller to accommodate the message preview
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Left section with pin icon and message type
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Icon(Icons.push_pin,
                        size: 20, color: Colors.grey),
                  ),

                  // File type thumbnail based on message type
                  _buildFileThumbnail(pinnedMessages.first.chat),

                  // Middle section with message preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Message type label
                        Text(
                          _getMessageTypeLabel(pinnedMessages.first.chat),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        // Message preview text
                        if (pinnedMessages.first.chat?.message != null &&
                            pinnedMessages.first.chat!.message!.isNotEmpty)
                          Text(
                            pinnedMessages.first.chat!.message!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else if (pinnedMessages.first.chat?.messageType ==
                            'image')
                          Text(
                            'Photo message',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else if (pinnedMessages.first.chat?.messageType ==
                            'video')
                          Text(
                            'Video message',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else if (pinnedMessages.first.chat?.messageType ==
                            'audio')
                          Text(
                            'Audio message',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Text(
                            'Pinned message',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Right section with message count and expansion chevron
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${pinnedMessages.length} messages',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      // Chevron icon for expansion
                      Obx(() => Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              controller.isExpanded.value
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 22,
                              color: Colors.grey.shade700,
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded list view
          Obx(() {
            if (!controller.isExpanded.value) {
              return const SizedBox.shrink();
            }

            return Container(
              constraints: const BoxConstraints(maxHeight: 300),
              margin: const EdgeInsets.only(bottom: 8, right: 10, left: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                shrinkWrap: true,
                itemCount: pinnedMessages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final pinnedMessage = pinnedMessages[index];

                  // Get the message data from Chat property
                  final chat = pinnedMessage.chat;
                  if (chat == null) return const SizedBox.shrink();

                  return _buildPinnedMessageCard(
                    context,
                    chat,
                    pinnedMessage.user,
                    pinnedMessage.messageId?.toString() ?? "",
                  );
                },
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildPinnedMessageCard(
    BuildContext context,
    Chat messageData,
    User? sender,
    String messageId,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (messageData.messageId != null) {
            controller.isExpanded.value = false;
            scrollToMessage(messageData.messageId.toString());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSenderInfo(messageData, sender),
                    const SizedBox(height: 8),
                    _buildMessageContent(context, messageData, sender),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    if (!controller.isRemovingPin.value) {
                      await controller.removePinMessage(
                        conversationId,
                        messageId,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: controller.isRemovingPin.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CupertinoActivityIndicator(radius: 7),
                          )
                        : const Icon(Icons.push_pin,
                            size: 14, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileThumbnail(Chat? chat) {
    if (chat == null) {
      // Default fallback for null chat
      return Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.push_pin, size: 20, color: Colors.grey),
      );
    }

    final messageType = chat.messageType ?? '';

    // Handle different file types
    switch (messageType) {
      case 'image' || 'gif':
        // Image thumbnail
        if (chat.url != null && chat.url!.isNotEmpty) {
          return Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: chat.url!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.photo, size: 20, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.photo, size: 20, color: Colors.grey),
                ),
              ),
            ),
          );
        }
        break;

      case 'video':
        // Video thumbnail
        if (chat.url != null && chat.url!.isNotEmpty) {
          return Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: chat.url!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.videocam,
                          size: 20, color: Colors.grey),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.videocam,
                          size: 20, color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        break;

      case 'audio':
        // Audio thumbnail
        return Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Icon(
            Icons.audiotrack,
            size: 20,
            color: Colors.blue.shade700,
          ),
        );

      case 'document':
        // Document thumbnail
        String fileExt = _getFileExtension(chat.url ?? '');
        Color bgColor;
        Color textColor;

        // Set colors based on file type
        switch (fileExt.toLowerCase()) {
          case 'pdf':
            bgColor = Colors.red.shade50;
            textColor = Colors.red.shade800;
            break;
          case 'doc':
          case 'docx':
            bgColor = Colors.blue.shade50;
            textColor = Colors.blue.shade800;
            break;
          case 'xls':
          case 'xlsx':
            bgColor = Colors.green.shade50;
            textColor = Colors.green.shade800;
            break;
          case 'ppt':
          case 'pptx':
            bgColor = Colors.orange.shade50;
            textColor = Colors.orange.shade800;
            break;
          default:
            bgColor = Colors.grey.shade50;
            textColor = Colors.grey.shade800;
        }

        return Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file,
                size: 18,
                color: textColor,
              ),
              if (fileExt.isNotEmpty)
                Text(
                  fileExt.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
            ],
          ),
        );

      case 'contact':
        // Contact thumbnail
        return Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.purple.shade100),
          ),
          child: Icon(
            Icons.contact_phone,
            size: 20,
            color: Colors.purple.shade700,
          ),
        );

      case 'location':
        // Location thumbnail
        return Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.teal.shade100),
          ),
          child: Icon(
            Icons.location_on,
            size: 20,
            color: Colors.teal.shade700,
          ),
        );

      default:
        // Text message thumbnail
        return Container(
          width: 0,
          height: 0,
          // margin: const EdgeInsets.only(right: 10),
          // decoration: BoxDecoration(
          //   color: chatownColor.withOpacity(0.1),
          //   borderRadius: BorderRadius.circular(6),
          //   border: Border.all(color: chatownColor.withOpacity(0.3)),
          // ),
          // child: Icon(
          //   Icons.chat_bubble_outline,
          //   size: 20,
          //   color: chatownColor,
          // ),
        );
    }

    // Default fallback if specific cases don't return
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(
        _getIconForMessageType(messageType),
        size: 20,
        color: Colors.grey.shade700,
      ),
    );
  }

  IconData _getIconForMessageType(String messageType) {
    switch (messageType) {
      case 'image':
        return Icons.photo;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'document':
        return Icons.insert_drive_file;
      case 'contact':
        return Icons.contact_phone;
      case 'location':
        return Icons.location_on;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  String _getFileExtension(String url) {
    if (url.isEmpty) return '';

    try {
      // Get filename from URL
      String filename = url.split('/').last;

      // Remove query parameters if any
      if (filename.contains('?')) {
        filename = filename.split('?').first;
      }

      // Get extension
      if (filename.contains('.')) {
        return filename.split('.').last;
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  String _getMessageTypeLabel(Chat? chat) {
    if (chat == null) return "Message";

    // Determine message type based on messageType field
    switch (chat.messageType) {
      case 'image':
        return "Photo";
      case 'audio':
        return "Audio";
      case 'video':
        return "Video";
      case 'document':
        return "Document";
      case 'contact':
        return "Contact";
      case 'location':
        return "Location";
      case 'gif':
        return "GIF";
      default:
        return "Message";
    }
  }

  // Widget _getMessageTypeIcon(Chat? chat) {
  //   if (chat == null)
  //     return Icon(Icons.push_pin, size: 16, color: Colors.amber.shade700);

  //   // Return appropriate icon based on message type
  //   switch (chat.messageType) {
  //     case 'image':
  //       return Icon(Icons.photo, size: 16, color: Colors.amber.shade700);
  //     case 'audio':
  //       return Icon(Icons.audiotrack, size: 16, color: Colors.amber.shade700);
  //     case 'video':
  //       return Icon(Icons.videocam, size: 16, color: Colors.amber.shade700);
  //     case 'document':
  //       return Icon(Icons.insert_drive_file,
  //           size: 16, color: Colors.amber.shade700);
  //     case 'contact':
  //       return Icon(Icons.contact_phone,
  //           size: 16, color: Colors.amber.shade700);
  //     case 'location':
  //       return Icon(Icons.location_on, size: 16, color: Colors.amber.shade700);
  //     default:
  //       return Icon(Icons.push_pin, size: 16, color: Colors.amber.shade700);
  //   }
  // }

  Widget _buildSenderInfo(Chat messageData, User? sender) {
    // Get sender name from User object
    // If sender is null or both firstName and lastName are empty, show "User" as default
    final senderName = sender != null
        ? "${sender.firstName ?? ''} ${sender.lastName ?? ''}"
        : "User";

    return Row(
      children: [
        // User avatar/thumbnail
        // This displays the user's profile image if available, or shows a fallback with first letter initial
        if (sender?.profileImage != null && sender!.profileImage!.isNotEmpty)
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: chatownColor.withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: sender.profileImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CupertinoActivityIndicator(radius: 8),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: chatownColor.withOpacity(0.1),
                  child: Text(
                    senderName.isNotEmpty ? senderName[0].toUpperCase() : "U",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: chatownColor,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          // Fallback avatar with first letter of sender's name
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chatownColor.withOpacity(0.1),
              border:
                  Border.all(color: chatownColor.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : "U",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: chatownColor,
                ),
              ),
            ),
          ),

        // Sender name and message timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display sender's full name
              // If name is empty, show "User" as fallback
              Text(
                senderName.trim().isEmpty ? "User" : senderName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: chatownColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Show relative time when message was sent
              Text(
                formatTimeDifference(messageData.createdAt ?? ''),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(
      BuildContext context, Chat messageData, User? sender) {
    final messageType = messageData.messageType ?? '';

    switch (messageType) {
      case 'image' || 'gif':
        // Added thumbnail preview for image messages
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              // Message type icon
              Icon(Icons.photo, size: 20, color: chatownColor),
              const SizedBox(width: 8),

              // Message type text
              const Expanded(
                child: Text(
                  'Photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Image thumbnail
              if (messageData.url != null && messageData.url!.isNotEmpty)
                InkWell(
                  onTap: () {
                    // Open full image view when thumbnail is tapped
                    // Navigator.push(
                    //   context,
                    //   PageTransition(
                    //     type: PageTransitionType.fade,
                    //     child: ImageViewPage(imageUrl: messageData.url!),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        imageUrl: messageData.url!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CupertinoActivityIndicator(radius: 10),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.error_outline, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

      case 'video':
        // Added thumbnail preview for video messages
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.videocam, size: 20, color: chatownColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Video',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Video thumbnail - Using messageData.url directly
              if (messageData.url != null && messageData.url!.isNotEmpty)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video thumbnail image from URL
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          // Using the actual video URL as the thumbnail source
                          imageUrl: messageData.url!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CupertinoActivityIndicator(radius: 10),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.error_outline, size: 20),
                          ),
                        ),
                      ),

                      // Play icon overlay
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

      case 'audio':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.audiotrack, size: 20, color: chatownColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Audio',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'document':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file, size: 20, color: chatownColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _extractFilenameFromUrl(messageData.url ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

      case 'contact':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.contact_phone, size: 20, color: chatownColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  messageData.sharedContactName ?? 'Contact',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

      case 'location':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, size: 20, color: chatownColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Text(
            messageData.message ?? 'Message',
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
    }
  }

  // Helper function to extract filename from URL
  String _extractFilenameFromUrl(String url) {
    if (url.isEmpty) return 'document';

    try {
      // Split the URL by '/' and get the last part
      String filename = url.split('/').last;

      // If the filename contains a query string, remove it
      if (filename.contains('?')) {
        filename = filename.split('?').first;
      }

      // URL-decode the filename
      filename = Uri.decodeComponent(filename);

      return filename;
    } catch (e) {
      return 'document';
    }
  }

  String formatTimeDifference(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final messageDate = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(messageDate);

      if (difference.inDays > 7) {
        // Format as "Apr 18" or similar
        return '${_getMonthShort(messageDate.month)} ${messageDate.day}';
      } else if (difference.inDays > 0) {
        return difference.inDays == 1
            ? 'Yesterday'
            : '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
