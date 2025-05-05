import '/resources/pages/dashboard_page.dart';
import '/resources/pages/dashboard_page.dart';
import '/resources/pages/home_page.dart';
import '/resources/pages/login_page.dart';
import '/resources/pages/register_page.dart';
import '/resources/pages/forgot_password_page.dart';
import '/resources/pages/not_found_page.dart';
import '/routes/guards/auth_route_guard.dart';
import 'package:nylo_framework/nylo_framework.dart';

/*
|--------------------------------------------------------------------------
| App Router
|
| Router helps your app handle page navigation and can be used to control
| the flow of your application.
|
| Learn more: https://nylo.dev/docs/6.x/router
|--------------------------------------------------------------------------
*/

appRouter() => nyRoutes((router) {
      // Public routes
      router.add(HomePage.path).initialRoute();
      router.add(LoginPagePage.path);
      router.add(RegisterPagePage.path);
      router.add(ForgotPasswordPagePage.path);

      // Protected routes with authentication guard
      router.add(DashboardPage.path, routeGuards: [AuthRouteGuard()]);

      // Unknown route handler
      router.add(NotFoundPage.path).unknownRoute();
      router.add(DashboardPage.path);
});
