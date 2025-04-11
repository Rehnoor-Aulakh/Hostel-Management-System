import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditHostels extends StatefulWidget {
  final int hostelId;

  EditHostels({required this.hostelId});

  @override
  _EditHostelsState createState() => _EditHostelsState();
}

class _EditHostelsState extends State<EditHostels> {
  String? hostelType;
  List<dynamic> allYears = [];
  Set<int> selectedYearIds = {};

  final List<String> hostelTypes = ['Boys', 'Girls'];

  @override
  void initState() {
    super.initState();
    fetchHostelDetails();
  }

  Future<void> fetchHostelDetails() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/hostel_management/get_hostel_details.php'),
      body: {'hostel_id': widget.hostelId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        hostelType = data['hostel_type'];
        allYears = data['all_years'];
        selectedYearIds = Set<int>.from(data['allowed_year_ids']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch hostel details")),
      );
    }
  }

  Future<void> updateHostelDetails() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/hostel_management/update_hostel_details.php'),
      body: {
        'hostel_id': widget.hostelId.toString(),
        'hostel_type': hostelType ?? '',
        'allowed_year_ids': jsonEncode(selectedYearIds.toList()),
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hostel details updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update hostel details")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating hostel details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Hostel'),
        backgroundColor: const Color.fromARGB(255, 60, 10, 127),
      ),
      backgroundColor: const Color.fromARGB(255, 177, 138, 228),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: allYears.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hostel Type:", style: TextStyle(fontSize: 16)),
                    DropdownButtonFormField<String>(
                      value: hostelType,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items: hostelTypes
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          hostelType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text("Allowed Student Years:",
                        style: TextStyle(fontSize: 16)),
                    ...allYears.map((year) {
                      return CheckboxListTile(
                        title: Text(year['year_name']),
                        value: selectedYearIds.contains(year['year_id']),
                        onChanged: (_) {
                          setState(() {
                            if (selectedYearIds.contains(year['year_id'])) {
                              selectedYearIds.remove(year['year_id']);
                            } else {
                              selectedYearIds.add(year['year_id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: updateHostelDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 60, 10, 127),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text("Update Hostel",
                            style: TextStyle(fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
