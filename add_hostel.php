<?php
require_once 'config.php';
header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$name = $data["name"];
$type = $data["type"];
$allowed_years = $data["allowed_year_ids"];
$floors = $data["floors"];
$allowed_capacities = $data["allowed_capacities"];

// Use prepared statement for inserting hostel
$stmt = $conn->prepare("INSERT INTO University_Hostels (hostel_name, type, floors) VALUES (?, ?, ?)");
$stmt->bind_param("ssi", $name, $type, $floors);

if ($stmt->execute()) {
    $hostel_id = $stmt->insert_id;

    // Insert allowed years
    $year_stmt = $conn->prepare("INSERT INTO Hostel_Allowed_Years (hostel_id, year_id) VALUES (?, ?)");
    foreach ($allowed_years as $year_id) {
        $year_stmt->bind_param("ii", $hostel_id, $year_id);
        $year_stmt->execute();
    }

    // Insert allowed capacities
    $cap_stmt = $conn->prepare("INSERT INTO Hostel_Capacity (hostel_id, capacity) VALUES (?, ?)");
    foreach ($allowed_capacities as $capacity) {
        $cap_stmt->bind_param("ii", $hostel_id, $capacity);
        $cap_stmt->execute();
    }

    echo json_encode([
        "success" => true,
        "message" => "Hostel and allowed years saved!",
        "hostel_id" => $hostel_id
    ]);
} else {
    echo json_encode(["error" => "Failed to save hostel details"]);
}
?>
