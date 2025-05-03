<?php
    require_once 'config.php';
    $sql="select * from student_years";
    $result=$conn->query($sql);
    $years=[];
    while($row = $result->fetch_assoc()) {
        $years[] = $row;
    }
    echo json_encode($years);
?>