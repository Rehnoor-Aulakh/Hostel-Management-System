import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComplaintsDashboard extends StatefulWidget {
  @override
  _ComplaintsDashboardState createState() => _ComplaintsDashboardState();
}

class _ComplaintsDashboardState extends State<ComplaintsDashboard> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = [
    "Cleaning",
    "Electricity",
    "Carpenter",
    "Plumbing",
    "Mess",
    "Gym",
    "Caretaker",
  ];
  Future<void> _submitComplaint() async {
    if (_selectedCategory == null || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please Select a Category and Enter a Message")));
      return;
    } else {
      final url =
          Uri.parse("http://10.0.2.2/hostel_management/submit_complaint.php");
      final response = await http.post(
        url,
        body: json.encode({
          "student_id": 123,
          "complaint_type": _selectedCategory,
          "message": _messageController.text
        }),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data["message"])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit complaint")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text('Complaints Dashboard', textAlign: TextAlign.center),
        backgroundColor: const Color.fromARGB(255, 60, 10, 127),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Complaint Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            DropdownButtonFormField(
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            const Text("Enter Complaint Message",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Describe your issue...",
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: ElevatedButton(
                onPressed: _submitComplaint,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 60, 10, 127),
                    foregroundColor: Colors.white),
                child: const Text("Submit Complaint"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
