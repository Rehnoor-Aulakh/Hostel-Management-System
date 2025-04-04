<?php
require_once "config.php"; 
header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method Not Allowed"]);
    exit;
}

if (!isset($_POST['role_name']) || empty(trim($_POST['role_name']))) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Role name is required"]);
    exit;
}

$roleName = trim($_POST['role_name']);

# Check if the role already exists
$sql_check = "SELECT role_id FROM Roles WHERE role_name = ?";
$stmt_check = $conn->prepare($sql_check);
$stmt_check->bind_param("s", $roleName);
$stmt_check->execute();
$result_check = $stmt_check->get_result();

if ($result_check->num_rows > 0) {
    http_response_code(409); // Conflict
    echo json_encode(["success" => false, "message" => "Role already exists"]);
    exit;
}

# Insert new role into the database
$sql = "INSERT INTO Roles (role_name) VALUES (?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $roleName);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(["success" => true, "message" => "Role added successfully", "role_id" => $stmt->insert_id]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to add role"]);
}

$stmt_check->close();
$stmt->close();
$conn->close();
?>
