<?php
require_once "config.php";
header("Content-Type: application/json");

if ($conn->connect_error) {
    echo json_encode(["message" => "Connection failed: " . $conn->connect_error]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email'], $data['password'])) {
    echo json_encode(["message" => "Invalid Input"]);
    exit;
}

$email = $data['email'];
$password = $data['password'];

// Use a parameterized query to prevent SQL injection
$query = "SELECT * FROM Users WHERE email = ? AND password = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ss", $email, $password); // Bind both email and password
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode(["message" => "Incorrect Email or Password"]);
    exit;
}

$user = $result->fetch_assoc();

// Successful login
echo json_encode([
    "message" => "Login successful",
    "user" => [
        "id" => $user["id"],
        "name" => $user["name"],
        "email" => $user["email"],
        "role" => $user["role"]
    ]
]);
exit;
?>
