import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hostel_management/add_role_screen.dart';
import 'package:hostel_management/add_staff.dart';

class WardenDashboard extends StatelessWidget {
  final String email;
  const WardenDashboard({required this.email});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text('Warden Dashboard', textAlign: TextAlign.center),
        backgroundColor: const Color.fromARGB(255, 60, 10, 127),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStaffScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 60, 10, 127),
                  foregroundColor: Colors.white),
              child: Text('Add Staff'),
            ),
          ],
        ),
      ),
    );
  }
}
