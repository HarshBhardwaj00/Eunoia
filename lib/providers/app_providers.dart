import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../services/auth_service.dart';
import '../services/journal_repository.dart';
import '../services/recommendation_engine.dart';
import '../services/cbt_offline_storage_service.dart';
import '../data/models/mood_log_model.dart';
import '../data/models/post_model.dart';
import '../data/models/user_model.dart';
import '../repositories/cbt_repository.dart';
import '../repositories/community_repository.dart';
import '../repositories/user_repository.dart';
import '../theme/premium_design_system.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// User profile data model
class UserProfile {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;
  final bool isAnonymous;
  final bool isEmailVerified;

  UserProfile({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.creationTime,
    this.lastSignInTime,
    this.isAnonymous = false,
    this.isEmailVerified = false,
  });

  factory UserProfile.fromFirebaseUser(User? user) {
    if (user == null) {
      return UserProfile();
    }
    return UserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      isAnonymous: user.isAnonymous,
      isEmailVerified: user.emailVerified,
    );
  }
}

/// StateNotifier for user profile that watches Firebase auth state
class UserProfileNotifier extends StateNotifier<UserProfile> {
  final FirebaseAuth _auth;

  UserProfileNotifier(this._auth) : super(UserProfile()) {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _auth.authStateChanges().listen((user) {
      state = UserProfile.fromFirebaseUser(user);
    });
  }

  Future<void> refresh() async {
    state = UserProfile.fromFirebaseUser(_auth.currentUser);
  }
}

/// Provider for user profile state (observable)
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
      return UserProfileNotifier(FirebaseAuth.instance);
    });

/// Provider for JournalRepository
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(FirebaseFirestore.instance);
});

/// StateNotifier for journal repository to trigger UI updates
class JournalRepositoryNotifier extends StateNotifier<List<MoodLog>> {
  final JournalRepository _repository;

  JournalRepositoryNotifier(this._repository) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _repository.initialize();
    state = _repository.getLocalMoodLogs();
  }

  Future<void> refresh() async {
    await _repository.initialize();
    state = _repository.getLocalMoodLogs();
  }

  Future<void> deleteMoodLog(String id) async {
    await _repository.deleteMoodLog(id);
    state = _repository.getLocalMoodLogs();
  }
}

/// Provider for journal repository state (observable)
final journalRepositoryStateProvider =
    StateNotifierProvider<JournalRepositoryNotifier, List<MoodLog>>((ref) {
      final repository = ref.watch(journalRepositoryProvider);
      return JournalRepositoryNotifier(repository);
    });

/// Provider for RecommendationEngine
final recommendationProvider = Provider<RecommendationEngine>((ref) {
  return RecommendationEngine();
});

/// Provider for CBTOfflineStorageService
final cbtOfflineStorageServiceProvider = Provider<CbtOfflineStorageService>((
  ref,
) {
  return CbtOfflineStorageService.instance;
});

/// Provider for CbtRepository
final cbtRepositoryProvider = Provider<CbtRepository>((ref) {
  final offlineStorage = ref.watch(cbtOfflineStorageServiceProvider);
  return CbtRepository(
    FirebaseFirestore.instance,
    offlineStorage,
    InternetConnectionChecker.createInstance(),
  );
});

/// Provider for CommunityRepository
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(FirebaseFirestore.instance);
});

/// StreamProvider for community feed
final communityFeedProvider = StreamProvider<List<PostModel>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getPublicFeed();
});

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

/// StreamProvider for user profile that watches Firebase auth and streams Firestore data
final userProfileFirestoreProvider = StreamProvider<UserModel?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserProfileStream();
});

/// Provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Dark theme configuration using premium design system
final darkTheme = PremiumDarkTheme.theme;

/// Light theme configuration using premium design system
final lightTheme = PremiumLightTheme.theme;
