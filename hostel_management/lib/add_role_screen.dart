import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddRoleScreen extends StatefulWidget {
  @override
  _AddRoleScreenState createState() => _AddRoleScreenState();
}

class _AddRoleScreenState extends State<AddRoleScreen> {
  final TextEditingController _roleController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addRole() async {
    if (_roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a role name")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2/hostel_management/add_roles.php'),
      body: {
        'role_name': _roleController.text,
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
      if (data['success']) {
        _roleController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add role")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(title: const Text("Add Role")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Role Name", style: TextStyle(fontSize: 18)),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(hintText: "Enter role name"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Center(
                    child: ElevatedButton(
                      onPressed: _addRole,
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 60, 10, 127),
                          foregroundColor: Colors.white),
                      child: const Text("Add Role"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
