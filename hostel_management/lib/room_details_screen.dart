import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoomDetailsScreen extends StatefulWidget {
  final int studentId;
  RoomDetailsScreen({required this.studentId});
  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  Map<String, dynamic>? roomDetails;
  List<dynamic> roommates = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchRoomDetails();
  }

  Future<void> fetchRoomDetails() async {
    final url =
        Uri.parse("http://10.0.2.2/hostel_management/get_room_details.php");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"student_id": widget.studentId}));
    final data = jsonDecode(response.body);

    //now we have to change the state to set loading false
    setState(() {
      if (data.containsKey("room_details")) {
        roomDetails = data["room_details"];
        roommates = data["roommates"];
      } else {
        roomDetails = {"error": "Room not found"};
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 177, 138, 228),
        appBar: AppBar(
          title: const Text('Student Dashboard', textAlign: TextAlign.center),
          backgroundColor: const Color.fromARGB(255, 60, 10, 127),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : roomDetails!.containsKey("error")
                  ? Text(roomDetails!["error"],
                      style: const TextStyle(color: Colors.red))
                  : Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text(
                                "Room Number",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text(roomDetails!["room_number"].toString()),
                            ),
                            ListTile(
                              title: const Text(
                                "Capacity",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text(roomDetails!["capacity"].toString()),
                            ),
                            ListTile(
                              title: const Text(
                                "Hostel",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text(roomDetails!["hostel_name"].toString()),
                            ),
                            ListTile(
                              title: const Text(
                                "Block",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text(roomDetails!["block_name"].toString()),
                            ),
                            Text("Roommates:",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            ...roommates.map((roommate) => ListTile(
                                  title: Text(roommate['name']),
                                  subtitle:
                                      Text("ID: ${roommate['student_id']}"),
                                )),
                          ],
                        ),
                      ),
                    ),
        ));
  }
}
