<?php
header('Content-Type: application/json');
require_once('config.php');

$data = json_decode(file_get_contents("php://input"), true);
$email = $conn->real_escape_string($data["email"]);
$hostel_id = $conn->real_escape_string($data["hostel_id"]);
$block_id = $conn->real_escape_string($data["block_id"]);
$room_id = $conn->real_escape_string($data["room_id"]);

// Step 1: Check if room exists and has space
$check_sql = "SELECT capacity, occupied FROM Rooms WHERE room_id = '$room_id'";
$result = $conn->query($check_sql);

if ($result && $result->num_rows > 0) {
    $room = $result->fetch_assoc();

    if ((int)$room['occupied'] >= (int)$room['capacity']) {
        echo json_encode(["success" => false, "message" => "Room is already full"]);
        exit;
    }

    // Step 2: Check if student already exists
    $student_sql = "SELECT student_id FROM Students WHERE student_email = '$email'";
    $student_result = $conn->query($student_sql);

    if ($student_result && $student_result->num_rows > 0) {
        $student = $student_result->fetch_assoc();
        $student_id = $student['student_id'];

        // Step 3: Update existing student's room
        $update_student_sql = "UPDATE Students 
                               SET room_id = '$room_id', block_id = '$block_id', hostel_id = '$hostel_id'
                               WHERE student_id = '$student_id'";
        if ($conn->query($update_student_sql)) {
            // Step 4: Update room occupancy
            $conn->query("UPDATE Rooms SET occupied = occupied + 1 WHERE room_id = '$room_id'");
            echo json_encode([
                "success" => true,
                "message" => "Room assigned successfully",
                "student_id" => $student_id
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to update student"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Student not found"]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Room not found"]);
}

$conn->close();
?>
