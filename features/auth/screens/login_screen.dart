// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print('🔐 [LOGIN] Attempting login for: $email');
    
    final success = await authProvider.signIn(email, password, context);

    print('🔐 [LOGIN] Success: $success');
    
    if (success && mounted) {
      print('🔐 [LOGIN] Showing success message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      
      print('🔐 [LOGIN] Navigating to /home');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print('🔐 [LOGIN] Login failed - check auth provider');
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle(context);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google Sign-In failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Guywithdumbell.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      
                      // App Name (changed to FITNESS BUDDY)
                      const Text(
                        'FITNESS BUDDY',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.email, color: Colors.blue.shade300),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.lock, color: Colors.blue.shade300),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.blue.shade300,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blue.shade300),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Error Message
                      if (authProvider.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('LOGIN', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[800])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[800])),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Google Sign-In Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: Image.asset(
                            'assets/images/googleLogo.png',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.g_mobiledata, color: Colors.white),
                          ),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}