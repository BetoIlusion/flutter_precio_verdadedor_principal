import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'dashboard_screen.dart';

const users = {
  'usuario@example.com': 'pass123',
  'admin@example.com': 'admin',
};

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    debugPrint('Login - Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'El usuario no existe';
      }
      if (users[data.name] != data.password) {
        return 'La contraseña no coincide';
      }
      return null; // Éxito
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup - Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (users.containsKey(data.name)) {
        return 'El usuario ya existe';
      }
      return null; // Éxito
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Recover - Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'El usuario no existe';
      }
      return null; // Éxito
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Mi App',
      // logo: const AssetImage('assets/logo.png'), // Descomenta si tienes un logo
      onLogin: _authUser,
      onSignup: _signupUser,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      },
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: Icons.g_mobiledata, // Icono básico de Google (FontAwesome no está incluido por defecto)
          label: 'Google',
          callback: () async {
            debugPrint('Inicio de sesión con Google');
            await Future.delayed(loginTime);
            debugPrint('Fin de sesión con Google');
            return null;
          },
        ),
        LoginProvider(
          icon: Icons.facebook, // Icono básico de Facebook
          label: 'Facebook',
          callback: () async {
            debugPrint('Inicio de sesión con Facebook');
            await Future.delayed(loginTime);
            debugPrint('Fin de sesión con Facebook');
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
      hideForgotPasswordButton: false, // Mostrar opción de recuperación
      //hideSignUpButton: false, // Mostrar opción de registro
      footer: null, // Quitamos la marca de agua
    );
  }
}