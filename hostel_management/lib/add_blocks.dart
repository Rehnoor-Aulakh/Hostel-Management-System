import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBlocksScreen extends StatefulWidget {
  final int hostelId;
  final int floors;

  const AddBlocksScreen({required this.hostelId, required this.floors});

  @override
  State<AddBlocksScreen> createState() => _AddBlocksScreenState();
}

class _AddBlocksScreenState extends State<AddBlocksScreen> {
  int numBlocks = 1;
  List<Map<String, dynamic>> blocksData = [];

  final List<String> blockNames =
      List.generate(26, (i) => String.fromCharCode(65 + i)); // A-Z

  @override
  void initState() {
    super.initState();
    updateBlocks(numBlocks);
  }

  void updateBlocks(int value) {
    setState(() {
      numBlocks = value;
      blocksData = List.generate(
          value, (index) => {'capacity': null, 'num_rooms': null});
    });
  }

  Future<void> saveBlocks() async {
    for (int i = 0; i < numBlocks; i++) {
      if (blocksData[i]['capacity'] == null ||
          blocksData[i]['num_rooms'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please fill all details for block ${blockNames[i]}"),
        ));
        return;
      }
    }

    final body = {
      "hostel_id": widget.hostelId,
      "floors": widget.floors,
      "blocks": List.generate(numBlocks, (i) {
        return {
          "block_name": blockNames[i],
          "capacity": blocksData[i]['capacity'],
          "num_rooms": blocksData[i]['num_rooms'],
        };
      }),
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/hostel_management/add_blocks.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String msg = data["message"] ?? data["error"] ?? "Unknown response";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Blocks")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: "Number of Blocks"),
              value: numBlocks,
              items: List.generate(
                  10,
                  (index) => DropdownMenuItem(
                      value: index + 1, child: Text('${index + 1}'))),
              onChanged: (value) {
                if (value != null) updateBlocks(value);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: numBlocks,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Block ${blockNames[index]}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(labelText: "Room Capacity"),
                            onChanged: (value) {
                              blocksData[index]['capacity'] =
                                  int.tryParse(value);
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(labelText: "Number of Rooms"),
                            onChanged: (value) {
                              blocksData[index]['num_rooms'] =
                                  int.tryParse(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(onPressed: saveBlocks, child: Text("Save Blocks")),
          ],
        ),
      ),
    );
  }
}
