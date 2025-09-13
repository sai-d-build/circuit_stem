// lib/application/services/cloud_storage_service.dart
// Cloud Storage Service for Firebase Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../presentation/state/hud_state.dart';

abstract class CloudStorageService {
  /// Upload user progress to cloud
  Future<void> uploadProgress(
      String userId, ProgressData progress, String levelId);

  /// Download user progress from cloud
  Future<ProgressData?> downloadProgress(String userId, String levelId);

  /// Sync all progress for a user
  Future<void> syncAllProgress(String userId);

  /// Upload user preferences
  Future<void> uploadPreferences(String userId, UserPreferences preferences);

  /// Download user preferences
  Future<UserPreferences?> downloadPreferences(String userId);

  /// Upload user statistics
  Future<void> uploadStats(String userId, UserStats stats);

  /// Download user statistics
  Future<UserStats?> downloadStats(String userId);

  /// Check if user has cloud data
  Future<bool> hasCloudData(String userId);

  /// Delete all cloud data for user
  Future<void> deleteUserData(String userId);

  /// Get sync status
  Future<SyncStatus> getSyncStatus(String userId);

  /// Resolve conflicts between local and cloud data
  Future<SyncResult> resolveConflicts(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
    ConflictResolutionStrategy strategy,
  );
}

// Firebase Implementation
class FirebaseCloudStorageService implements CloudStorageService {
  final FirebaseFirestore _firestore;

  FirebaseCloudStorageService(this._firestore);

  @override
  Future<void> uploadProgress(
      String userId, ProgressData progress, String levelId) async {
    try {
      final progressData = {
        'currentScore': progress.currentScore,
        'bestScore': progress.bestScore,
        'starsEarned': progress.starsEarned,
        'totalStars': progress.totalStars,
        'hintsUsed': progress.hintsUsed,
        'totalHints': progress.totalHints,
        'elapsedTimeInSeconds': progress.elapsedTime.inSeconds,
        'isComplete': progress.isComplete,
        'lastPlayed': FieldValue.serverTimestamp(),
        'version': 1,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(levelId)
          .set(progressData, SetOptions(merge: true));

      // Update user's last sync timestamp
      await _updateLastSync(userId);
    } catch (e) {
      throw CloudStorageException('Failed to upload progress: $e');
    }
  }

  @override
  Future<ProgressData?> downloadProgress(String userId, String levelId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(levelId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return ProgressData(
        levelId: levelId, // Add required levelId parameter
        currentScore: data['currentScore'] ?? 0,
        bestScore: data['bestScore'] ?? 0,
        starsEarned: data['starsEarned'] ?? 0,
        totalStars: data['totalStars'] ?? 3,
        hintsUsed: data['hintsUsed'] ?? 0,
        totalHints: data['totalHints'] ?? 0,
        elapsedTime: Duration(seconds: data['elapsedTimeInSeconds'] ?? 0),
        isComplete: data['isComplete'] ?? false,
      );
    } catch (e) {
      throw CloudStorageException('Failed to download progress: $e');
    }
  }

  @override
  Future<void> syncAllProgress(String userId) async {
    try {
      // final progressCollection = await _firestore
      //     .collection('users')
      //     .doc(userId)
      //     .collection('progress')
      //     .get();

      // This would typically be handled by the calling code
      // to merge local and cloud data
      await _updateLastSync(userId);
    } catch (e) {
      throw CloudStorageException('Failed to sync progress: $e');
    }
  }

  @override
  Future<void> uploadPreferences(
      String userId, UserPreferences preferences) async {
    try {
      final prefsData = {
        'soundEnabled': preferences.soundEnabled,
        'musicVolume': preferences.musicVolume,
        'soundVolume': preferences.soundVolume,
        'theme': preferences.theme,
        'language': preferences.language,
        'hapticFeedback': preferences.hapticFeedback,
        'showHints': preferences.showHints,
        'developerMode': preferences.developerMode,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set({'preferences': prefsData}, SetOptions(merge: true));

      await _updateLastSync(userId);
    } catch (e) {
      throw CloudStorageException('Failed to upload preferences: $e');
    }
  }

  @override
  Future<UserPreferences?> downloadPreferences(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final prefs = data['preferences'] as Map<String, dynamic>?;

      if (prefs == null) return null;

      return UserPreferences(
        soundEnabled: prefs['soundEnabled'] ?? true,
        musicVolume: prefs['musicVolume'] ?? 0.5,
        soundVolume: prefs['soundVolume'] ?? 1.0,
        theme: prefs['theme'],
        language: prefs['language'],
        hapticFeedback: prefs['hapticFeedback'] ?? false,
        showHints: prefs['showHints'] ?? true,
        developerMode: prefs['developerMode'] ?? false,
      );
    } catch (e) {
      throw CloudStorageException('Failed to download preferences: $e');
    }
  }

  @override
  Future<void> uploadStats(String userId, UserStats stats) async {
    try {
      final statsData = {
        'levelsCompleted': stats.levelsCompleted,
        'totalScore': stats.totalScore,
        'totalPlayTime': stats.totalPlayTime,
        'currentStreak': stats.currentStreak,
        'longestStreak': stats.longestStreak,
        'achievements': stats.achievements,
        'unlockedComponents': stats.unlockedComponents,
        'firstPlayDate': stats.firstPlayDate?.toIso8601String(),
        'lastPlayDate': stats.lastPlayDate?.toIso8601String(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set({'stats': statsData}, SetOptions(merge: true));

      await _updateLastSync(userId);
    } catch (e) {
      throw CloudStorageException('Failed to upload stats: $e');
    }
  }

  @override
  Future<UserStats?> downloadStats(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final stats = data['stats'] as Map<String, dynamic>?;

      if (stats == null) return null;

      return UserStats(
        levelsCompleted: stats['levelsCompleted'] ?? 0,
        totalScore: stats['totalScore'] ?? 0,
        totalPlayTime: stats['totalPlayTime'] ?? 0,
        currentStreak: stats['currentStreak'] ?? 0,
        longestStreak: stats['longestStreak'] ?? 0,
        achievements: List<String>.from(stats['achievements'] ?? []),
        unlockedComponents:
            List<String>.from(stats['unlockedComponents'] ?? []),
        firstPlayDate: stats['firstPlayDate'] != null
            ? DateTime.parse(stats['firstPlayDate'])
            : null,
        lastPlayDate: stats['lastPlayDate'] != null
            ? DateTime.parse(stats['lastPlayDate'])
            : null,
      );
    } catch (e) {
      throw CloudStorageException('Failed to download stats: $e');
    }
  }

  @override
  Future<bool> hasCloudData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists && doc.data() != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete all subcollections
      final progressCollection = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .get();

      for (final doc in progressCollection.docs) {
        await doc.reference.delete();
      }

      // Delete main document
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw CloudStorageException('Failed to delete user data: $e');
    }
  }

  @override
  Future<SyncStatus> getSyncStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return SyncStatus.noData;

      final data = doc.data()!;
      final lastSync = data['lastSync'] as Timestamp?;

      if (lastSync == null) return SyncStatus.needsSync;

      final now = DateTime.now();
      final lastSyncDate = lastSync.toDate();
      final hoursSinceSync = now.difference(lastSyncDate).inHours;

      if (hoursSinceSync > 24) return SyncStatus.needsSync;
      return SyncStatus.synced;
    } catch (e) {
      return SyncStatus.error;
    }
  }

  @override
  Future<SyncResult> resolveConflicts(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
    ConflictResolutionStrategy strategy,
  ) async {
    switch (strategy) {
      case ConflictResolutionStrategy.localWins:
        return SyncResult.localApplied;
      case ConflictResolutionStrategy.remoteWins:
        return SyncResult.remoteApplied;
      case ConflictResolutionStrategy.merge:
        // Implement merge logic here
        return SyncResult.merged;
      case ConflictResolutionStrategy.manual:
        return SyncResult.needsManualResolution;
    }
  }

  Future<void> _updateLastSync(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'lastSync': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

// Supporting Classes and Enums

enum SyncStatus {
  synced,
  needsSync,
  noData,
  error,
}

enum SyncResult {
  success,
  localApplied,
  remoteApplied,
  merged,
  needsManualResolution,
  error,
}

enum ConflictResolutionStrategy {
  localWins,
  remoteWins,
  merge,
  manual,
}

class CloudStorageException implements Exception {
  final String message;

  CloudStorageException(this.message);

  @override
  String toString() => 'CloudStorageException: $message';
}
