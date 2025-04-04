<?php
    require_once 'config.php';
    header("Content-Type: application/json");
    if ($conn->connect_error) {
        die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
    }
    
    $sql="SELECT hostel_id, hostel_name,warden_id FROM University_Hostels";
    $result=$conn->query($sql);
    $hostels=[];
    if($result->num_rows>0){
        while ($row = $result->fetch_assoc()) {
            $hostels[] = $row;
        }
    }

    echo json_encode($hostels);



?>