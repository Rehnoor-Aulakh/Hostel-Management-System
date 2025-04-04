<?php
require_once "config.php";
header("Content-Type: application/json");

// Check connection
if ($conn->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["message" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['name'], $data['email'], $data["password"], $data["role"])) {
    http_response_code(400); // Bad Request
    echo json_encode(["message" => "Invalid Input"]);
    exit();
}

$name = $conn->real_escape_string($data['name']);
$email = $conn->real_escape_string($data['email']);
$role = $conn->real_escape_string($data["role"]);
$password = $conn->real_escape_string($data["password"]);

// Check if email exists
$query = "SELECT * FROM Users WHERE email = '$email'";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    http_response_code(409); // Conflict
    echo json_encode(["message" => "Email Already Exists"]);
    exit();
}

// Insert new user
$insertQuery = "INSERT INTO Users (name, email, password, role) VALUES ('$name', '$email', '$password', '$role')";
if ($conn->query($insertQuery) === TRUE) {
    http_response_code(200); // Success
    echo json_encode(["message" => "User registered Successfully!"]);
} else {
    http_response_code(500); // Internal Server Error
    echo json_encode(["message" => "Registration Failed: " . $conn->error]);
}
exit();
?>
