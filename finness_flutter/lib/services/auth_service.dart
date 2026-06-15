import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import 'firebase_service.dart';
import 'seed_service.dart';

export '../models/models.dart' show UserProfile;

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseService? firebaseService,
    SeedService? seedService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firebase = firebaseService ?? FirebaseService.instance,
       _seed = seedService ?? SeedService();

  final FirebaseAuth _auth;
  final FirebaseService _firebase;
  final SeedService _seed;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserProfile?> get currentProfile async {
    final user = currentUser;
    if (user == null) return null;
    return loadProfile(user);
  }

  Future<UserCredential> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    _afterAuthenticatedInBackground(credential.user);
    return credential;
  }

  Future<UserCredential> register(
    String email,
    String password, {
    String? name,
    String? gender,
    String? dob,
    double? height,
    double? weight,
    List<EquipmentId>? equipment,
    String? photo,
    FitnessGoal? goal,
  }) async {
    final cleanedEmail = email.trim();
    final displayName = (name == null || name.trim().isEmpty)
        ? _nameFromEmail(cleanedEmail)
        : name.trim();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanedEmail,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);

    final profile = UserProfile(
      uid: credential.user?.uid ?? '',
      name: displayName,
      email: cleanedEmail,
      gender: gender ?? 'Female',
      dob: dob,
      height: height ?? 165,
      weight: weight ?? 58,
      equipment: equipment,
      photo: photo,
      goal: goal ?? fitnessGoalMaintain,
    );

    await _firebase.setValue(
      'finnness/users/${profile.uid}/profile',
      profile.toJson(),
    );
    await _seedSafely(credential.user);
    _flushPendingInBackground();
    return credential;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() {
    return _auth.signOut();
  }

  Future<UserProfile?> refreshProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return loadProfile(user);
  }

  Future<void> saveProfile(Map<String, Object?> profile) async {
    final user = currentUser;
    if (user == null) return;

    final name = profile['name']?.toString().trim();
    if (name != null && name.isNotEmpty && user.displayName != name) {
      await user.updateDisplayName(name);
    }

    await _firebase.saveProfile(user.uid, profile);
  }

  Future<UserProfile> loadProfile(User user) async {
    final stored = await _firebase.fetchProfile(user.uid);
    if (stored != null) return stored;

    return UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? _nameFromEmail(user.email ?? ''),
    );
  }

  Future<void> handleAuthState(User? user) async {
    if (user == null) return;
    _afterAuthenticatedInBackground(user);
  }

  void _afterAuthenticatedInBackground(User? user) {
    if (user == null) return;
    unawaited(_seedSafely(user));
    _flushPendingInBackground();
  }

  Future<void> _seedSafely(User? user) async {
    if (user == null) return;
    try {
      await _seed.seedUserIfEmpty(user.uid).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Seed data should never block login.
    }
  }

  void _flushPendingInBackground() {
    unawaited(
      _firebase
          .flushPending()
          .timeout(const Duration(seconds: 8))
          .catchError((_) => 0),
    );
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    return email.split('@').first;
  }
}

final authService = AuthService();
