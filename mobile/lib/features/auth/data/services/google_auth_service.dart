import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '806095337610-2fc7pku90lub6k5hd3didhn1j12ckgr4.apps.googleusercontent.com',
    serverClientId:
        '806095337610-apubvklb92i22hkmab3v90co508v8792.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) return null;

      final response = await _dio.post(
        '/api/auth/google',
        queryParameters: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
