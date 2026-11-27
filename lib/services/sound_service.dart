import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';

/// The game's sound effects (files in assets/sounds/, made by
/// tool/make_sounds.py).
enum Sfx {
  // Movement and UI
  snap('snap.wav'), // a letter clicks into a square
  select('select.wav'), // bubble pop when a square is tapped
  whoosh('whoosh.wav'), // moving to another clue, clearing a word
  shuffle('shuffle.wav'), // restarting the puzzle
  // Correct moves and progress
  ding1('ding1.wav'), // word solved; each word in a row rings higher
  ding2('ding2.wav'),
  ding3('ding3.wav'),
  ding4('ding4.wav'),
  ding5('ding5.wav'),
  sparkle('sparkle.wav'), // hint revealed
  complete('complete.wav'), // puzzle complete
  // Mistakes
  buzzer('buzzer.wav'), // "Check" found wrong letters
  thud('thud.wav'); // a move that is not allowed

  const Sfx(this.file);
  final String file;

  /// The success ding for a combo of [count] words in a row (1 to 5).
  static Sfx ding(int count) =>
      const [ding1, ding2, ding3, ding4, ding5][count.clamp(1, 5) - 1];
}

/// How strong a vibration is.
enum Buzz { light, strong, celebrate }

/// Plays sounds and vibrations, following the Sound effects and
/// Vibration switches in Settings. If sound cannot be played (for
/// example in tests), the game simply stays quiet.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  final Map<Sfx, AudioPlayer> _players = {};
  bool _ready = false;

  /// Loads all sounds. Called once from main().
  Future<void> init() async {
    try {
      for (final Sfx sfx in Sfx.values) {
        final AudioPlayer player = AudioPlayer();
        if (!kIsWeb) {
          await player.setPlayerMode(PlayerMode.lowLatency);
        }
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource('sounds/${sfx.file}'));
        _players[sfx] = player;
      }
      _ready = true;
    } catch (error) {
      debugPrint('Sounds not available: $error');
    }
  }

  void play(Sfx sfx) {
    final AudioPlayer? player = _players[sfx];
    if (!_ready || player == null || !AppState.instance.soundOn) {
      return;
    }
    unawaited(_playFromStart(player, sfx));
  }

  Future<void> _playFromStart(AudioPlayer player, Sfx sfx) async {
    try {
      await player.stop();
      await player.resume();
    } catch (_) {
      try {
        await player.play(AssetSource('sounds/${sfx.file}'));
      } catch (error) {
        debugPrint('Could not play ${sfx.file}: $error');
      }
    }
  }

  void buzz(Buzz kind) {
    if (!_ready || !AppState.instance.vibrationOn) {
      return;
    }
    switch (kind) {
      case Buzz.light:
        unawaited(HapticFeedback.lightImpact());
      case Buzz.strong:
        unawaited(HapticFeedback.heavyImpact());
      case Buzz.celebrate:
        unawaited(HapticFeedback.vibrate());
    }
  }
}
