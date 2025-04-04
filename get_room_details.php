<?php
require_once "config.php";
header("Content-Type: application/json");

if ($conn->connect_error) {
    echo json_encode(["message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

$data = json_decode(file_get_contents("php://input"), true);
if (!isset($data['student_id'])) {
    echo json_encode(["error" => "Student ID is required"]);
    exit;
}

$studentID = $data["student_id"];

// Step 1: Get Room Details
$sql = "SELECT r.room_number, r.capacity, h.hostel_name, b.block_name, r.room_id
        FROM Rooms r 
        JOIN Blocks b ON r.block_id = b.block_id
        JOIN University_Hostels h ON b.hostel_id = h.hostel_id
        JOIN Students s ON s.room_id = r.room_id
        WHERE s.student_id = $studentID";  

$stmt = $conn->prepare($sql);
$stmt->execute();
$result = $stmt->get_result();
$room = $result->fetch_assoc();

if (!$room) {
    echo json_encode(["error" => "Room details not found for student_id: " . $studentID]);
    exit;
}

$roomID = $room["room_id"];

// Step 2: Get Roommates (excluding the current student)
$sql2 = "SELECT student_id, name FROM Students WHERE room_id = $roomID AND student_id != $studentID";
$stmt2 = $conn->prepare($sql2);
$stmt2->execute();
$result2 = $stmt2->get_result();

$roommates = [];
while ($row = $result2->fetch_assoc()) {
    $roommates[] = $row;
}

// Final Output
echo json_encode([
    "room_details" => $room,
    "roommates" => $roommates
]);
?>
