/// Work that runs while the splash screen is showing.
///
/// main() starts the slower jobs (questions, Firebase) here and shows the
/// app straight away. The splash screen waits for [ready] before it moves
/// on, so every screen after it still finds everything loaded.
class Startup {
  Startup._();

  static Future<void>? _job;

  /// Called once from main() with the background work.
  static void begin(Future<void> job) => _job = job;

  /// Finishes when the background start-up work is done. It never fails:
  /// each job handles its own errors, so the app opens either way.
  /// When nothing was started (as in tests), it is ready at once.
  static Future<void> get ready => _job ?? Future<void>.value();
}
