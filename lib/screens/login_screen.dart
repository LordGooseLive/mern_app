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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                // Header in the "Sketchy" style
                Text(
                  _isLogin ? 'WELCOME BACK' : 'CREATE PROFILE',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.5,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Bordered Input Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
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

                // Button inside a bordered box (matches sketch)
                GestureDetector(
                  onTap: context.watch<AuthProvider>().isLoading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: context.watch<AuthProvider>().isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          _isLogin ? 'LOG IN' : 'SIGN UP',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLogin ? 'NEED AN ACCOUNT?' : 'ALREADY HAVE ONE?',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
