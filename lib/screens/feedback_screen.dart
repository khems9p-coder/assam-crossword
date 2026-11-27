import 'package:material_ui/material_ui.dart';

import '../services/contact_service.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const List<String> _categories = [
    'Bug report',
    'Incorrect answer',
    'Suggestion',
    'General feedback',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _message = TextEditingController();
  String _category = 'General feedback';
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    setState(() => _sending = true);

    final FeedbackOutcome outcome = await FeedbackService.instance.submit(
      name: _name.text,
      email: _email.text,
      category: _category,
      message: _message.text,
    );

    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    _message.clear();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          outcome == FeedbackOutcome.sent
              ? Icons.check_circle_rounded
              : Icons.schedule_send_rounded,
          color: AppColors.forestGreen,
          size: 48,
        ),
        title: Text(
          outcome == FeedbackOutcome.sent ? 'Thank you!' : 'Saved',
        ),
        content: Text(
          outcome == FeedbackOutcome.sent
              ? 'Your feedback has been sent to ${AppConstants.developer}.'
              : "You're offline right now. Your feedback is saved on this "
                  'device and will be sent automatically when you are back '
                  'online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// The old way: write the same message in the email app instead.
  Future<void> _sendByEmail() async {
    final String body = 'Name: ${_name.text.trim()}\n'
        'Email: ${_email.text.trim()}\n'
        'Category: $_category\n\n'
        '${_message.text.trim()}\n\n'
        'Sent from ${AppConstants.appName} ${AppConstants.appVersion}';
    final bool opened = await ContactService.openEmail(
      subject: '${AppConstants.appName} feedback: $_category',
      body: body,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't open an email app. Please write to "
            '${AppConstants.contactEmail}.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Found a mistake or have an idea? Tell us below.',
                    style: TextStyle(fontSize: 15, color: AppColors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Your email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final String text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(text)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline_rounded),
                    ),
                    items: [
                      for (final String category in _categories)
                        DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _message,
                    minLines: 5,
                    maxLines: 10,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 10) {
                        return 'Please write a message (at least 10 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _sending ? null : _submit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send Feedback'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _sendByEmail,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Or send it by email instead'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feedback goes straight to ${AppConstants.developer}. '
                    'If you are offline, it is saved and sent later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
