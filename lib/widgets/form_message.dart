import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A red (error) or green (success) message box for forms.
class FormMessage extends StatelessWidget {
  final String text;
  final bool isError;

  const FormMessage(this.text, {super.key, this.isError = true});

  @override
  Widget build(BuildContext context) {
    final Color color = isError ? Colors.red.shade700 : AppColors.forestGreen;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
