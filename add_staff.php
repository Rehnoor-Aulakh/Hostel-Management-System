<?php
require_once "config.php"; 
header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method Not Allowed"]);
    exit;
}

# Check if required fields are provided
$required_fields = ['name', 'role_id', 'contact', 'hostel_id', 'block_id', 'email'];
foreach ($required_fields as $field) {
    if (!isset($_POST[$field]) || empty(trim($_POST[$field]))) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "$field is required"]);
        exit;
    }
}

$name = trim($_POST['name']);
$role_id = trim($_POST['role_id']);
$contact = trim($_POST['contact']);
$hostel_id = trim($_POST['hostel_name']);
$block_id = trim($_POST['block_name']);
$email = trim($_POST['email']);

# Check if the staff email already exists
$sql_check = "SELECT staff_id FROM Staff WHERE email = ?";
$stmt_check = $conn->prepare($sql_check);
$stmt_check->bind_param("s", $email);
$stmt_check->execute();
$result_check = $stmt_check->get_result();

if ($result_check->num_rows > 0) {
    http_response_code(409); // Conflict
    echo json_encode(["success" => false, "message" => "Email already exists"]);
    exit;
}

# Insert new staff into the database
$sql = "INSERT INTO Staff (name, role_id, contact, hostel_id, block_id, email) VALUES (?, ?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sissis", $name, $role_id, $contact, $hostel_id, $block_id, $email);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(["success" => true, "message" => "Staff added successfully", "staff_id" => $stmt->insert_id]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to add staff"]);
}

$stmt_check->close();
$stmt->close();
$conn->close();
?>
