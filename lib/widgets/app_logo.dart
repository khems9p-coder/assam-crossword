import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogo({
    super.key,
    this.size = 120,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.brand,
        borderRadius: BorderRadius.circular(size * 0.23),
      ),
      child: Icon(
        Icons.grid_on_rounded,
        size: size * 0.6,
        color: iconColor ?? AppColors.gold,
      ),
    );
  }
}
