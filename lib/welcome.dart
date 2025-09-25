// ignore_for_file: avoid_print, unused_local_variable, deprecated_member_use, unused_field
import 'package:flutter/material.dart';
import 'package:whoxachat/app.dart';
import 'package:whoxachat/src/global/global.dart';
import 'package:whoxachat/src/global/strings.dart';
import 'package:whoxachat/src/screens/layout/bottombar.dart';
import 'package:whoxachat/src/screens/user/FinalLogin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:hive/hive.dart';

class Welcome extends StatefulWidget {
  final bool fromAppScreen;
  const Welcome({super.key, this.fromAppScreen = false});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  bool _requestingPermission = false;
  int _currentPermissionIndex = 0;
  bool _continuePressed = false;
  bool _permissionsInitialized = false;
  bool _showPermissionEducation = false;
  bool _permissionFlowStarted = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Track which permissions have already been granted
  Map<Permission, bool> _permissionsGranted = {};
  late List<Map<String, dynamic>> _permissions;

  // Initialize permissions list based on platform
  void _initPermissionsList() {
    _permissions = [
      {
        'permission': Permission.contacts,
        'title': 'Contacts',
        'description': 'Find friends who are already using the app',
        'icon': Icons.contacts_outlined,
        'color': Color(0xFF9C27B0),
        'benefit': 'Connect with existing friends'
      },
    ];

    // 添加相册权限 - 根据平台使用不同的权限
    if (Platform.isIOS) {
      _permissions.add({
        'permission': Permission.photos,
        'title': 'Photos',
        'description': 'Share photos from your gallery with friends and backup photos',
        'icon': Icons.photo_library_outlined,
        'color': Color(0xFF00BCD4),
        'benefit': 'Share your favorite memories'
      });
    } else {
      _permissions.add({
        'permission': Permission.storage,
        'title': 'Storage',
        'description': 'Access photos and files to share with friends and backup photos',
        'icon': Icons.folder_outlined,
        'color': Color(0xFF00BCD4),
        'benefit': 'Share photos and files'
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _initPermissionsList();
    _checkAllPermissionsStatus().then((_) {
      setState(() {
        _permissionsInitialized = true;
      });

      // Start animations
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();

      if (widget.fromAppScreen && mounted) {
        Future.delayed(Duration(milliseconds: 500), () {
          _startPermissionEducation();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<bool> _checkPhotoPermission() async {
    try {
      if (Platform.isIOS) {
        var status = await Permission.photos.status;
        // iOS端也要求完全授权，不接受受限权限
        return status.isGranted;
      } else if (Platform.isAndroid) {
        var storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      }
      return false;
    } catch (e) {
      print("Error checking photo permission: $e");
      return false;
    }
  }

  Future<void> _checkAllPermissionsStatus() async {
    print("Checking permission status for all permissions...");

    for (var permissionData in _permissions) {
      final permission = permissionData['permission'] as Permission;

      if (permission == Permission.photos || permission == Permission.storage) {
        final isPhotoGranted = await _checkPhotoPermission();
        _permissionsGranted[permission] = isPhotoGranted;
      } else {
        final status = await permission.status;
        _permissionsGranted[permission] = status.isGranted;
      }
    }

    if (widget.fromAppScreen && mounted) {
      setState(() {});
    }
  }

  void _savePermissionsRequested() {
    try {
      Hive.box('userdata').put('permissions_requested', true);
      print("Successfully saved permissions_requested flag to Hive");
    } catch (e) {
      print("Error saving permissions_requested flag: $e");
    }
  }

  void _navigateToLogin() {
    var box = Hive.box(userdata);
    final bool hasAuthToken = box.get(authToken) != null;
    final bool hasLastName =
        box.get(lastName) != null && box.get(lastName)!.isNotEmpty;
    final bool hasFirstName =
        box.get(firstName) != null && box.get(firstName)!.isNotEmpty;

    if (hasAuthToken && hasLastName && hasFirstName) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TabbarScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Flogin()),
        (route) => false,
      );
    }
  }

  void _startPermissionEducation() {
    setState(() {
      _showPermissionEducation = true;
    });
  }

  Future<void> _startPermissionFlow() async {
    setState(() {
      _permissionFlowStarted = true;
      _showPermissionEducation = false;
    });

    // Request permissions one by one with smooth transitions
    for (int i = 0; i < _permissions.length; i++) {
      setState(() {
        _currentPermissionIndex = i;
      });

      final permissionData = _permissions[i];
      final permission = permissionData['permission'] as Permission;

      // Check if already granted
      final status = await permission.status;
      if (status.isGranted) {
        _permissionsGranted[permission] = true;
        continue;
      }

      // Special handling for photo/storage permissions
      if ((permission == Permission.photos && Platform.isIOS) || 
          (permission == Permission.storage && Platform.isAndroid)) {
        final isPhotoGranted = await _checkPhotoPermission();
        if (isPhotoGranted) {
          _permissionsGranted[permission] = true;
          continue;
        }

        final newStatus = await permission.request();
        final newIsGranted = await _checkPhotoPermission();
        _permissionsGranted[permission] = newIsGranted;
      } else {
        // Standard permission request
        try {
          final newStatus = await permission.request();
          _permissionsGranted[permission] = newStatus.isGranted;
        } catch (e) {
          print("Error requesting ${permission.toString()}: $e");
          _permissionsGranted[permission] = false;
        }
      }

      // Brief pause between permissions for smooth UX
      if (i < _permissions.length - 1) {
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    _savePermissionsRequested();

    // Show completion animation before navigating
    await Future.delayed(Duration(milliseconds: 500));
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final bool isSmallScreen = screenWidth < 360;
    final bool isLargeScreen = screenWidth > 600;

    final double logoSize =
        isSmallScreen ? 90.0 : (isLargeScreen ? 150.0 : 120.0);
    final double iconSize =
        isSmallScreen ? 45.0 : (isLargeScreen ? 70.0 : 60.0);
    final double titleFontSize =
        isSmallScreen ? 30.0 : (isLargeScreen ? 46.0 : 38.0);
    final double descFontSize =
        isSmallScreen ? 16.0 : (isLargeScreen ? 22.0 : 19.0);
    final double buttonWidth =
        screenWidth * 0.75 > 290 ? 290 : screenWidth * 0.75;
    final double buttonHeight =
        isSmallScreen ? 50.0 : (isLargeScreen ? 70.0 : 60.0);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [_fadeController, _slideController, _scaleController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color(0xFFF7F5FF),
                      Color(0xFFF0ECFF),
                      Color(0xFFE8E2FF),
                    ],
                  ),
                ),
              ),

              // Floating particles animation
              ...List.generate(
                  6,
                  (index) =>
                      _buildFloatingParticle(index, screenWidth, screenHeight)),

              // Main content with fixed layout
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        final contentHeight = availableHeight -
                            120; // Reserve space for bottom button

                        return Column(
                          children: [
                            // Fixed height content area with internal scrolling
                            Container(
                              height: contentHeight,
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.06),
                                child: Column(
                                  children: [
                                    // Top spacer
                                    SizedBox(height: screenHeight * 0.02),

                                    // Header with improved styling
                                    _buildHeader(isSmallScreen, isLargeScreen),

                                    // Spacer
                                    SizedBox(height: screenHeight * 0.03),

                                    // App logo with scale animation
                                    ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: _buildAppLogo(logoSize, iconSize),
                                    ),

                                    // Spacer
                                    SizedBox(height: screenHeight * 0.03),

                                    // App info - more compact
                                    _buildAppInfo(titleFontSize, descFontSize,
                                        screenWidth),

                                    // Spacer
                                    SizedBox(height: screenHeight * 0.03),

                                    // Permission preview cards or progress
                                    if (!_showPermissionEducation &&
                                        !_permissionFlowStarted)
                                      _buildPermissionPreview(
                                          screenWidth, isSmallScreen)
                                    else if (_permissionFlowStarted)
                                      _buildPermissionProgress(
                                          screenWidth, isSmallScreen),

                                    // Bottom spacer to ensure button area is preserved
                                    SizedBox(height: screenHeight * 0.02),
                                  ],
                                ),
                              ),
                            ),

                            // Fixed bottom action area
                            Container(
                              height: 120,
                              child: _buildBottomAction(buttonWidth,
                                  buttonHeight, isSmallScreen, isLargeScreen),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Permission education overlay
              if (_showPermissionEducation)
                _buildPermissionEducationOverlay(
                    screenWidth, screenHeight, isSmallScreen),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(
      int index, double screenWidth, double screenHeight) {
    final double size = 20 + (index * 10).toDouble();
    final double left = (index * 0.2 * screenWidth) % screenWidth;
    final double top = (index * 0.15 * screenHeight) % screenHeight;

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              -20 * _fadeController.value * (1 + index * 0.3),
            ),
            child: Opacity(
              opacity: 0.1 * _fadeAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: chatownColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: chatownColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 40 : 50,
            height: isSmallScreen ? 40 : 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, chatownColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: isSmallScreen ? 20 : 26,
            ),
          ),
          SizedBox(width: 12),
          Text(
            languageController.textTranslate("App Permissions"),
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo(double logoSize, double iconSize) {
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF2EEFB),
            Color(0xFFE8E2FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(logoSize * 0.3),
        boxShadow: [
          BoxShadow(
            color: chatownColor.withOpacity(0.3),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.chat_bubble_outline,
          color: chatownColor,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildAppInfo(
      double titleFontSize, double descFontSize, double screenWidth) {
    return Column(
      children: [
        Text(
          'Whoxa',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize * 0.9, // Slightly smaller for better fit
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            children: [
              Text(
                languageController.textTranslate(
                    "Connect, share, and chat with friends and family"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: descFontSize * 0.9, // Slightly smaller
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                languageController
                    .textTranslate("Secure messaging with enhanced privacy"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (descFontSize - 2) * 0.9,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionPreview(double screenWidth, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chatownColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            languageController.textTranslate("We'll request permissions for:"),
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _permissions
                .take(4)
                .map((perm) => _buildPermissionChip(perm, isSmallScreen))
                .toList(),
          ),
          if (_permissions.length > 4) ...[
            SizedBox(height: 8),
            Text(
              "+${_permissions.length - 4} more",
              style: TextStyle(
                fontSize: 14,
                color: chatownColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionChip(
      Map<String, dynamic> permission, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (permission['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: (permission['color'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            permission['icon'],
            size: isSmallScreen ? 16 : 18,
            color: permission['color'],
          ),
          SizedBox(width: 6),
          Text(
            permission['title'],
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionProgress(double screenWidth, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: chatownColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            languageController.textTranslate("Setting up permissions..."),
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentPermissionIndex + 1) / _permissions.length,
            backgroundColor: chatownColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(chatownColor),
          ),
          SizedBox(height: 12),
          Text(
            "${_currentPermissionIndex + 1} of ${_permissions.length}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(double buttonWidth, double buttonHeight,
      bool isSmallScreen, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_permissionFlowStarted) ...[
            GestureDetector(
              onTap: () {
                if (!_continuePressed) {
                  setState(() {
                    _continuePressed = true;
                  });
                  _startPermissionEducation();
                }
              },
              child: Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [secondaryColor, chatownColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                  boxShadow: [
                    BoxShadow(
                      color: chatownColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    languageController.textTranslate("Get Started"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : (isLargeScreen ? 20 : 18),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              languageController.textTranslate("Secure • Private • Fast"),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
          ] else ...[
            Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(buttonHeight / 2),
                border: Border.all(color: chatownColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(chatownColor),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      languageController.textTranslate("Configuring..."),
                      style: TextStyle(
                        color: chatownColor,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionEducationOverlay(
      double screenWidth, double screenHeight, bool isSmallScreen) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85, // Limit height to 85% of screen
              maxWidth: screenWidth - 40,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header section - fixed
                Container(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [secondaryColor, chatownColor],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        languageController.textTranslate("Quick Setup"),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        languageController.textTranslate(
                            "We'll ask for permissions to enable core features. You can change these anytime in Settings."),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content area for permissions
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        // Permission benefits list - show only first 4 to prevent overflow
                        ...(_permissions.take(4).map((perm) =>
                            _buildPermissionBenefit(perm, isSmallScreen))),
                        if (_permissions.length > 4)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              languageController.textTranslate(
                                  "+ ${_permissions.length - 4} more features"),
                              style: TextStyle(
                                fontSize: 14,
                                color: chatownColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Footer section - fixed
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Main action button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startPermissionFlow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: chatownColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              languageController
                                  .textTranslate("Continue Setup"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Skip option is hide due to appstore reject
                        /*  TextButton(
                          onPressed: () {
                            setState(() {
                              _showPermissionEducation = false;
                            });
                            // Handle skip by going directly to login
                            _handleSkipPermissions();
                          },
                          child: Text(
                            languageController.textTranslate("Skip for now"),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ), */
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionBenefit(
      Map<String, dynamic> permission, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (permission['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              permission['icon'],
              color: permission['color'],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission['title'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  permission['benefit'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
