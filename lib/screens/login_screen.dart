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
  bool _obscurePassword = true;

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
      // Note: We'll update the AuthProvider to accept separate names in the next step
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.pets, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(_isLogin ? 'Login' : 'Register', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              if (!_isLogin) ...[
                TextField(controller: _fNameController, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _lNameController, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder())),
                const SizedBox(height: 16),
              ],
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: context.watch<AuthProvider>().isLoading ? null : _submit,
                  child: Text(_isLogin ? 'Login' : 'Register'),
                ),
              ),
              TextButton(onPressed: _toggleMode, child: Text(_isLogin ? 'Create an account' : 'Have an account? Login')),
            ],
          ),
        ),
      ),
    );
  }
}
