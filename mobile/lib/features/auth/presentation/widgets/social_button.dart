import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/google_auth_service.dart';
import '../../../../core/network/auth_storage_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../home/presentation/screens/main_screen.dart';

class SocialButton extends StatefulWidget {
  final String text;

  const SocialButton({
    super.key,
    required this.text,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  final _googleAuthService = GoogleAuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final response = await _googleAuthService.signInWithGoogle();

      if (response != null) {
        final accessToken = response['accessToken'];
        final refreshToken = response['refreshToken'];
        final fullName = response['fullName'] ?? 'User';
        final email = response['email'] ?? '';

        if (accessToken != null && refreshToken != null) {
          await AuthStorageService.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );

          final id = response['id'];
          await AuthStorageService.saveUserInfo(
            email: email,
            fullName: fullName,
            id: id ?? 0,
          );

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else {
          throw Exception('Failed to get valid tokens from backend.');
        }
      } else {
        // Sign in cancelled by user or returned null
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else ...[
                SvgPicture.asset('assets/google_logo.svg', width: 24, height: 24),
                const SizedBox(width: 12),
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
