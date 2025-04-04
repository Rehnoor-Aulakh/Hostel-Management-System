import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStaffScreen extends StatefulWidget {
  @override
  _AddStaffScreenState createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hostelIdController = TextEditingController();
  final TextEditingController _blockIdController = TextEditingController();

  String? selectedRole;
  List<Map<String, dynamic>> roles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2/hostel_management/get_roles.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        roles = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<void> _addStaff() async {
    if (_nameController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _hostelIdController.text.isEmpty ||
        _blockIdController.text.isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2/hostel_management/add_staff.php'),
      body: {
        'name': _nameController.text,
        'role_id': selectedRole,
        'contact': _contactController.text,
        'hostel_name': _hostelIdController.text,
        'block_name': _blockIdController.text,
        'email': _emailController.text,
      },
    );

    setState(() {
      _isLoading = false;
    });

    final data = json.decode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );

    if (data['success']) {
      _nameController.clear();
      _contactController.clear();
      _emailController.clear();
      _hostelIdController.clear();
      _blockIdController.clear();
      setState(() {
        selectedRole = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(title: Text("Add Staff")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "Enter staff name")),
            SizedBox(height: 10),
            Text("Role",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField(
              value: selectedRole,
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role['role_id'].toString(),
                  child: Text(role['role_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value as String?;
                });
              },
              decoration: InputDecoration(hintText: "Select role"),
            ),
            SizedBox(height: 10),
            Text("Contact",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
                controller: _contactController,
                decoration: InputDecoration(hintText: "Enter contact")),
            SizedBox(height: 10),
            Text("Email",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: "Enter email")),
            SizedBox(height: 10),
            Text("Hostel Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
                controller: _hostelIdController,
                decoration: InputDecoration(hintText: "Enter Hostel Name")),
            SizedBox(height: 10),
            Text("Block Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
                controller: _blockIdController,
                decoration: InputDecoration(hintText: "Enter Block Name")),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Center(
                    child: ElevatedButton(
                      onPressed: _addStaff,
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 60, 10, 127),
                          foregroundColor: Colors.white),
                      child: Text('Add Staff'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
