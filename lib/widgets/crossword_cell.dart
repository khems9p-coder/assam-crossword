import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class CrosswordCell extends StatelessWidget {
  final double size;
  final bool isBlock;
  final bool isSelected;
  final bool inActiveWord;
  final bool isWrong;
  final bool isRevealed;
  final String letter;
  final int? number;
  final VoidCallback? onTap;

  const CrosswordCell({
    super.key,
    required this.size,
    this.isBlock = false,
    this.isSelected = false,
    this.inActiveWord = false,
    this.isWrong = false,
    this.isRevealed = false,
    this.letter = '',
    this.number,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlock) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.forestGreen.withValues(alpha: 0.9),
          border: Border.all(color: AppColors.forestGreen, width: 0.5),
        ),
      );
    }

    Color background = Colors.white;
    if (inActiveWord) {
      background = AppColors.gold.withValues(alpha: 0.25);
    }
    if (isWrong) {
      background = Colors.red.withValues(alpha: 0.15);
    }
    if (isSelected) {
      background = AppColors.gold.withValues(alpha: 0.75);
    }

    final Color textColor = isWrong
        ? Colors.red.shade700
        : (isRevealed ? Colors.blueGrey : Colors.black87);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: Colors.black38, width: 0.5),
        ),
        child: Stack(
          children: [
            if (number != null)
              Positioned(
                left: 2,
                top: 1,
                child: Text(
                  '$number',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: size * 0.24,
                    height: 1,
                    color: Colors.black54,
                  ),
                ),
              ),
            Center(
              child: Text(
                letter,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontSize: size * 0.55,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
