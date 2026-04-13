import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  bool _isLogin = true;

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    bool success;
    if (_isLogin) {
      success = await auth.login(email, password);
    } else {
      if (_fNameController.text.isEmpty || _lNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide first and last name')),
        );
        return;
      }
      success = await auth.register(
        _fNameController.text.trim(),
        _lNameController.text.trim(),
        email,
        password,
      );
    }

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Authentication Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                // Header
                Text(
                  _isLogin ? 'WELCOME BACK' : 'CREATE PROFILE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.5,
                    color: onSurface,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Bordered Input Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: onSurface, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _SketchyField(controller: _fNameController, label: 'FIRST NAME'),
                        const SizedBox(height: 15),
                        _SketchyField(controller: _lNameController, label: 'LAST NAME'),
                        const SizedBox(height: 15),
                      ],
                      _SketchyField(controller: _emailController, label: 'EMAIL'),
                      const SizedBox(height: 15),
                      _SketchyField(
                        controller: _passwordController, 
                        label: 'PASSWORD', 
                        obscure: true
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Dynamic Styled Button
                GestureDetector(
                  onTap: context.watch<AuthProvider>().isLoading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      border: Border.all(color: onSurface, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: context.watch<AuthProvider>().isLoading 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimaryContainer))
                      : Text(
                          _isLogin ? 'LOG IN' : 'SIGN UP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.2,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLogin ? 'NEED AN ACCOUNT?' : 'ALREADY HAVE ONE?',
                    style: TextStyle(color: onSurface.withOpacity(0.6), fontSize: 12),
                  ),
                ),

                if (_isLogin)
                  TextButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter your email first')),
                        );
                        return;
                      }
                      context.read<AuthProvider>().requestPasswordReset(email).then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset email sent!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? 'Error')),
                          );
                        }
                      });
                    },
                    child: Text(
                      'FORGOT PASSWORD?',
                      style: TextStyle(color: onSurface.withOpacity(0.6), fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SketchyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;

  const _SketchyField({
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.5))),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: onSurface),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: onSurface.withOpacity(0.4))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: onSurface, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
