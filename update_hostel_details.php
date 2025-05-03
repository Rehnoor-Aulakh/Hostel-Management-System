<?php
require_once 'config.php';
header("Content-Type: application/json");

$hostel_id = $_POST['hostel_id'];
$hostel_type = $_POST['hostel_type'];
$allowed_year_ids = json_decode($_POST['allowed_year_ids'], true);

// Update hostel type
$stmt = $conn->prepare("UPDATE University_Hostels SET hostel_type = ? WHERE hostel_id = ?");
$stmt->bind_param("si", $hostel_type, $hostel_id);
$stmt->execute();

// Clear existing allowed years
$conn->query("DELETE FROM hostel_allowed_years WHERE hostel_id = $hostel_id");

// Insert new allowed years
$insert_stmt = $conn->prepare("INSERT INTO hostel_allowed_years (hostel_id, year_id) VALUES (?, ?)");
foreach ($allowed_year_ids as $year_id) {
    $insert_stmt->bind_param("ii", $hostel_id, $year_id);
    $insert_stmt->execute();
}

echo json_encode(["status" => "success"]);
?>
