import 'package:flutter/material.dart';
import 'package:hostel_management/complaints_dashboard.dart';
import 'room_details_screen.dart';

class StudentDashboard extends StatelessWidget {
  final String email;
  const StudentDashboard({required this.email});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text('Student Dashboard', textAlign: TextAlign.center),
        backgroundColor: const Color.fromARGB(255, 60, 10, 127),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              DashboardTile(title: "Room Details", icon: Icons.room),
              DashboardTile(title: "Complaints", icon: Icons.report_problem),
              DashboardTile(
                  title: "Fee Status", icon: Icons.account_balance_wallet),
              DashboardTile(title: "Attendance", icon: Icons.assignment),
            ],
          )),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const DashboardTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          // Add navigation logic for each section
          if (title == "Room Details") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RoomDetailsScreen(studentId: 123)));
          } else if (title == "Complaints") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ComplaintsDashboard()));
          }
        },
      ),
    );
  }
}
