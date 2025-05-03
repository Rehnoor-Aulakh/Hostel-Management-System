<?php
header('Content-Type: application/json');
require_once('config.php');

$data = json_decode(file_get_contents("php://input"), true);
$year = $conn->real_escape_string($data["year"]);
$gender = $data["gender"];

// Map gender to hostel type
if ($gender == "Male") {
    $gender = "Boys";
} else if ($gender == "Female") {
    $gender = "Girls";
}

$sql = "SELECT uh.hostel_id, uh.hostel_name 
        FROM University_Hostels uh 
        JOIN hostel_allowed_years hay 
        ON uh.hostel_id = hay.hostel_id
        WHERE hay.year_id = $year AND uh.type = '$gender'";

$result = $conn->query($sql);

$hostels = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $hostels[] = $row;
    }
    echo json_encode(["success" => true, "hostels" => $hostels]);
} else {
    echo json_encode(["success" => false, "message" => "No hostels found"]);
}
?>
