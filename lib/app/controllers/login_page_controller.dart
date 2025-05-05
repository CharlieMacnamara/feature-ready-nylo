import '/app/repositories/auth_repository.dart';
import '/resources/pages/dashboard_page.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginPageController extends NyController {
  final AuthRepository _authRepository = AuthRepository();
  
  // ValueNotifiers for reactive state
  final ValueNotifier<String> errorMessageNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  @override
  construct(BuildContext context) {
    super.construct(context);

    // Initialize state variables
    updateState('isLoading', data: false);
    updateState('errorMessage', data: '');
  }

  /// Login using email and password
  Future<void> login(String email, String password) async {
    // Update loading state
    updateState('isLoading', data: true);
    isLoadingNotifier.value = true;
    
    updateState('errorMessage', data: '');
    errorMessageNotifier.value = '';

    try {
      // Attempt to sign in using AuthRepository
      final result = await _authRepository.signInWithEmail(email, password);

      if (result != null) {
        // Authenticate using Nylo's Auth helper
        await Auth.authenticate(data: result);

        // Navigate to dashboard on success
        await routeTo(DashboardPagePage.path);
      } else {
        updateState('errorMessage', data: 'Invalid email or password');
        errorMessageNotifier.value = 'Invalid email or password';
      }
    } catch (e) {
      updateState('errorMessage', data: 'An error occurred. Please try again.');
      errorMessageNotifier.value = 'An error occurred. Please try again.';
      printError('Login error: $e');
    } finally {
      updateState('isLoading', data: false);
      isLoadingNotifier.value = false;
    }
  }
}
