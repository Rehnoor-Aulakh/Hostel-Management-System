import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_hostels.dart';

class UpdateHostel extends StatefulWidget {
  @override
  _UpdateHostelState createState() => _UpdateHostelState();
}

class _UpdateHostelState extends State<UpdateHostel> {
  List<dynamic> hostels = [];
  int? selectedHostelId;

  @override
  void initState() {
    super.initState();
    fetchHostels();
  }

  Future<void> fetchHostels() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2/hostel_management/get_available_hostels.php'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        hostels = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch hostels")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text("Update Hostel"),
        backgroundColor: const Color.fromARGB(255, 60, 10, 127),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Select From Available Hostels"),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedHostelId,
              hint: const Text("Choose a hostel"),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: hostels.map<DropdownMenuItem<int>>((hostel) {
                final id = int.parse(hostel['hostel_id']);
                final name = hostel['hostel_name'];
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedHostelId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text("Selected Hostel ID: $selectedHostelId"),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: selectedHostelId != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditHostels(
                            hostelId: selectedHostelId!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text("Edit Hostel Details"),
            ),
          ],
        ),
      ),
    );
  }
}
