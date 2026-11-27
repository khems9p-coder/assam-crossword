import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class GameKeyboard extends StatelessWidget {
  final ValueChanged<String> onLetter;
  final VoidCallback onBackspace;

  const GameKeyboard({
    super.key,
    required this.onLetter,
    required this.onBackspace,
  });

  static const List<String> _rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.forestGreen.withValues(alpha: 0.08),
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < _rows.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      if (i == 1) const Spacer(),
                      if (i == 2) const Spacer(flex: 3),
                      for (final String letter in _rows[i].split(''))
                        Expanded(
                          flex: 2,
                          child: _Key(
                            label: letter,
                            onTap: () => onLetter(letter),
                          ),
                        ),
                      if (i == 1) const Spacer(),
                      if (i == 2)
                        Expanded(
                          flex: 3,
                          child: _Key(
                            icon: Icons.backspace_outlined,
                            tooltip: 'Backspace',
                            onTap: onBackspace,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback onTap;

  const _Key({this.label, this.icon, this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final IconData? keyIcon = icon;
    final Widget content = keyIcon != null
        ? Icon(keyIcon, size: 22)
        : Text(
            label ?? '',
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          );

    final Widget key = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: AppColors.surface,
        elevation: 1,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(height: 46, child: Center(child: content)),
        ),
      ),
    );

    final String? message = tooltip;
    return message == null ? key : Tooltip(message: message, child: key);
  }
}
