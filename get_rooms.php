<?php
require_once('config.php');
header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);
$block_id = $data["block_id"];
$floor = $data["floor"];

// First, get the block name
$block_sql = "SELECT block_name FROM Blocks WHERE block_id=$block_id";
$block_result = $conn->query($block_sql);

if ($block_result && $block_result->num_rows > 0) {
    $block_row = $block_result->fetch_assoc();
    $block_name = $block_row["block_name"];

    // Now fetch rooms where room_number starts with blockName-floorNumber (like 'A-3')
    $room_sql = "SELECT * FROM Rooms 
                 WHERE block_id=$block_id 
                 AND room_number LIKE '$block_name-$floor%'";

    $room_result = $conn->query($room_sql);

    $rooms = [];
    if ($room_result && $room_result->num_rows > 0) {
        while ($room_row = $room_result->fetch_assoc()) {
            $rooms[] = [
                "room_id" => $room_row["room_id"],
                "room_number" => $room_row["room_number"],
                "capacity" => (int)$room_row["capacity"],
                "occupancy" => (int)$room_row["occupied"]
            ];
        }
        echo json_encode(["success" => true, "rooms" => $rooms]);
    } else {
        echo json_encode(["success" => false, "message" => "No rooms found on this floor"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Block not found"]);
}
?>
