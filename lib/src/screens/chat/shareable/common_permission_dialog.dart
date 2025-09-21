import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whoxachat/src/global/global.dart';

class PermissionUtil {
  static void showPermissionSettingsDialog(
      BuildContext context,
      String permissionName,
      Function languageTranslate,
      Color primaryColor,
      Color secondaryColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appColorWhite,
          title: Text(
            "Allow $permissionName Access",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          content: Text(
            "To use this feature, you need to enable $permissionName permissions in settings.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                languageTranslate('Cancel'),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [secondaryColor, primaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: Text(
                  languageTranslate('Open Settings'),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> checkContactPermission() async {
    // Check current permission status
    PermissionStatus status = await Permission.contacts.status;

    // If permission is already granted, return true
    if (status.isGranted) {
      return true;
    }

    // If permission is denied but can be requested, request it
    if (status.isDenied) {
      status = await Permission.contacts.request();
      // Return true if user granted permission after request
      return status.isGranted;
    }

    // If permission is permanently denied or restricted, return false
    // This is when we need to show the settings dialog
    return false;
  }
}
