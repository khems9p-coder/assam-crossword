import '../models/crossword.dart';
import '../models/difficulty.dart';

/// Hand-checked puzzles used to test the engine and the game screen.
/// The full question bank is added in Phase 8.
class SamplePuzzles {
  SamplePuzzles._();

  static const CrosswordPuzzle assamStarter = CrosswordPuzzle(
    id: 'sample_assam_01',
    title: 'Assam Starter',
    topicId: 'assam_wildlife',
    difficulty: Difficulty.easy,
    rows: 5,
    cols: 5,
    words: [
      CrosswordWord(
        answer: 'TEA',
        clue: "Assam's world-famous plantation crop",
        row: 0,
        col: 0,
        direction: ClueDirection.across,
      ),
      CrosswordWord(
        answer: 'TIGER',
        clue: 'Big striped cat protected in Kaziranga',
        row: 0,
        col: 0,
        direction: ClueDirection.down,
      ),
      CrosswordWord(
        answer: 'GAS',
        clue: 'Natural ___: a fuel found in Assam along with petroleum',
        row: 2,
        col: 0,
        direction: ClueDirection.across,
      ),
      CrosswordWord(
        answer: 'SKI',
        clue: 'Glide over snow on long narrow boards',
        row: 2,
        col: 2,
        direction: ClueDirection.down,
      ),
      CrosswordWord(
        answer: 'RHINO',
        clue: 'One-horned animal that is the state animal of Assam',
        row: 4,
        col: 0,
        direction: ClueDirection.across,
      ),
    ],
  );
}
