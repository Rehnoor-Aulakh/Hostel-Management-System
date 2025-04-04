import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'warden_dashboard.dart';

class WardenDetailsScreen extends StatefulWidget {
  final String email;
  final String name;

  const WardenDetailsScreen({required this.email, required this.name});

  @override
  _WardenDetailsScreenState createState() => _WardenDetailsScreenState();
}

class _WardenDetailsScreenState extends State<WardenDetailsScreen> {
  final TextEditingController _contactController = TextEditingController();
  String? _selectedHostel;
  List<Map<String, dynamic>> _hostelList = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableHostels();
  }

  Future<void> _fetchAvailableHostels() async {
    final url = Uri.parse(
        "http://10.0.2.2/hostel_management/get_available_hostels.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _hostelList = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception("Failed to load hostels");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching hostels: $error")),
      );
    }
  }

  Future<void> _saveWardenDetails() async {
    if (_contactController.text.isEmpty || _selectedHostel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    final url =
        Uri.parse("http://10.0.2.2/hostel_management/save_warden_details.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": widget.name,
          "email": widget.email,
          "contact": _contactController.text,
          "hostel_id": _selectedHostel,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"])),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WardenDashboard(email: widget.email),
          ),
        ); // Go back to the previous screen
      } else {
        throw Exception(responseData["message"] ?? "Failed to save details");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving details: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text("Warden Details"),
        backgroundColor: const Color.fromARGB(255, 60, 10, 127),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Warden Name: ${widget.name}",
                style: const TextStyle(fontSize: 16)),
            Text("Warden Email: ${widget.email}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: "Contact"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedHostel,
              hint: const Text("Select Hostel"),
              items: _hostelList
                  .where((hostel) =>
                      hostel["warden_id"] == null) // Filter available hostels
                  .map((hostel) {
                return DropdownMenuItem<String>(
                  value: hostel["hostel_id"].toString(),
                  child: Text(hostel["hostel_name"].toString()),
                  enabled: hostel["warden_id"] == null,
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHostel = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveWardenDetails,
              child: const Text("Save Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 60, 10, 127),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
