import 'package:flutter/material.dart';
import 'package:hostel_management/warden_dashboard.dart';
import 'package:http/http.dart' as http;
import 'admin_dashboard.dart';
import 'dart:convert';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }

  Future<void> loginUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showSnackbar("Please fill all fields!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("http://10.0.2.2/hostel_management/login.php");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text,
        "password": _passwordController.text,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showSnackbar(responseData["message"]);
      // Navigate to dashboard if needed
      if (responseData["user"]["role"] == "Student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => StudentDashboard(
                    email: _emailController.text,
                  )),
        );
      } else if (responseData["user"]["role"] == "Warden") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WardenDashboard(email: _emailController.text)),
        );
      } else if (responseData["user"]["role"] == "Admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      }
    } else {
      showSnackbar("Login failed! Try again.");
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
        title: const Text('LOGIN', textAlign: TextAlign.center),
        backgroundColor: Color.fromARGB(255, 60, 10, 127),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: Text('Login'),
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
