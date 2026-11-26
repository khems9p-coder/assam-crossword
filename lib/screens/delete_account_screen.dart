import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/form_message.dart';
import '../widgets/password_field.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  bool _understood = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    if (!_understood) {
      setState(() {
        _error = 'Please tick the box to confirm you understand.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.instance.deleteAccount(_password.text);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account has been deleted. You are now a guest.'),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } on AuthFailure catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? error = _error;
    final Color danger = Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 64, color: danger),
                  const SizedBox(height: 12),
                  const Text(
                    'This permanently deletes your Assam Crossword account '
                    '(${'login, name and email'}) from our servers. '
                    'It cannot be undone. You can still play as a guest.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  PasswordField(
                    controller: _password,
                    label: 'Your password',
                    validator: Validators.requiredPassword,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _understood,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text("I understand this can't be undone"),
                    onChanged: _busy
                        ? null
                        : (value) =>
                            setState(() => _understood = value ?? false),
                  ),
                  if (error != null) FormMessage(error),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: danger,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _busy ? null : _delete,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Delete My Account'),
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
