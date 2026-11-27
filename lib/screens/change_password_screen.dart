import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/form_message.dart';
import '../widgets/password_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.instance.changePassword(
        currentPassword: _current.text,
        newPassword: _new.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your password has been changed.')),
      );
      Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
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
                  Text(
                    'For your security, enter your current password first.',
                    style: TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _current,
                    label: 'Current password',
                    textInputAction: TextInputAction.next,
                    validator: Validators.requiredPassword,
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    controller: _new,
                    label: 'New password',
                    helperText: 'At least 8 characters, with letters and numbers',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final String? basic = Validators.newPassword(value);
                      if (basic != null) {
                        return basic;
                      }
                      if (value == _current.text) {
                        return 'Choose a different password from your current one';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    controller: _confirm,
                    label: 'Confirm new password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _new.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  if (error != null) FormMessage(error),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Change Password'),
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
