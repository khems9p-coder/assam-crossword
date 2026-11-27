import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class CrosswordCell extends StatelessWidget {
  final double size;
  final bool isBlock;
  final bool isSelected;
  final bool inActiveWord;
  final bool isWrong;
  final bool isRevealed;
  final bool isSolved;
  final bool isGiven;
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
    this.isSolved = false,
    this.isGiven = false,
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
          color: AppColors.brand.withValues(alpha: 0.9),
          border: Border.all(color: AppColors.brand, width: 0.5),
        ),
      );
    }

    Color background = AppColors.surface;
    if (isGiven) {
      background = AppColors.isDark
          ? Colors.grey.shade700
          : Colors.grey.shade300;
    }
    if (isSolved) {
      background = Colors.green.withValues(alpha: 0.18);
    }
    if (inActiveWord) {
      background = AppColors.gold.withValues(alpha: 0.25);
    }
    if (isWrong) {
      background = Colors.red.withValues(alpha: 0.15);
    }
    if (isSelected) {
      background = AppColors.gold.withValues(alpha: 0.75);
    }

    Color textColor = AppColors.ink;
    if (isRevealed) {
      textColor = Colors.blueGrey;
    }
    if (isSolved) {
      textColor = AppColors.forestGreen;
    }
    if (isWrong) {
      textColor = Colors.red.shade700;
    }

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
