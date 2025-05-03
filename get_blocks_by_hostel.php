<?php
    require_once('config.php');
    header('Content-Type: application/json');

    $input = json_decode(file_get_contents("php://input"), true);
    $hostel_id = $input["hostel_id"];

    $response = array();

    $blockQuery="SELECT block_id, block_name FROM Blocks where hostel_id=$hostel_id";

    $blockResult = mysqli_query($conn, $blockQuery);

    if($blockResult)
    {
        $blocks=array();
        while($block=mysqli_fetch_assoc($blockResult))
        {
            $block_id=$block["block_id"];

            //fetch capacity from the rooms table given the block id
            $capacityQuery="SELECT capacity FROM Rooms where block_id=$block_id LIMIT 1";
            $capacityResult=mysqli_query($conn,$capacityQuery);
            $capacityRow = mysqli_fetch_assoc($capacityResult);
            $capacity = $capacityRow ? $capacityRow["capacity"] : "N/A";

            $blocks[]=array(
                "block_id"=>$block["block_id"],
                "block_name"=>$block["block_name"],
                "capacity"=>$capacity
            );

        }
        $response["success"]=true;
        $response["blocks"]=$blocks;


    }
    else
    {
        $response['success']=false;
        $response["message"] = "Query failed: " . mysqli_error($conn);
    }

    echo json_encode($response);

?>