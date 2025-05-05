import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/forgot_password_page_controller.dart';
import '/app/forms/forgot_password_form.dart';
import '/resources/pages/login_page.dart';

class ForgotPasswordPagePage
    extends NyStatefulWidget<ForgotPasswordPageController> {
  static RouteView path = ("/forgot-password", (_) => ForgotPasswordPagePage());

  ForgotPasswordPagePage({super.key})
      : super(child: () => _ForgotPasswordPagePageState());
}

class _ForgotPasswordPagePageState extends NyPage<ForgotPasswordPagePage> {
  /// [ForgotPasswordPageController] controller
  ForgotPasswordPageController get controller => widget.controller;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Forgot password form
  late ForgotPasswordForm _forgotPasswordForm;

  @override
  get init => () {
        _forgotPasswordForm = ForgotPasswordForm();
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Header
              Text(
                "Forgot Password",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                "Enter your email address and we'll send you a link to reset your password.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Forgot password form
              NyForm(
                key: _formKey,
                form: _forgotPasswordForm,
              ),

              const SizedBox(height: 10),

              // Error message
              ValueListenableBuilder<String>(
                valueListenable: controller.errorMessageNotifier,
                builder: (context, errorMessage, child) {
                  if (errorMessage.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              // Success message
              ValueListenableBuilder<bool>(
                valueListenable: controller.resetSentNotifier,
                builder: (context, resetSent, child) {
                  if (!resetSent) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "Reset link sent to your email!",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              // Reset password button
              ValueListenableBuilder<bool>(
                valueListenable: controller.isLoadingNotifier,
                builder: (context, isLoading, child) {
                  return ElevatedButton(
                    onPressed: isLoading ? null : () => _handleResetPassword(),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Send Reset Link'),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Back to login link
              TextButton(
                onPressed: () => routeTo(LoginPagePage.path),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle reset password form submission
  void _handleResetPassword() {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      // Get the email value directly
      final fields = _forgotPasswordForm.fields();
      final emailField =
          fields.first; // There's only one field (Email) in this form
      final email = emailField.value as String? ?? '';

      controller.resetPassword(email);
    }
  }
}
