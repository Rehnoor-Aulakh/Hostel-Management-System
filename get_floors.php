<?php
require_once('config.php');
header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);
$hostel_id = $data["hostel_id"];

$sql = "SELECT floors FROM University_Hostels WHERE hostel_id=$hostel_id";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $totalFloors = (int)$row["floors"];

    // Generate floor numbers array
    $floors = range(1, $totalFloors);

    echo json_encode(["success" => true, "floors" => $floors]);
} else {
    echo json_encode(["success" => false, "message" => "No hostels found"]);
}
?>
