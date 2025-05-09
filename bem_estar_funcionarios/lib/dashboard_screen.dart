import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Bem-Estar Funcionário')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              _buildEmergencyButton(context),
              _buildAppointments(userData['appointments']),
              _buildProcesses(userData['processes']),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.warning),
      label: Text('Emergência'),
      onPressed: () => Navigator.pushNamed(context, '/emergency'),
      style: ElevatedButton.styleFrom(primary: Colors.red),
    );
  }
}