import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:assamcrossword/data/legal_text.dart';
import 'package:assamcrossword/screens/legal_screen.dart';
import 'package:assamcrossword/utils/constants.dart';

void main() {
  testWidgets('privacy policy and terms load and show',
      (WidgetTester tester) async {
    final LegalText? text = await tester.runAsync(() => LegalText.load());
    expect(text, isNotNull);
    expect(text!.privacy.sections.length, greaterThanOrEqualTo(10));
    expect(text.terms.sections.length, greaterThanOrEqualTo(8));

    // The policy explains how to delete an account and how to contact us.
    final String policy = text.privacy.sections
        .expand((LegalSection s) => s.paragraphs)
        .join(' ');
    expect(policy, contains('Delete Account'));
    expect(policy, contains(AppConstants.contactEmail));

    await tester.pumpWidget(
      const MaterialApp(home: LegalScreen(doc: LegalDoc.privacy)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Last updated'), findsOneWidget);
    expect(find.text('1. Playing as a guest'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: LegalScreen(doc: LegalDoc.terms)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Terms and Conditions'), findsWidgets);
  });
}
