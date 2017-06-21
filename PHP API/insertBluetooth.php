<?php

require "init.php";

$curr_device = $_POST["Curr_Device"];
$found_device = $_POST["Found_Device"];
$rssi = $_POST["RSSI"];
$distance = $_POST["Distance"];
$time = $_POST["Time"];

$sql_query = "INSERT INTO bluetoothTable (`Curr_Device`, `Found_Device`, `RSSI`, `Distance`, `Time`) values('".$curr_device."', '".$found_device."', '".$rssi."','".$distance."', '".$time."');";

if(mysqli_query($con,$sql_query))
{
    echo "<h3> Data Insertion Success </h3>";
}

else
{
    echo "Data Insertion Error" .mysqli_error($con);
}

?>