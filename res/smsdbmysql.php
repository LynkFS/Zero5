<?php
header("Access-Control-Allow-Origin: *");

$servername = "www.lynkfs.design";
$username = "lynkfsde_admin";
$password = "DeSignAdmin";
$dbname = "lynkfsde_forum";

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);
// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$sql = $_POST['sql_statement']; 

$arr = array();
$result = mysqli_query($conn, $sql);

if (mysqli_num_rows($result) > 0) {
    // output data of each row
    while($row = mysqli_fetch_assoc($result)) {
      $arr[] = $row;
    }
    echo '{"rows":'.json_encode($arr).'}';
} else {
    echo "0 results";
}

mysqli_close($conn);
?>