<?php

require "init.php";

$curr_device = $_POST["Curr_Device"];
$found_device = $_POST["Found_Device"];
$rssi = $_POST["RSSI"];
$distance = $_POST["Distance"];
$orientation = $_POST["Orientation"];
$worientation = $_POST["wOrientation"];
$xorientation = $_POST["xOrientation"];
$yorientation = $_POST["yOrientation"];
$zorientation = $_POST["zOrientation"];
$time = $_POST["Time"];

$sql_query = "INSERT INTO bluetoothTestOrientation (`Curr_Device`, `Found_Device`, `RSSI`, `Distance`, `Orientation`, `wOrientation`, `xOrientation`, `yOrientation`, `zOrientation`, `Time`) values('".$curr_device."', '".$found_device."', '".$rssi."','".$distance."','".$orientation."','".$worientation."','".$xorientation."','".$yorientation."','".$zorientation."', '".$time."');";

if(mysqli_query($con,$sql_query))
{
    echo "<h3> Data Insertion Success </h3>";
}

else
{
    echo "Data Insertion Error" .mysqli_error($con);
}

?>