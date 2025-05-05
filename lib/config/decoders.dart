import '/app/controllers/dashboard_page_controller.dart';
import '/app/models/chore.dart';
import '/app/networking/auth_api_service.dart';
import '/app/networking/chore_api_service.dart';
import '/app/networking/household_api_service.dart';
import '/app/models/household.dart';
import '/app/models/notification.dart';
import '/app/controllers/forgot_password_page_controller.dart';
import '/app/controllers/register_page_controller.dart';
import '/app/controllers/login_page_controller.dart';
import '/app/controllers/home_controller.dart';
import '/app/models/user.dart';
import '/app/networking/api_service.dart';

/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/6.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  //
  User: (data) => User.fromJson(data),

  // User: (data) => User.fromJson(data),

  List<Notification>: (data) => List.from(data).map((json) => Notification.fromJson(json)).toList(),

  Notification: (data) => Notification.fromJson(data),

  List<Household>: (data) => List.from(data).map((json) => Household.fromJson(json)).toList(),

  Household: (data) => Household.fromJson(data),

  List<Chore>: (data) => List.from(data).map((json) => Chore.fromJson(json)).toList(),

  Chore: (data) => Chore.fromJson(data),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/6.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),

  // ...

  HouseholdApiService: HouseholdApiService(),

  ChoreApiService: ChoreApiService(),

  AuthApiService: AuthApiService(),
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/6.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  HomeController: () => HomeController(),

  // ...

  LoginPageController: () => LoginPageController(),

  RegisterPageController: () => RegisterPageController(),

  ForgotPasswordPageController: () => ForgotPasswordPageController(),

  DashboardPageController: () => DashboardPageController(),
};

