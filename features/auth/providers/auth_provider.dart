// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  
  // ✅ Add these getters
  String? get userEmail => _user?.email;
  String? get userId => _user?.id;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _user = Supabase.instance.client.auth.currentUser;
  }

  // Email/Password Sign Up
  Future<bool> signUp(String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        Navigator.pushReplacementNamed(context, '/onboarding');
        return true;
      } else {
        _errorMessage = 'Sign up failed: no user returned';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Email/Password Sign In
Future<bool> signIn(String email, String password, BuildContext context) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      _user = response.user;
      // ✅ Clear all previous routes (welcome, login)
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return true;
    } else {
      _errorMessage = 'Sign in failed: no user returned';
      return false;
    }
  } catch (e) {
    _errorMessage = e.toString();
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Google Sign-In
Future<bool> signInWithGoogle(BuildContext context) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User canceled sign-in
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Check if we got an idToken
    if (googleAuth.idToken == null) {
      _errorMessage = 'Google Sign-In failed: No ID token received.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final response = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    if (response.user != null) {
      _user = response.user;
      Navigator.pushReplacementNamed(context, '/home');
      return true;
    } else {
      _errorMessage = 'Google sign-in failed: no user returned';
      return false;
    }
  } catch (e) {
    _errorMessage = e.toString();
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Sign Out
  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signOut();
      await GoogleSignIn().signOut();
      _user = null;
      Navigator.pushReplacementNamed(context, '/welcome');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}