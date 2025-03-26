import 'package:flutter/material.dart';
import '/screens/dashboard_screen.dart';
import '/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_providers.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadToken(), // Carga el token al iniciar
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Aplicación',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
            .copyWith(secondary: Colors.orange),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
          titleLarge:
              TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
      },
    );
  }
}
