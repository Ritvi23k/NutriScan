// =============================================================================
// providers/auth_provider.dart
// =============================================================================
// Mock Google Sign-In authentication provider.
//
// Simulates the Google OAuth flow with a realistic delay and persists
// the "signed in" state using SharedPreferences. Replace with real
// firebase_auth + google_sign_in when ready.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Manages user authentication state (mock Google Sign-In).
///
/// Persists auth state locally so the user stays "signed in" across sessions.
class AuthProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // State Variables
  // ---------------------------------------------------------------------------
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _userName = '';
  String get userName => _userName;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _userInitials = '';
  String get userInitials => _userInitials;

  // Storage keys
  static const String _keySignedIn = 'auth_signed_in';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';

  // ---------------------------------------------------------------------------
  // Initialization — Check persisted auth state
  // ---------------------------------------------------------------------------

  /// Checks if the user was previously signed in.
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isSignedIn = prefs.getBool(_keySignedIn) ?? false;
      _userName = prefs.getString(_keyUserName) ?? '';
      _userEmail = prefs.getString(_keyUserEmail) ?? '';
      _userInitials = _getInitials(_userName);
    } catch (e) {
      _isSignedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Sign In (Mock Google OAuth)
  // ---------------------------------------------------------------------------

  /// Simulates Google Sign-In with a realistic network delay.
  ///
  /// In a real app, replace this with:
  /// ```dart
  /// final googleUser = await GoogleSignIn().signIn();
  /// final googleAuth = await googleUser.authentication;
  /// final credential = GoogleAuthProvider.credential(...);
  /// await FirebaseAuth.instance.signInWithCredential(credential);
  /// ```
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // On Web, use Firebase's native popup, since google_sign_in v7 doesn't support custom buttons.
        final googleProvider = GoogleAuthProvider();
        final userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        
        _userName = userCredential.user?.displayName ?? '';
        _userEmail = userCredential.user?.email ?? '';
        _userInitials = _getInitials(_userName);
        _isSignedIn = true;
      } else {
        // Using GoogleSignIn v7.x API for Android/iOS
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
        
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        _userName = userCredential.user?.displayName ?? '';
        _userEmail = userCredential.user?.email ?? '';
        _userInitials = _getInitials(_userName);
        _isSignedIn = true;
      }

      // Persist auth state.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySignedIn, true);
      await prefs.setString(_keyUserName, _userName);
      await prefs.setString(_keyUserEmail, _userEmail);

      return true;
    } catch (e, stacktrace) {
      debugPrint("Google Sign-In Error: $e\n$stacktrace");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs the user out and clears persisted auth state.
  Future<void> signOut() async {
    _isSignedIn = false;
    _userName = '';
    _userEmail = '';
    _userInitials = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySignedIn);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts initials from a full name (e.g., "Alex Johnson" → "AJ").
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
