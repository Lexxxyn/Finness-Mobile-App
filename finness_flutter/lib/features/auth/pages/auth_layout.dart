import 'package:flutter/material.dart';

import 'forgot_password_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import '../providers/auth_provider.dart';

class AuthLayout {
  const AuthLayout._();

  static const loginRoute = '/auth/login';
  static const registerRoute = '/auth/register';
  static const forgotPasswordRoute = '/auth/forgot-password';

  static Map<String, WidgetBuilder> routes({WidgetBuilder? homeBuilder}) {
    return {
      '/': homeBuilder ?? (_) => const _HomePlaceholder(),
      loginRoute: (_) => const LoginPage(),
      registerRoute: (context) => RegisterPage(
        onLoginPressed: () {
          Navigator.of(context).pushReplacementNamed(loginRoute);
        },
        onRegister: (data) async {
          await authService.register(
            data.email,
            data.password,
            name: data.name,
            gender: data.gender,
            dob: data.dob == null ? null : _formatDate(data.dob!),
            height: data.height,
            weight: data.weight,
            equipment: data.equipment,
            goal: data.goal,
          );
        },
        onRegistered: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        },
      ),
      forgotPasswordRoute: (_) => ForgotPasswordPage(
        onResetPassword: (email) async {
          await authService.sendPasswordReset(email);
        },
      ),
    };
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home')));
  }
}
