import 'package:flutter/material.dart';
import 'package:hostel_management/student_dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentDetailsScreen extends StatefulWidget {
  final String email;
  final String name;

  const StudentDetailsScreen({required this.email, required this.name});

  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? _selectedCourse;
  String? _selectedGender;

  final List<String> _courses = ['BTech', 'MTech', 'PhD'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  Future<void> saveStudentDetails() async {
    if (_selectedCourse == null ||
        _selectedGender == null ||
        _yearController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    final url =
        Uri.parse("http://10.0.2.2/hostel_management/add_student_details.php");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "name": widget.name,
          "age": int.parse(_ageController.text),
          "gender": _selectedGender,
          "contact": _contactController.text,
          "course": _selectedCourse,
          "year": int.parse(_yearController.text)
        }));
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData["message"])));
    }
    if (responseData["success"]) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => StudentDashboard(email: widget.email)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save details!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: Text("Student Details"),
        backgroundColor: Color.fromARGB(255, 60, 10, 127),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Name: ${widget.name}", style: TextStyle(fontSize: 16)),
            Text("Email: ${widget.email}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              items: _courses
                  .map((course) => DropdownMenuItem(
                        value: course,
                        child: Text(course),
                      ))
                  .toList(),
              decoration: InputDecoration(labelText: "Course"),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
            ),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: "Year"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: _genders
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              decoration: InputDecoration(labelText: "Gender"),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: "Contact"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveStudentDetails,
              child: Text("Save Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 60, 10, 127),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
