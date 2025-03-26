import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      
      body: Center(
        child: Text(
          '¡Bienvenido a Mi App!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}