import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/material.dart';

/* ForgotPassword Form
|--------------------------------------------------------------------------
| Usage: https://nylo.dev/docs/6.x/forms#how-it-works
| Casts: https://nylo.dev/docs/6.x/forms#form-casts
| Validation Rules: https://nylo.dev/docs/6.x/validation#validation-rules
|-------------------------------------------------------------------------- */

class ForgotPasswordForm extends NyFormData {
  ForgotPasswordForm({String? name}) : super(name ?? "forgot_password");

  // @override
  // get init => () {
  //   /// Initial data for the form
  //   return {
  //     "name": "Anthony",
  //     "price": "100",
  //     "favourite_color": "Blue",
  //     "bio": "I am a Flutter Developer"
  //   };
  // };

  @override
  fields() => [
        Field.email(
          "Email",
          autofocus: true,
          validate: FormValidator.rule("email"),
          style: "compact",
        ),
      ];

  @override
  Widget? get submitButton => null; // Submit button will be added in the page
}
