import 'package:assamcrossword/services/feedback_service.dart';
import 'package:assamcrossword/services/local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
  });

  test('feedback is kept on the device when it cannot be sent', () async {
    // Firebase is not running in tests, so the message must wait.
    final FeedbackOutcome outcome = await FeedbackService.instance.submit(
      name: '  Test  ',
      email: 'a@b.c',
      category: 'Suggestion',
      message: 'x' * 2500,
    );
    expect(outcome, FeedbackOutcome.queued);
    final List<Map<String, dynamic>> waiting =
        FeedbackService.instance.pending;
    expect(waiting, hasLength(1));
    expect(waiting.first['name'], 'Test');
    expect((waiting.first['message'] as String).length, 2000);
    expect(waiting.first['id'], isA<String>());
  });
}
