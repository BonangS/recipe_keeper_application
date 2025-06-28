import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static const String _sessionKey = 'session';
  static const String _lastEmailKey = 'last_email';

  AuthService(this._prefs) {
    _initSession();
  }

  void _initSession() {
    final session = _prefs.getString(_sessionKey);
    if (session != null) {
      try {
        // Coba pulihkan sesi dengan refresh token
        _supabase.auth.setSession(session);
      } catch (e) {
        print('Failed to recover session: $e');
        // Invalid session, remove it
        _prefs.remove(_sessionKey);
      }
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get last used email
  String? get lastEmail => _prefs.getString(_lastEmailKey);

  // Sign Up
  Future<void> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _saveAuthState(true);
        // Simpan email yang terakhir digunakan
        await _prefs.setString(_lastEmailKey, email);
      } else {
        throw 'Pendaftaran gagal. Silakan coba lagi.';
      }
    } catch (e) {
      // Tangani error spesifik
      String errorMessage = e.toString();
      if (errorMessage.contains('unique constraint')) {
        throw 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
      } else if (errorMessage.contains('Invalid email')) {
        throw 'Format email tidak valid. Silakan periksa kembali.';
      } else if (errorMessage.contains('Password should be at least')) {
        throw 'Password terlalu pendek. Minimal 6 karakter.';
      } else {
        throw 'Gagal mendaftar: $errorMessage';
      }
    }
  }

  // Sign In
  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _saveAuthState(true);
        // Simpan email yang terakhir digunakan
        await _prefs.setString(_lastEmailKey, email);
      } else {
        throw 'Login gagal: Email atau password salah';
      }
    } catch (e) {
      // Tangani error spesifik
      String errorMessage = e.toString();
      if (errorMessage.contains('Invalid login credentials')) {
        throw 'Email atau password salah';
      } else if (errorMessage.contains('Email not confirmed')) {
        throw 'Email belum dikonfirmasi. Silakan cek email Anda.';
      } else if (errorMessage.contains('Rate limit')) {
        throw 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
      } else {
        throw 'Gagal login: $errorMessage';
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _saveAuthState(false);
  }

  // Save auth state
  Future<void> _saveAuthState(bool isLoggedIn) async {
    await _prefs.setBool('isLoggedIn', isLoggedIn);
    
    // Simpan session jika login
    if (isLoggedIn) {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        // Simpan token akses atau refresh token untuk recovery session
        await _prefs.setString(_sessionKey, session.refreshToken ?? '');
      }
    } else {
      // Hapus session jika logout
      await _prefs.remove(_sessionKey);
    }
  }
}
