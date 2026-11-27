import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../game/crossword_engine.dart';
import '../theme/app_theme.dart';
import 'crossword_cell.dart';

/// Draws the crossword at the largest size that fits the space.
class CrosswordGrid extends StatelessWidget {
  final CrosswordEngine engine;

  const CrosswordGrid({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellSize = math
            .min(
              (constraints.maxWidth - 4) / engine.cols,
              (constraints.maxHeight - 4) / engine.rows,
            )
            .clamp(16.0, 64.0)
            .floorToDouble();

        return Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.forestGreen, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int r = 0; r < engine.rows; r++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int c = 0; c < engine.cols; c++)
                        CrosswordCell(
                          size: cellSize,
                          isBlock: engine.isBlock(r, c),
                          isSelected: engine.isSelected(r, c),
                          inActiveWord: engine.isInActiveWord(r, c),
                          isWrong: engine.isWrong(r, c),
                          isRevealed: engine.isRevealed(r, c),
                          letter: engine.isBlock(r, c) ? '' : engine.entryAt(r, c),
                          number: engine.numberAt(r, c),
                          onTap: () => engine.selectCell(r, c),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
