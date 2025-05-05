import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/register_page_controller.dart';
import '/app/forms/register_form.dart';
import '/resources/pages/login_page.dart';

class RegisterPagePage extends NyStatefulWidget<RegisterPageController> {
  static RouteView path = ("/register", (_) => RegisterPagePage());

  RegisterPagePage({super.key}) : super(child: () => _RegisterPagePageState());
}

class _RegisterPagePageState extends NyPage<RegisterPagePage> {
  /// [RegisterPageController] controller
  RegisterPageController get controller => widget.controller;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Register form
  late RegisterForm _registerForm;

  @override
  get init => () {
        _registerForm = RegisterForm();
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo or app name
                Text(
                  "Create Account",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Register form
                NyForm(
                  key: _formKey,
                  form: _registerForm,
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

                // Register button
                ValueListenableBuilder<bool>(
                  valueListenable: controller.isLoadingNotifier,
                  builder: (context, isLoading, child) {
                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _handleRegister(),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Register'),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => routeTo(LoginPagePage.path),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle register form submission
  void _handleRegister() {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      // Get form data directly from fields
      final fields = _registerForm.fields();
      final email = fields.firstWhere((field) => field.name == "Email").value
              as String? ??
          '';
      final password = fields
              .firstWhere((field) => field.name == "Password")
              .value as String? ??
          '';

      controller.register(email, password);
    }
  }
}
