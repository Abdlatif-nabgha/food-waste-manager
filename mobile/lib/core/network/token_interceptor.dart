import 'package:dio/dio.dart';
import 'auth_storage_service.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;

  TokenInterceptor(this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Exclude auth routes from needing access token
    if (!options.path.contains('/api/auth/')) {
      final accessToken = await AuthStorageService.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/api/auth/')) {
      // 401 Unauthorized outside of auth routes. Try refreshing token.
      final refreshToken = await AuthStorageService.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // Use a new Dio instance to avoid infinite loops with this interceptor
          final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
          
          final response = await refreshDio.post(
            '/api/auth/refresh-token',
            queryParameters: {'token': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            if (newAccessToken != null && newRefreshToken != null) {
              await AuthStorageService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Retry the original request
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              
              final cloneReq = await refreshDio.request(
                opts.path,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                ),
                data: opts.data,
                queryParameters: opts.queryParameters,
              );
              
              return handler.resolve(cloneReq);
            }
          }
        } catch (e) {
          // Refresh failed. Clear tokens and logout.
          await AuthStorageService.clearAll();
          // Ideally, we'd navigate back to Login via a GlobalKey<NavigatorState> or similar event bus
        }
      } else {
        // No refresh token available. Logout.
        await AuthStorageService.clearAll();
      }
    }

    return handler.next(err);
  }
}
