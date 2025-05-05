import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/login_page_controller.dart';
import '/app/forms/login_form.dart';
import '/resources/pages/forgot_password_page.dart';
import '/resources/pages/register_page.dart';

class LoginPagePage extends NyStatefulWidget<LoginPageController> {
  static RouteView path = ("/login", (_) => LoginPagePage());

  LoginPagePage({super.key}) : super(child: () => _LoginPagePageState());
}

class _LoginPagePageState extends NyPage<LoginPagePage> {
  /// [LoginPageController] controller
  LoginPageController get controller => widget.controller;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Login form
  late LoginForm _loginForm;

  @override
  get init => () {
        _loginForm = LoginForm();
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo or app name
              Text(
                "Deedlicious",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Login form
              NyForm(
                key: _formKey,
                form: _loginForm,
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

              // Login button
              ValueListenableBuilder<bool>(
                valueListenable: controller.isLoadingNotifier,
                builder: (context, isLoading, child) {
                  return ElevatedButton(
                    onPressed: isLoading ? null : () => _handleLogin(),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Forgot password link
              TextButton(
                onPressed: () => routeTo(ForgotPasswordPagePage.path),
                child: const Text('Forgot Password?'),
              ),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => routeTo(RegisterPagePage.path),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle login form submission
  void _handleLogin() {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      // Get form data directly from fields
      final fields = _loginForm.fields();
      final email = fields.firstWhere((field) => field.name == "Email").value
              as String? ??
          '';
      final password = fields
              .firstWhere((field) => field.name == "Password")
              .value as String? ??
          '';

      controller.login(email, password);
    }
  }
}
