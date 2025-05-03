<?php
require_once 'config.php';
header("Content-Type: application/json");

$hostel_id = $data["hostel_id"];
$response = [];

// Fetch hostel type
$hostel_sql = "SELECT hostel_type FROM University_Hostels WHERE hostel_id = ?";
$stmt = $conn->prepare($hostel_sql);
$stmt->bind_param("i", $hostel_id);
$stmt->execute();
$hostel_result = $stmt->get_result()->fetch_assoc();
$response['hostel_type'] = $hostel_result['hostel_type'];

// Fetch all years
$years_query = "SELECT year_id, year_name FROM student_years";
$years_result = $conn->query($years_query);
$response['all_years'] = [];
while ($row = $years_result->fetch_assoc()) {
    $response['all_years'][] = [
        "year_id" => $row['year_id'],
        "year_name" => $row['year_name']
    ];
}

// Fetch allowed year_ids
$allowed_years_sql = "SELECT year_id FROM hostel_allowed_years WHERE hostel_id = ?";
$stmt2 = $conn->prepare($allowed_years_sql);
$stmt2->bind_param("i", $hostel_id);
$stmt2->execute();
$allowed_result = $stmt2->get_result();
$response['allowed_year_ids'] = [];
while ($row = $allowed_result->fetch_assoc()) {
    $response['allowed_year_ids'][] = (int)$row['year_id'];
}

echo json_encode($response);
?>
