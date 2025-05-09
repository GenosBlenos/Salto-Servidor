import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  final User user;

  const DashboardScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bem-vindo ${user.email}')),
      body: Center(
        child: Text('Dashboard do Funcionário'),
      ),
    );
  }
}