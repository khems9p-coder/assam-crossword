import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/achievement.dart';
import '../services/score_service.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

/// What the player chose after finishing a puzzle.
enum FinishChoice { dashboard, replay, next }

/// The "Puzzle complete!" screen: confetti, stars, time and points.
class CelebrationDialog extends StatefulWidget {
  final String title;
  final GameResult result;

  const CelebrationDialog({
    super.key,
    required this.title,
    required this.result,
  });

  /// Shows the dialog and returns the player's choice.
  static Future<FinishChoice?> show(
    BuildContext context, {
    required String title,
    required GameResult result,
  }) {
    return showDialog<FinishChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CelebrationDialog(title: title, result: result),
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final math.Random random = math.Random();
    _pieces = List<_Piece>.generate(70, (_) => _Piece.random(random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameResult result = widget.result;

    String timeLine = 'Time: ${Helpers.formatDuration(result.seconds)}';
    if (!result.countsForBestTime) {
      timeLine += '\n(A word was revealed, so this time is not a record.)';
    } else if (!result.isNewBest && result.previousBest != null) {
      timeLine +=
          '\nBest time: ${Helpers.formatDuration(result.previousBest)}';
    }

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.gold,
                    size: 56,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Puzzle complete!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.title, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 3; i++)
                        Icon(
                          i < result.stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.gold,
                          size: 44,
                        ),
                    ],
                  ),
                  if (result.isNewBest) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'New best time!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(timeLine, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(
                    '+${result.points} points',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  if (result.dailyStreak != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '🔥 Daily streak: ${result.dailyStreak} '
                      '${result.dailyStreak == 1 ? 'day' : 'days'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                  for (final Achievement badge in result.newAchievements)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badge.icon, color: AppColors.forestGreen),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'New badge: ${badge.title}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (result.isDaily)
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(FinishChoice.dashboard),
                      child: const Text('Done'),
                    )
                  else
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(FinishChoice.next),
                      child: const Text('Next Puzzle'),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(FinishChoice.replay),
                          child: const Text('Replay'),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context)
                              .pop(FinishChoice.dashboard),
                          child: const Text('Dashboard'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _ConfettiPainter(_pieces, _controller.value),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One piece of confetti.
class _Piece {
  final double x;
  final double delay;
  final double speed;
  final double drift;
  final double spin;
  final double size;
  final Color color;

  const _Piece(
    this.x,
    this.delay,
    this.speed,
    this.drift,
    this.spin,
    this.size,
    this.color,
  );

  static const List<Color> _colors = [
    AppColors.gold,
    AppColors.forestGreen,
    Colors.redAccent,
    Colors.lightBlue,
    Colors.orange,
    Colors.purpleAccent,
  ];

  factory _Piece.random(math.Random r) => _Piece(
        r.nextDouble(),
        r.nextDouble() * 0.35,
        0.8 + r.nextDouble() * 0.6,
        (r.nextDouble() - 0.5) * 0.3,
        r.nextDouble() * 12,
        5 + r.nextDouble() * 6,
        _colors[r.nextInt(_colors.length)],
      );
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double progress;

  _ConfettiPainter(this.pieces, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) {
      return;
    }
    final Paint paint = Paint();
    for (final _Piece p in pieces) {
      final double t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) {
        continue;
      }
      final double dx = (p.x + p.drift * t) * size.width;
      final double dy = -20 + t * p.speed * (size.height + 40);
      paint.color = p.color.withValues(alpha: 1 - t * 0.6);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * t);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
