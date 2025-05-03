import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'room_selection.dart';

class ChooseHostel extends StatefulWidget {
  final String email;
  final int year;
  final String gender;
  const ChooseHostel(
      {required this.email, required this.year, required this.gender});

  @override
  State<ChooseHostel> createState() => _ChooseHostelState();
}

class _ChooseHostelState extends State<ChooseHostel> {
  String? selectedHostelId;
  String? selectedBlockId;
  List<Map<String, dynamic>> hostels = [];
  List<Map<String, dynamic>> blocks = [];
  List<String> availableRooms = [];

  @override
  void initState() {
    super.initState();
    fetchHostels();
  }

  Future<void> fetchHostels() async {
    final url = Uri.parse(
        "https://www.certusdiagnostics.in/hostel/get_hostels_by_year.php");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"year": widget.year, "gender": widget.gender}));

    final data = jsonDecode(response.body);
    setState(() {
      hostels = List<Map<String, dynamic>>.from(data["hostels"]);
    });
  }

  Future<void> fetchBlocks(String hostelId) async {
    final url = Uri.parse(
        "https://www.certusdiagnostics.in/hostel/get_blocks_by_hostel.php");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"hostel_id": hostelId}));
    final data = jsonDecode(response.body);
    setState(() {
      blocks = List<Map<String, dynamic>>.from(data["blocks"]);
    });
  }

  Widget buildHostelDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedHostelId,
      hint: Text("Select Hostel"),
      items: hostels
          .map((hostel) => DropdownMenuItem(
                value: hostel["hostel_id"].toString(),
                child: Text(hostel["hostel_name"]),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedHostelId = value!;
          blocks = [];
        });
        fetchBlocks(value!);
      },
    );
  }

  Widget buildBlockGrid() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: blocks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 1.4),
      itemBuilder: (context, index) {
        final block = blocks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomSelection(
                  email: widget.email,
                  hostelId: selectedHostelId!,
                  blockId: block["block_id"].toString(),
                  blockName: block["block_name"],
                ),
              ),
            );
          },
          child: Card(
            color: Colors.deepPurple[100],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      block["block_name"],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text("Capacity: ${block["capacity"]}S")
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 177, 138, 228),
      appBar: AppBar(
        title: Text("Choose Hostel"),
        backgroundColor: Color.fromARGB(255, 60, 10, 127),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildHostelDropdown(),
            SizedBox(height: 20),
            if (blocks.isNotEmpty)
              Text("Select a Block:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            if (blocks.isNotEmpty) buildBlockGrid(),
          ],
        ),
      ),
    );
  }
}
