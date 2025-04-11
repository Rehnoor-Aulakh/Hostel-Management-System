import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text('Hostel Management', textAlign: TextAlign.center),
        backgroundColor: Color.fromARGB(255, 60, 10, 127),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Hostel Management",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    "Login",
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Color.fromARGB(255, 60, 10, 127),
                      foregroundColor: Colors.white),
                ),
                const SizedBox(width: 85),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignupScreen()));
                  },
                  child: Text(
                    "Signup",
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Color.fromARGB(255, 60, 10, 127),
                      foregroundColor: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
