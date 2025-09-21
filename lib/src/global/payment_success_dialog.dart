import 'package:whoxachat/src/global/global.dart';
import 'package:flutter/material.dart';

/// A highly customizable success widget that can be used in dialogs,
/// full screens, or embedded in other widgets.
class SuccessWidget extends StatefulWidget {
  /// The main title text displayed below the success icon
  final String title;

  /// The descriptive message displayed below the title
  final String message;

  /// Text for the primary action button
  final String primaryButtonText;

  /// Callback function when primary button is pressed
  final VoidCallback onPrimaryButtonPressed;

  /// Optional text for a secondary action button
  final String? secondaryButtonText;

  /// Optional callback function when secondary button is pressed
  final VoidCallback? onSecondaryButtonPressed;

  /// Whether to show the particle background
  final bool showParticles;

  /// Whether to animate the widget when it appears
  final bool animate;

  /// Optional custom widget to replace the default checkmark icon
  final Widget? customIcon;

  /// Size of the icon/image
  final double iconSize;

  /// Color of the title text
  final Color titleColor;

  /// Color of the message text
  final Color messageColor;

  /// Background color of the primary button
  final Color primaryButtonColor;

  /// Text color of the primary button
  final Color primaryButtonTextColor;

  /// Optional icon to show on the primary button
  final IconData? primaryButtonIcon;

  /// Width of the content container
  final double? width;

  /// Whether to use the GIF checkmark or a static icon
  final bool useGifCheckmark;

  const SuccessWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.showParticles = true,
    this.animate = true,
    this.customIcon,
    this.iconSize = 80,
    this.titleColor = Colors.black,
    this.messageColor = Colors.black87,
    this.primaryButtonColor = Colors.blue,
    this.primaryButtonTextColor = Colors.white,
    this.primaryButtonIcon,
    this.width,
    this.useGifCheckmark = true,
  }) : super(key: key);

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget = _buildContentWidget();

    if (widget.animate) {
      contentWidget = ScaleTransition(
        scale: _scaleAnimation,
        child: contentWidget,
      );
    }

    if (widget.showParticles) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Contained background particles - using ClipRRect to constrain it
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: widget.width ?? 320,
              height: (widget.width ?? 320) * 1.2, // Proportional height
              child: Image.asset(
                'assets/icons/particals.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content container
          contentWidget,
        ],
      );
    } else {
      return contentWidget;
    }
  }

  Widget _buildContentWidget() {
    return Container(
      width: widget.width ?? 320,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: 0.9), // Slightly transparent to show particles
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          _buildSuccessIcon(),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: widget.messageColor,
            ),
          ),
          const SizedBox(height: 28),

          // Primary button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onPrimaryButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryButtonColor,
                foregroundColor: widget.primaryButtonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.primaryButtonIcon != null) ...[
                    Icon(widget.primaryButtonIcon),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.primaryButtonText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Optional secondary button
          if (widget.secondaryButtonText != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: widget.onSecondaryButtonPressed,
                child: Text(
                  widget.secondaryButtonText!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    // Return custom icon if provided
    if (widget.customIcon != null) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: widget.customIcon,
      );
    }

    // Use GIF checkmark if specified
    if (widget.useGifCheckmark) {
      return Container(
        width: widget.iconSize,
        height: widget.iconSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Image.asset(
          'assets/icons/checkmark.gif',
          width: widget.iconSize,
          height: widget.iconSize,
        ),
      );
    }

    // Default to a blue badge with checkmark
    return Container(
      width: widget.iconSize,
      height: widget.iconSize,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: widget.iconSize * 0.6,
      ),
    );
  }
}

class EnhancedSuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool useGifCheckmark;
  final String? logoUrl;

  const EnhancedSuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
    this.useGifCheckmark = true,
    this.logoUrl,
  }) : super(key: key);

  @override
  State<EnhancedSuccessDialog> createState() => _EnhancedSuccessDialogState();
}

class _EnhancedSuccessDialogState extends State<EnhancedSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );


    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Particle background with fixed size container
            Container(
              width: size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/icons/particals.png'),
                  fit: BoxFit.cover,
                ),
              ),
              // Add some space around the content with semi-transparent overlay
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo/Checkmark with animation
                    _buildLogo(),

                    const SizedBox(height: 20),

                    // Title with fade-in animation
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Message with fade-in animation
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Text(
                        widget.message,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 14,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Button with scale animation
                    ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _controller,
                          curve: const Interval(0.6, 1.0,
                              curve: Curves.easeOutBack),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                secondaryColor,
                                chatownColor,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: TextButton(
                            onPressed: widget.onButtonPressed,
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )

                        //  SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //     onPressed: widget.onButtonPressed,
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Theme.of(context).primaryColor,
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.symmetric(vertical: 14),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(24),
                        //       ),
                        //       elevation: 3,
                        //     ),
                        //     child: Text(
                        //       widget.buttonText,
                        //       style: const TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Professional implementation for logo display
  Widget _buildLogo() {
    // Use default checkmark GIF if specified
    if (widget.useGifCheckmark) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/success_check.gif',
          height: 120,
          width: 120,
        ),
      );
    }

    // Use custom verification logo if available
    if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            widget.logoUrl!,
            height: 120,
            width: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/default_verification_badge.png',
                height: 120,
                width: 120,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: chatownColor,
                  strokeWidth: 2.0,
                ),
              );
            },
          ),
        ),
      );
    }

    // Default fallback image
    return SizedBox.shrink();
    // return Container(
    //   width: 120,
    //   height: 120,
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(15),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withValues(alpha: 0.1),
    //         blurRadius: 8,
    //         offset: const Offset(0, 2),
    //       ),
    //     ],
    //   ),
    //   child: Image.asset(
    //     'assets/images/default_verification_badge.png',
    //     height: 120,
    //     width: 120,
    //   ),
    // );
  }
}

/// Extension to show enhanced success dialog easily from any BuildContext
extension EnhancedSuccessDialogExtension on BuildContext {
  /// Shows the enhanced success dialog with particle background and animations
  Future<T?> showEnhancedSuccessDialog<T>({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool useGifCheckmark = true,
    String? logoUrl,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => EnhancedSuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        useGifCheckmark: useGifCheckmark,
        logoUrl: logoUrl,
      ),
    );
  }
}

/// Extension to show success dialog easily from any BuildContext
extension SuccessDialogExtension on BuildContext {
  /// Shows a success dialog with the given widget
  Future<T?> showSuccessDialog<T>({
    required SuccessWidget widget,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: widget,
      ),
    );
  }

  /// Shows a fixed background success dialog (recommended)
  Future<T?> showFixedBackgroundSuccessDialog<T>({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool useGifCheckmark = true,
    String? logoUrl,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => EnhancedSuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        useGifCheckmark: useGifCheckmark,
        logoUrl: logoUrl,
      ),
    );
  }
}
