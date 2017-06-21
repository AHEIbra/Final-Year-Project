<?php

require "init.php";

$curr_device = $_POST["Curr_Device"];
$location = $_POST["Location"];
$wifi_ID = $_POST["wifiID"];
$bssid = $_POST["BSSID"];
$rssi = $_POST["RSSI"];
$time = $_POST["Time"];

$sql_query = "INSERT INTO wifiTable (`Curr_Device`, `Location`, `wifiID`, `BSSID`, `RSSI`, `Time`) values('".$curr_device."', '".$location."', '".$wifi_ID."','".$bssid."','".$rssi."','".$time."');";

if(mysqli_query($con,$sql_query))
{
    echo "<h3> Data Insertion Success </h3>";
}

else
{
    echo "Data Insertion Error" .mysqli_error($con);
}

?>