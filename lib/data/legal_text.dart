import 'dart:convert';

import 'package:flutter/services.dart';

/// One heading of a legal document, with its paragraphs.
class LegalSection {
  final String heading;
  final List<String> paragraphs;

  const LegalSection(this.heading, this.paragraphs);
}

/// The Privacy Policy or the Terms and Conditions.
class LegalDocument {
  final String title;
  final String intro;
  final List<LegalSection> sections;

  const LegalDocument(this.title, this.intro, this.sections);

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      json['title'] as String,
      json['intro'] as String,
      [
        for (final Object? raw in json['sections'] as List)
          if (raw is Map)
            LegalSection(
              raw['heading'] as String,
              [
                for (final Object? p in raw['paragraphs'] as List)
                  if (p is String) p,
              ],
            ),
      ],
    );
  }
}

/// The legal texts, read from assets/data/legal.json. The same file is
/// used to make the public web pages (tool/make_legal_pages.py), so the
/// app and the website always say the same thing.
class LegalText {
  final String updated;
  final LegalDocument privacy;
  final LegalDocument terms;

  const LegalText(this.updated, this.privacy, this.terms);

  static const String asset = 'assets/data/legal.json';

  static LegalText? _cached;
  static Future<LegalText>? _loading;

  /// Already loaded, or null.
  static LegalText? get cached => _cached;

  static Future<LegalText> load() {
    return _loading ??= rootBundle.loadString(asset).then((String text) {
      final Map<String, dynamic> json =
          jsonDecode(text) as Map<String, dynamic>;
      final LegalText result = LegalText(
        json['updated'] as String,
        LegalDocument.fromJson(json['privacy'] as Map<String, dynamic>),
        LegalDocument.fromJson(json['terms'] as Map<String, dynamic>),
      );
      _cached = result;
      return result;
    });
  }
}
