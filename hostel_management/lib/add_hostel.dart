import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_blocks.dart';

class AddHostelScreen extends StatefulWidget {
  @override
  _AddHostelScreenState createState() => _AddHostelScreenState();
}

class _AddHostelScreenState extends State<AddHostelScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedType;
  int? floors;

  List<dynamic> yearOptions = [];
  List<int> selectedYearIds = [];
  List<int> selectedCapacities = [];

  final List<Map<String, dynamic>> capacityOptions = [
    {'label': '1S', 'value': 1},
    {'label': '2S', 'value': 2},
    {'label': '3S', 'value': 3},
    {'label': '4S', 'value': 4},
  ];

  @override
  void initState() {
    super.initState();
    fetchStudentYears();
  }

  Future<void> fetchStudentYears() async {
    final url =
        Uri.parse("http://10.0.2.2/hostel_management/get_student_years.php");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        yearOptions = jsonDecode(response.body);
      });
    }
  }

  Future<void> _addHostel() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/hostel_management/add_hostel.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text,
        "type": _selectedType,
        "allowed_year_ids": selectedYearIds,
        "allowed_capacities": selectedCapacities,
        "floors": floors,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Hostel added successfully")),
      );

      final hostelId = data["hostel_id"] ?? 0;
      if (hostelId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid hostel ID returned")),
        );
        return;
      } // Make sure backend sends this
      final floorCount = floors!;

      // Clear form
      _nameController.clear();
      setState(() {
        _selectedType = null;
        selectedYearIds.clear();
        selectedCapacities.clear();
        floors = null;
      });

      // Navigate to AddBlocksScreen with hostelId and floorCount
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddBlocksScreen(
            hostelId: hostelId,
            floors: floorCount,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["error"] ?? "Failed to add hostel"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: const Text("Add Hostel"),
        backgroundColor: const Color.fromARGB(255, 60, 10, 127),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Hostel Name"),
            ),
            const SizedBox(height: 20),

            // Hostel Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              hint: const Text("Select Hostel Type"),
              items: ['Boys', 'Girls'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Floors Dropdown
            DropdownButtonFormField<int>(
              value: floors,
              hint: const Text("Select Number of Floors"),
              items: List.generate(12, (index) => index + 1).map((floor) {
                return DropdownMenuItem<int>(
                  value: floor,
                  child: Text("$floor Floor${floor > 1 ? 's' : ''}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  floors = value;
                });
              },
            ),
            const SizedBox(height: 20),

            const Text('Select Allowed Student Years'),
            Expanded(
              child: ListView(
                children: [
                  ...yearOptions.map((year) {
                    int yearId = int.parse(year['id'].toString());
                    String yearLabel = year['year_name'] ?? 'Unknown Year';
                    return CheckboxListTile(
                      title: Text(yearLabel),
                      value: selectedYearIds.contains(yearId),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedYearIds.add(yearId);
                          } else {
                            selectedYearIds.remove(yearId);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const Divider(),
                  const Text("Select Allowed Room Capacities"),
                  ...capacityOptions.map((capacity) {
                    return CheckboxListTile(
                      title: Text(capacity['label']),
                      value: selectedCapacities.contains(capacity['value']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedCapacities.add(capacity['value']);
                          } else {
                            selectedCapacities.remove(capacity['value']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addHostel,
              child: const Text("Save Hostel"),
            ),
          ],
        ),
      ),
    );
  }
}
