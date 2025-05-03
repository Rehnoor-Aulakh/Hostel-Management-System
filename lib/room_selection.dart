import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'room_details_screen.dart';

class RoomSelection extends StatefulWidget {
  final String email;
  final String hostelId;
  final String blockId;
  final String blockName;

  const RoomSelection({
    required this.email,
    required this.hostelId,
    required this.blockId,
    required this.blockName,
  });

  @override
  State<RoomSelection> createState() => _RoomSelectionState();
}

class _RoomSelectionState extends State<RoomSelection> {
  List<int> floors = [];
  int? selectedFloor;
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    fetchFloors();
  }

  Future<void> fetchFloors() async {
    final url =
        Uri.parse("https://www.certusdiagnostics.in/hostel/get_floors.php");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"hostel_id": widget.hostelId}),
    );
    final data = jsonDecode(response.body);
    setState(() {
      floors = List<int>.from(data["floors"]);
    });
  }

  Future<void> fetchRooms(int floor) async {
    final url =
        Uri.parse("https://www.certusdiagnostics.in/hostel/get_rooms.php");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "block_id": widget.blockId,
        "floor": floor,
      }),
    );
    final data = jsonDecode(response.body);
    setState(() {
      rooms = List<Map<String, dynamic>>.from(data["rooms"]);
      selectedFloor = floor;
    });
  }

  Future<void> assignRoom(String roomId) async {
    final url =
        Uri.parse("https://www.certusdiagnostics.in/hostel/allot_room.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "hostel_id": widget.hostelId,
        "block_id": widget.blockId,
        "room_id": roomId,
      }),
    );

    final data = jsonDecode(response.body);
    final message = data["message"] ?? "Unknown response";

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: data["success"] ? Colors.green : Colors.red,
    ));

    if (data["success"]) {
      // Get student_id from response
      final studentId = data["student_id"];
      if (studentId != null) {
        // Navigate to RoomDetailsScreen with studentId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(studentId: studentId),
          ),
        );
      } else {
        // fallback if student_id missing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Room assigned but student ID not returned"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget buildFloorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: floors.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final floor = floors[index];
        return GestureDetector(
          onTap: () => fetchRooms(floor),
          child: Card(
            color: Color.fromARGB(255, 127, 255, 244),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text("Floor $floor",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget buildRoomGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: rooms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final room = rooms[index];
        int occupancy = room["occupancy"];
        int capacity = room["capacity"];
        String roomId = room["room_id"].toString();
        bool isFull = occupancy >= capacity;

        return GestureDetector(
          onTap: () {
            if (!isFull) {
              assignRoom(roomId);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Room is already full"),
                backgroundColor: Colors.red,
              ));
            }
          },
          child: Card(
            color: isFull ? Colors.red[200] : Colors.green[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(room["room_number"],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("$occupancy / $capacity"),
                ],
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
      backgroundColor: Color.fromARGB(255, 194, 147, 255),
      appBar: AppBar(
        title: Text("Select Floor - ${widget.blockName}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Choose a Floor:", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              buildFloorGrid(),
              if (selectedFloor != null) ...[
                SizedBox(height: 20),
                Text("Rooms on Floor $selectedFloor:",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                buildRoomGrid(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
