<?php
header("Content-Type: application/json");
require_once("config.php");

ini_set('display_errors', 1);
error_reporting(E_ALL);

// Log to file for debugging
$log_file = "/tmp/room_debug.log";
file_put_contents($log_file, "Script started\n", FILE_APPEND);

// Get and parse JSON input
$data = json_decode(file_get_contents("php://input"), true);
if ($data === null) {
    echo json_encode(["error" => "Invalid JSON"]);
    exit();
}

$hostel_id = $data["hostel_id"] ?? null;
$floors = $data["floors"] ?? null;
$blocks = $data["blocks"] ?? [];

if (!$hostel_id || !$floors || empty($blocks)) {
    echo json_encode(["error" => "Missing required fields"]);
    exit();
}

$total_inserted = 0;

foreach ($blocks as $block) {
    $block_name = $block["block_name"] ?? null;
    $capacity = $block["capacity"] ?? null;
    $num_rooms = $block["num_rooms"] ?? null;

    if (!$block_name || !$capacity || !$num_rooms) {
        echo json_encode(["error" => "Block data missing"]);
        exit();
    }

    // Insert block
    $stmt = $conn->prepare("INSERT INTO Blocks (hostel_id, block_name) VALUES (?, ?)");
    $stmt->bind_param("is", $hostel_id, $block_name);
    if (!$stmt->execute()) {
        echo json_encode(["error" => "Block insert failed: " . $stmt->error]);
        exit();
    }
    $block_id = $stmt->insert_id;
    $stmt->close();

    file_put_contents($log_file, "Block $block_name inserted with ID $block_id\n", FILE_APPEND);

    // Now insert num_rooms rooms per floor
    for ($floor = 1; $floor <= $floors; $floor++) {
        for ($i = 1; $i <= $num_rooms; $i++) {
            $room_number = $block_name . '-' . ($floor * 100 + $i);

            $stmt = $conn->prepare("INSERT INTO Rooms (block_id, room_number, capacity, occupied) VALUES (?, ?, ?, 0)");
            $stmt->bind_param("isi", $block_id, $room_number, $capacity);

            if ($stmt->execute()) {
                $total_inserted++;
                file_put_contents($log_file, "Inserted room: $room_number\n", FILE_APPEND);
            } else {
                file_put_contents($log_file, "Failed to insert room: $room_number - " . $stmt->error . "\n", FILE_APPEND);
            }

            $stmt->close();
        }
    }
}

echo json_encode(["message" => "Inserted $total_inserted rooms"]);
?>
