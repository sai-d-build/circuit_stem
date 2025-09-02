import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../common/cloud_config.dart';
import 'auth_service.dart';
import 'cloud_storage_service.dart';
import '../../domain/entities/user.dart' as domain_user;
import '../../presentation/state/hud_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

// Mock implementations for testing
class MockAuthService implements AuthService {
  @override
  Stream<domain_user.User?> authStateChanges() => Stream.value(null);

  @override
  Future<domain_user.User?> getCurrentUser() async => null;

  @override
  Future<domain_user.User> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    throw UnimplementedError('Mock auth - use real implementation');
  }

  @override
  Future<domain_user.User> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    throw UnimplementedError('Mock auth - use real implementation');
  }

  @override
  Future<domain_user.User> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    throw UnimplementedError('Mock auth - use real implementation');
  }

  @override
  Future<domain_user.User> createAccount(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    throw UnimplementedError('Mock auth - use real implementation');
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<void> refreshToken() async {}
}


class MockCloudStorageService implements CloudStorageService {
  @override
  Future<void> uploadProgress(String userId, ProgressData progress, String levelId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - progress uploaded', context: {
        'userId': userId,
        'levelId': levelId,
        'score': progress.currentScore,
        'serviceType': 'mock_upload',
      });
    }
  }

  @override
  Future<ProgressData?> downloadProgress(String userId, String levelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - progress download request', context: {
        'userId': userId,
        'levelId': levelId,
        'serviceType': 'mock_download',
      });
    }
    return null;
  }

  @override
  Future<void> syncAllProgress(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - full progress sync started', context: {
        'userId': userId,
        'serviceType': 'mock_sync',
      });
    }
  }

  @override
  Future<void> uploadPreferences(String userId, domain_user.UserPreferences preferences) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - preferences uploaded', context: {
        'userId': userId,
        'serviceType': 'mock_preferences_upload',
      });
    }
  }

  @override
  Future<domain_user.UserPreferences?> downloadPreferences(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - preferences download request', context: {
        'userId': userId,
        'serviceType': 'mock_preferences_download',
      });
    }
    return null;
  }

  @override
  Future<void> uploadStats(String userId, domain_user.UserStats stats) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - stats uploaded', context: {
        'userId': userId,
        'serviceType': 'mock_stats_upload',
      });
    }
  }

  @override
  Future<domain_user.UserStats?> downloadStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - stats download request', context: {
        'userId': userId,
        'serviceType': 'mock_stats_download',
      });
    }
    return null;
  }

  @override
  Future<bool> hasCloudData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return false;
  }

  @override
  Future<void> deleteUserData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Mock cloud service - user data deletion', context: {
        'userId': userId,
        'serviceType': 'mock_data_deletion',
      });
    }
  }

  @override
  Future<SyncStatus> getSyncStatus(String userId) async => SyncStatus.synced;

  @override
  Future<SyncResult> resolveConflicts(Map<String, dynamic> local, Map<String, dynamic> remote, ConflictResolutionStrategy strategy) async => SyncResult.success;
}

class LocalAuthService implements AuthService {
  @override
  Stream<domain_user.User?> authStateChanges() => Stream.value(null);

  @override
  Future<domain_user.User?> getCurrentUser() async => null;

  @override
  Future<domain_user.User> signInWithEmail(String email, String password) async {
    throw UnsupportedError('Authentication is disabled in local-only mode');
  }

  @override
  Future<domain_user.User> signInWithGoogle() async {
    throw UnsupportedError('Authentication is disabled in local-only mode');
  }

  @override
  Future<domain_user.User> signInWithApple() async {
    throw UnsupportedError('Authentication is disabled in local-only mode');
  }

  @override
  Future<domain_user.User> createAccount(String email, String password) async {
    throw UnsupportedError('Authentication is disabled in local-only mode');
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    throw UnsupportedError('Authentication is disabled in local-only mode');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<void> refreshToken() async {}
}


class LocalCloudStorageService implements CloudStorageService {
  @override
  Future<void> uploadProgress(String userId, ProgressData progress, String levelId) async {
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Local cloud service - upload ignored', context: {
        'userId': userId,
        'levelId': levelId,
        'serviceType': 'local_mode_disabled',
      });
    }
  }

  @override
  Future<ProgressData?> downloadProgress(String userId, String levelId) async {
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Local cloud service - download ignored', context: {
        'userId': userId,
        'levelId': levelId,
        'serviceType': 'local_mode_disabled',
      });
    }
    return null;
  }

  @override
  Future<void> syncAllProgress(String userId) async {
    if (CloudConfig.enableCloudLogging) {
      StructuredLogger.debug('Local cloud service - sync ignored', context: {
        'userId': userId,
        'serviceType': 'local_mode_disabled',
      });
    }
  }

  @override
  Future<void> uploadPreferences(String userId, domain_user.UserPreferences preferences) async {
    if (CloudConfig.enableCloudLogging) {
      print('Local: Preferences upload ignored (local-only mode)');
    }
  }

  @override
  Future<domain_user.UserPreferences?> downloadPreferences(String userId) async {
    if (CloudConfig.enableCloudLogging) {
      print('Local: Preferences download ignored (local-only mode)');
    }
    return null;
  }

  @override
  Future<void> uploadStats(String userId, domain_user.UserStats stats) async {
    if (CloudConfig.enableCloudLogging) {
      print('Local: Stats upload ignored (local-only mode)');
    }
  }

  @override
  Future<domain_user.UserStats?> downloadStats(String userId) async {
    if (CloudConfig.enableCloudLogging) {
      print('Local: Stats download ignored (local-only mode)');
    }
    return null;
  }

  @override
  Future<bool> hasCloudData(String userId) async => false;

  @override
  Future<void> deleteUserData(String userId) async {
    if (CloudConfig.enableCloudLogging) {
      print('Local: User data deletion ignored (local-only mode)');
    }
  }

  @override
  Future<SyncStatus> getSyncStatus(String userId) async => SyncStatus.noData;

  @override
  Future<SyncResult> resolveConflicts(Map<String, dynamic> local, Map<String, dynamic> remote, ConflictResolutionStrategy strategy) async => SyncResult.success;
}

// Cloud Service Manager
class CloudServiceManager {
    static AuthService getAuthService() {
    switch (currentCloudMode) {
      case CloudServiceMode.real:
        return FirebaseAuthService(fb_auth.FirebaseAuth.instance);
      case CloudServiceMode.mocked:
        return MockAuthService();
      case CloudServiceMode.emulator:
        return FirebaseAuthService(fb_auth.FirebaseAuth.instance); // Assuming emulator is configured globally
      case CloudServiceMode.localOnly:
        return LocalAuthService();
    }
  }

    static CloudStorageService getCloudStorageService() {
    switch (currentCloudMode) {
      case CloudServiceMode.real:
        return FirebaseCloudStorageService(FirebaseFirestore.instance);
      case CloudServiceMode.mocked:
        return MockCloudStorageService();
      case CloudServiceMode.emulator:
        // TODO: Return FirebaseCloudStorageService with emulator config
        throw UnimplementedError('Firebase emulator not yet configured');
      case CloudServiceMode.localOnly:
        return LocalCloudStorageService();
    }
  }
}

// Riverpod providers for cloud services
final authServiceProvider = Provider<AuthService>((ref) {
  return CloudServiceManager.getAuthService();
});

final cloudStorageServiceProvider = Provider<CloudStorageService>((ref) {
  return CloudServiceManager.getCloudStorageService();
});