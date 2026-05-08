import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') && data['message'] != null) {
          return data['message'].toString();
        }
        if (data.containsKey('error') && data['error'] != null) {
          // Spring Boot default error field
          return data['error'].toString();
        }
      }
      return fallback;
    }
    return 'Connection error. Please check if your backend is running.';
  }

  Future<String> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
      
      final message = response.data['message'] ?? 'Verification code sent to your email.';
      if (message.toString().toLowerCase().contains('error')) {
        throw Exception(message);
      }
      return message;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to register. Please try again.'));
    } catch (e) {
      if (e.toString().contains('Error')) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<String> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify-email',
        data: {
          'email': email,
          'code': int.tryParse(code) ?? 0,
        },
      );
      
      final message = response.data['message'] ?? 'Email verified successfully. You can now login.';
      if (message.toString().toLowerCase().contains('error')) {
        throw Exception(message);
      }
      return message;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Invalid or expired code.'));
    } catch (e) {
      if (e.toString().contains('Error')) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<String> resendCode({required String email}) async {
    try {
      final response = await _dio.post(
        '/api/auth/resend-code',
        queryParameters: {'email': email},
      );
      
      final message = response.data['message'] ?? 'Verification code resent successfully.';
      if (message.toString().toLowerCase().contains('error')) {
        throw Exception(message);
      }
      return message;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to resend code.'));
    } catch (e) {
      if (e.toString().contains('Error')) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Some APIs return the error inside a 200 OK.
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
            final msg = data['message'].toString();
            if (msg.toLowerCase().contains('verify your email') || msg.toLowerCase().contains('error')) {
               throw Exception(msg);
            }
        }
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to login. Please check your credentials.'));
    } catch (e) {
      if (e.toString().contains('verify your email') || e.toString().contains('Error')) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        '/api/auth/forgot-password',
        queryParameters: {'email': email},
      );
      
      final message = response.data['message'] ?? 'Reset code sent to your email.';
      if (message.toString().toLowerCase().contains('error')) {
        throw Exception(message);
      }
      return message;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to request password reset.'));
    } catch (e) {
      if (e.toString().contains('Error')) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/reset-password',
        data: {
          'email': email,
          'code': int.tryParse(code) ?? 0,
          'newPassword': newPassword,
        },
      );
      
      final message = response.data['message'] ?? 'Password reset successfully.';
      if (message.toString().toLowerCase().contains('error')) {
        throw Exception(message);
      }
      return message;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to reset password.'));
    } catch (e) {
      if (e.toString().contains('Error')) rethrow;
      throw Exception('An unexpected error occurred.');
    }
  }
}
