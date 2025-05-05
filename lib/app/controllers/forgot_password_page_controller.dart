import '/app/repositories/auth_repository.dart';
import '/resources/pages/login_page.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ForgotPasswordPageController extends NyController {
  final AuthRepository _authRepository = AuthRepository();
  
  // ValueNotifiers for reactive state
  final ValueNotifier<String> errorMessageNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> resetSentNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  @override
  construct(BuildContext context) {
    super.construct(context);

    // Initialize state variables
    updateState('isLoading', data: false);
    updateState('errorMessage', data: '');
    updateState('resetSent', data: false);
  }

  /// Reset password using email
  Future<void> resetPassword(String email) async {
    // Update loading state
    updateState('isLoading', data: true);
    isLoadingNotifier.value = true;
    
    updateState('errorMessage', data: '');
    errorMessageNotifier.value = '';
    
    updateState('resetSent', data: false);
    resetSentNotifier.value = false;

    try {
      // Attempt to send password reset email using AuthRepository
      final success = await _authRepository.sendPasswordResetEmail(email);

      if (success) {
        // Update state and show success toast
        updateState('resetSent', data: true);
        resetSentNotifier.value = true;
        
        showToastSuccess(
            title: "Success",
            description: 'Password reset link sent to your email');

        // Redirect to login page after short delay
        await Future.delayed(const Duration(seconds: 2));
        await routeTo(LoginPagePage.path);
      } else {
        updateState('errorMessage',
            data: 'Failed to send reset link. Please try again.');
        errorMessageNotifier.value = 'Failed to send reset link. Please try again.';
      }
    } catch (e) {
      updateState('errorMessage', data: 'An error occurred. Please try again.');
      errorMessageNotifier.value = 'An error occurred. Please try again.';
      printError('Password reset error: $e');
    } finally {
      updateState('isLoading', data: false);
      isLoadingNotifier.value = false;
    }
  }
}
