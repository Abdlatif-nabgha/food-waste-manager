import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'ACCESS_TOKEN';
  static const _keyRefreshToken = 'REFRESH_TOKEN';
  static const _keyEmail = 'USER_EMAIL';
  static const _keyFullName = 'USER_FULL_NAME';
  static const _keyUserId = 'USER_ID';

  // Save Tokens & User Info
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<void> saveUserInfo({
    required String email,
    required String fullName,
    required int id,
  }) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyFullName, value: fullName);
    await _storage.write(key: _keyUserId, value: id.toString());
  }

  // Get Tokens
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Get User Info
  static Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  static Future<String?> getFullName() async {
    return await _storage.read(key: _keyFullName);
  }

  static Future<int?> getUserId() async {
    final idStr = await _storage.read(key: _keyUserId);
    if (idStr != null) {
      return int.tryParse(idStr);
    }
    return null;
  }

  // Clear Storage on Logout
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
