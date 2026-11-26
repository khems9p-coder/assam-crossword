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
}
