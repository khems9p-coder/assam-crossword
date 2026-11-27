import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/form_message.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await AuthService.instance.sendPasswordReset(_email.text);
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _isError = false;
        _message = 'If an account exists for ${_email.text.trim()}, a '
            'password reset link has been sent. Check your inbox and spam '
            'folder.';
      });
    } on AuthFailure catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _isError = true;
        _message = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? message = _message;

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
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
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 64,
                    color: AppColors.forestGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the email you registered with. We will send you a '
                    'link to choose a new password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.email,
                  ),
                  if (message != null) FormMessage(message, isError: _isError),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Send Reset Link'),
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
