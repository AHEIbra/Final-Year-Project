<?php

require "init.php";

$wifi_ID = $_POST["wifiID"];
$name_ = $_POST["name"];
$level_ = $_POST["level"];

$sql_query = "insert into wifiValues values('".$wifi_ID."', '".$name_."', '".$level_."');";

if(mysqli_query($con,$sql_query))
{
    echo "<h3> Data Insertion Success </h3>";
}

else
{
    echo "Data Insertion Error" .mysqli_error($con);
}

?>