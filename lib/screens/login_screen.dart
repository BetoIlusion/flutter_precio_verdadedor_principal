import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard_screen.dart';
import 'package:flutter_precio_verdadedor_principal/providers/auth_providers.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.5:8000/api/auth/login'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': data.name,
          'password': data.password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final token = responseData['token'];
        final user = responseData['user'];

        if (token != null && user != null) {
          await Provider.of<AuthProvider>(context, listen: false).setAuthData(
            token,
            user['id'],
            user['name'],
            user['email'],
            user['telefono'],
          );
          return null; // Éxito
        } else {
          return 'Respuesta inválida del servidor';
        }
      } else if (response.statusCode == 401) {
        return 'Credenciales incorrectas';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  Future<String?> _signupUser(SignupData data) {
    // Aquí podrías implementar el registro real si lo deseas
    return Future.delayed(loginTime).then((_) {
      return 'El registro no está implementado aún';
    });
  }

  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      return 'La recuperación no está implementada aún';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Mi App',
      onLogin: (loginData) => _authUser(loginData, context),
      onSignup: _signupUser,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      },
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: Icons.g_mobiledata,
          label: 'Google',
          callback: () async {
            debugPrint('Inicio de sesión con Google');
            await Future.delayed(loginTime);
            return null;
          },
        ),
        LoginProvider(
          icon: Icons.facebook,
          label: 'Facebook',
          callback: () async {
            debugPrint('Inicio de sesión con Facebook');
            await Future.delayed(loginTime);
            return null;
          },
        ),
      ],
      theme: LoginTheme(
        primaryColor: Colors.teal,
        accentColor: Colors.orange,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        bodyStyle: Theme.of(context).textTheme.bodyMedium,
        textFieldStyle: Theme.of(context).textTheme.bodyMedium,
      ),
      messages: LoginMessages(
        userHint: 'Correo electrónico',
        passwordHint: 'Contraseña',
        loginButton: 'Iniciar Sesión',
        signupButton: 'Registrarse',
        forgotPasswordButton: '¿Olvidaste tu contraseña?',
      ),
      hideForgotPasswordButton: false,
      footer: null,
    );
  }
}
