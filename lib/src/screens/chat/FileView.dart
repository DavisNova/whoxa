import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FileView extends StatefulWidget {
  final String file;
  const FileView({super.key, required this.file});

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  String? _errorMessage;
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    print("PDF URL: ${widget.file}");

    // Initialize loading state here, not during build
    _isLoading = true;

    // Add post-frame callback to update state after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePdfViewer();
    });
  }

  void _initializePdfViewer() {
    // This method is called after the build is complete
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
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
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Document'),
      ),
      body: Stack(
        children: [
          // Use a Builder to separate the PDF viewer from the loading indicators
          Builder(
            builder: (context) {
              return SfPdfViewer.network(
                widget.file,
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                canShowScrollHead: true,
                canShowPaginationDialog: true,
                enableDoubleTapZooming: true,
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  // Use post-frame callback to avoid setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = "Failed to load PDF: ${details.error}";
                    });
                  });
                },
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  // Use post-frame callback to avoid setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _isLoading = false;
                    });
                    print("PDF loaded successfully");
                  });
                },
              );
            },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _initializePdfViewer();
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
