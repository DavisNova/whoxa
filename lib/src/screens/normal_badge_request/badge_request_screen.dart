import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whoxachat/src/global/api_helper.dart';
import 'dart:convert';

import 'package:whoxachat/src/global/global.dart';

class BadgeRequestScreen extends StatefulWidget {
  const BadgeRequestScreen({Key? key}) : super(key: key);

  @override
  State<BadgeRequestScreen> createState() => _BadgeRequestScreenState();
}

class _BadgeRequestScreenState extends State<BadgeRequestScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  File? _selectedIdImage;
  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedIdImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedIdImage = null;
    });
  }

  Future<void> _submitBadgeRequest() async {
    // Validate inputs
    if (_fullNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
      return;
    }

    if (_selectedIdImage == null) {
      setState(() {
        _errorMessage = 'Please upload your government issued ID';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      const String baseUrl = ApiHelper.baseUrl;
      final Uri uri = Uri.parse('${baseUrl}/request-subscription-vip-user');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] =
          'Bearer ${Hive.box('userdata').get('authToken')}';
      request.headers['Accept'] = 'application/json';
      // Add text field
      request.fields['full_name'] = _fullNameController.text.trim();

      // Add file
      final fileExtension =
          _selectedIdImage!.path.split('.').last.toLowerCase();
      final mimeType = fileExtension == 'png'
          ? 'image/png'
          : fileExtension == 'pdf'
              ? 'application/pdf'
              : 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          _selectedIdImage!.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Add any required headers
      // request.headers['Authorization'] = 'Bearer your-token-here';

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Badge request submitted successfully')),
        );
        Navigator.pop(context); // Return to previous screen
      } else {
        final errorData = json.decode(responseBody);
        setState(() {
          _errorMessage = errorData['message'] ?? 'Failed to submit request';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get your app's theme colors
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                secondaryColor.withValues(alpha: 0.04),
                primaryColor.withValues(alpha: 0.04),
              ],
            ),
          ),
        ),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Request Verified Badge',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(CupertinoIcons.back, color: Colors.black)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0, color: const Color(0xFFE9E9E9)),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name Field
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Upload Government ID
                  const Text(
                    'Government Issued ID',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Upload area with DashedBorder
                        if (_selectedIdImage == null)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: CustomPaint(
                                painter: DashedBorderPainter(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                  gap: 5,
                                  radius: 16,
                                ),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 28,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Upload Government ID',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Upload PNG, JPG, JPEG & PDF formats',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Selected Image
                        if (_selectedIdImage != null)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedIdImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _removeImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informational text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Verification Information',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your ID will be used solely for verification purposes and will be handled securely. Once verified, your account will receive a verified badge.',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit Button with Gradient
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          //   child: Container(
          //     width: double.infinity,
          //     height: 48,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(24),
          //       gradient: LinearGradient(colors: [
          //         secondaryColor,
          //         chatownColor,
          //       ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          //     ),
          //     child: TextButton(
          //       onPressed: _isSubmitting ? null : _submitBadgeRequest,
          //       style: TextButton.styleFrom(
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(24),
          //         ),
          //       ),
          //       child: _isSubmitting
          //           ? const SizedBox(
          //               width: 24,
          //               height: 24,
          //               child: CircularProgressIndicator(
          //                 color: Colors.white,
          //                 strokeWidth: 2,
          //               ),
          //             )
          //           : const Text(
          //               'Submit Request',
          //               style: TextStyle(
          //                 color: Colors.black,
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //     ),
          //   ),
          // ),
          _isSubmitting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: chatownColor,
                    strokeWidth: 2,
                  ),
                )
              : CustomButtom(
                  onPressed: _isSubmitting ? null : _submitBadgeRequest,
                  title: "Submit Request",
                )
        ],
      ),
    );
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final Path dashPath = Path();
    double distance = 0.0;
    final PathMetrics pathMetrics = path.computeMetrics();

    for (final PathMetric pathMetric in pathMetrics) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + 3),
          Offset.zero,
        );
        distance += 3 + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
