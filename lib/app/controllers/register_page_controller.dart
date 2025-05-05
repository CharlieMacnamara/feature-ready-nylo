import '/resources/pages/dashboard_page.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/repositories/auth_repository.dart';

class RegisterPageController extends NyController {
  late AuthRepository _authRepository;
  
  // ValueNotifiers for reactive state
  final ValueNotifier<String> errorMessageNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  @override
  construct(BuildContext context) {
    super.construct(context);
    _authRepository = AuthRepository();

    // Initialize state
    updateState('errorMessage', data: null);
    updateState('isLoading', data: false);
  }

  /// Register a new user
  Future<void> register(String email, String password) async {
    try {
      // Set loading state
      updateState('isLoading', data: true);
      isLoadingNotifier.value = true;
      
      // Clear any previous error
      updateState('errorMessage', data: null);
      errorMessageNotifier.value = '';

      // Register user using repository
      final userData = await _authRepository.signUpWithEmail(email, password);

      if (userData != null) {
        // Use Nylo's authentication helper to store the session
        await Auth.authenticate(data: userData);

        // If successful, navigate to dashboard
        updateState('isLoading', data: false);
        isLoadingNotifier.value = false;
        await routeTo(DashboardPage.path);
      } else {
        throw Exception("Registration failed");
      }
    } catch (e) {
      // Handle error
      updateState('isLoading', data: false);
      isLoadingNotifier.value = false;
      updateState('errorMessage', data: e.toString());
      errorMessageNotifier.value = e.toString();
    }
  }
}
