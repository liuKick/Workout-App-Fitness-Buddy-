// lib/features/auth/screens/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../../widgets/app_textfield.dart';
import '../../../widgets/app_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the terms and conditions'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final success = await authProvider.signUp(email, password, context);

      if (success && mounted) {
        context.read<OnboardingProvider>().resetOnboarding();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please complete your profile.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/quick-setup');
      }
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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sign Up'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/dumbell.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Join',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              children: const [
                                TextSpan(text: 'FITNESS '),  // Changed
                                TextSpan(
                                  text: 'BUDDY',              // Changed
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    
                    Text(
                      'Create Account',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to start your fitness journey',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    AppTextfield(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AppTextfield(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a password';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AppTextfield(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm your password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: secondaryTextColor, fontSize: 13),
                                children: const [
                                  TextSpan(text: 'I agree to the '),
                                  TextSpan(text: 'Terms of Service', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                  TextSpan(text: ' and '),
                                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    AppButton(
                      text: 'SIGN UP',
                      onPressed: _handleSignUp,
                      isLoading: authProvider.isLoading,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[800])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: Colors.grey[600])),
                        ),
                        Expanded(child: Divider(color: Colors.grey[800])),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Image.asset(
                          'assets/images/googleLogo.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.white),
                        ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (authProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: secondaryTextColor)),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('Login', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}