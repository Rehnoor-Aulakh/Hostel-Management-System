<?php
require_once 'config.php';
header('Content-Type: application/json');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["error" => "Invalid input data"]);
    exit();
}

$name = $data["name"] ?? null;
$type = $data["type"] ?? null;
$allowed_years = $data["allowed_year_ids"] ?? [];
$floors = $data["floors"] ?? null;
$allowed_capacities = $data["allowed_capacities"] ?? [];

if (!$name || !$type || !$floors) {
    echo json_encode(["error" => "Missing required fields"]);
    exit();
}

$stmt = $conn->prepare("INSERT INTO University_Hostels (hostel_name, type, floors) VALUES (?, ?, ?)");
$stmt->bind_param("ssi", $name, $type, $floors);

if ($stmt->execute()) {
    $hostel_id = $stmt->insert_id;

    // Insert allowed years
    if (!empty($allowed_years)) {
        $year_stmt = $conn->prepare("INSERT INTO hostel_allowed_years (hostel_id, year_id) VALUES (?, ?)");
        foreach ($allowed_years as $year_id) {
            $year_stmt->bind_param("ii", $hostel_id, $year_id);
            $year_stmt->execute();
        }
    }

    // Insert allowed capacities
    if (!empty($allowed_capacities)) {
        $cap_stmt = $conn->prepare("INSERT INTO hostel_capacity (hostel_id, capacity) VALUES (?, ?)");
        foreach ($allowed_capacities as $capacity) {
            $cap_stmt->bind_param("ii", $hostel_id, $capacity);
            $cap_stmt->execute();
        }
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
