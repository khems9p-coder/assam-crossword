import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';

class ContactService {
  ContactService._();

  /// Opens the phone's email app with a message to KBX Studios.
  /// Returns false if no email app could be opened.
  static Future<bool> openEmail({
    String subject = '',
    String body = '',
  }) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: AppConstants.contactEmail,
      query: 'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}',
    );
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  /// Opens the phone's share menu with a message about the app.
  /// If sharing is not possible, the message is copied instead.
  /// Returns true if shared, false if copied.
  static Future<bool> shareApp() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: AppConstants.shareMessage,
          subject: AppConstants.appName,
        ),
      );
      return true;
    } catch (_) {
      await Clipboard.setData(
        const ClipboardData(text: AppConstants.shareMessage),
      );
      return false;
    }
  }

  /// Opens the app's page on Google Play so the player can rate it.
  static Future<bool> openStorePage() async {
    try {
      return await launchUrl(
        Uri.parse(AppConstants.playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
