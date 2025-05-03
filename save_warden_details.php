<?php
require_once 'config.php';
header('Content-Type: application/json');

// Read the incoming JSON data
$data = json_decode(file_get_contents("php://input"), true);

// Check if data is valid
if (!isset($data["name"], $data["email"], $data["contact"], $data["hostel_id"])) {
    echo json_encode(["error" => "Missing required fields"]);
    exit();
}

$name = $data["name"];
$email = $data["email"];
$contact = $data["contact"];
$hostel_id = $data["hostel_id"];

// Prepare and execute the first query
$sql = "INSERT INTO Wardens (name, contact, email, hostel_id) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssi", $name, $contact, $email, $hostel_id);

if ($stmt->execute()) {
    $warden_id = $stmt->insert_id;

    // Update University_Hostels table
    $update_sql = "UPDATE University_Hostels SET warden_id = ? WHERE hostel_id = ?";
    $update_stmt = $conn->prepare($update_sql);
    $update_stmt->bind_param("ii", $warden_id, $hostel_id);

    if ($update_stmt->execute()) {
        echo json_encode(["message" => "Warden details saved successfully"]);
    } else {
        echo json_encode(["error" => "Failed to update hostel with warden_id"]);
    }
    $update_stmt->close();
} else {
    echo json_encode(["error" => "Failed to insert warden details"]);
}

$stmt->close();
$conn->close();
?>
