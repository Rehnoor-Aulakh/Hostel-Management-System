<?php
require_once 'config.php';
header("Content-Type: application/json");

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (
    isset($data["email"], $data["name"], $data["age"], $data["gender"], $data["contact"], 
    $data["course"], $data["year"])
) {
    $email = $conn->real_escape_string($data["email"]);
    $name = $conn->real_escape_string($data["name"]);
    $age = intval($data["age"]);
    $gender = $conn->real_escape_string($data["gender"]);
    $contact = $conn->real_escape_string($data["contact"]);
    $course = $conn->real_escape_string($data["course"]);
    $year = intval($data["year"]);


    $sql = "INSERT INTO Students (name, age, gender, contact, email, course, year, admission_date) 
            VALUES ('$name', $age, '$gender', '$contact', '$email', '$course', $year, CURDATE())";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Student details saved successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
}

$conn->close();
?>
