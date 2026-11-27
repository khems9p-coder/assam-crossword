import 'package:material_ui/material_ui.dart';

import '../data/legal_text.dart';
import '../theme/app_theme.dart';

/// Which legal document to show.
enum LegalDoc { privacy, terms }

/// Shows the Privacy Policy or the Terms and Conditions.
class LegalScreen extends StatelessWidget {
  final LegalDoc doc;

  const LegalScreen({super.key, required this.doc});

  String get _title =>
      doc == LegalDoc.privacy ? 'Privacy Policy' : 'Terms and Conditions';

  @override
  Widget build(BuildContext context) {
    final LegalText? ready = LegalText.cached;
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: ready != null
          ? _body(ready)
          : FutureBuilder<LegalText>(
              future: LegalText.load(),
              builder: (context, snapshot) {
                final LegalText? text = snapshot.data;
                if (text != null) {
                  return _body(text);
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not open this page.'),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  Widget _body(LegalText text) {
    final LegalDocument document =
        doc == LegalDoc.privacy ? text.privacy : text.terms;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: ${text.updated}',
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                ),
                const SizedBox(height: 16),
                Text(document.intro, style: const TextStyle(fontSize: 15)),
                for (final LegalSection section in document.sections) ...[
                  const SizedBox(height: 20),
                  Text(
                    section.heading,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  for (final String paragraph in section.paragraphs)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        paragraph,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
