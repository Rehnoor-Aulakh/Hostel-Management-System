import 'package:flutter/material.dart';
import 'package:hostel_management/warden_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_details_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _selectedRole = 'Student';

  // Function to show snackbar
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> registerUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      showSnackbar("Please fill all fields!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("http://10.0.2.2/hostel_management/signup.php");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "role": _selectedRole,
      }),
    );
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showSnackbar(responseData["message"]);

      // Navigate to the respective details page based on role
      if (_selectedRole == "Student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailsScreen(
                email: _emailController.text, name: _nameController.text),
          ),
        );
      } else if (_selectedRole == "Warden") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WardenDetailsScreen(
                email: _emailController.text, name: _nameController.text),
            // WardenDetailsScreen(email: _emailController.text),
          ),
        );
      } else if (_selectedRole == "Staff") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDetailsScreen(
                email: _emailController.text, name: _nameController.text),
            // StaffDetailsScreen(email: _emailController.text),
          ),
        );
      }
    } else {
      showSnackbar("Signup failed! Try again.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text(
          'SIGNUP',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 60, 10, 127),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedRole,
              items: ["Student", "Warden", "Staff"].map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registerUser,
                    child: const Text('Sign Up'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 60, 10, 127)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
