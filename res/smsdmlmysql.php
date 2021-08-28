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
 
// Attempt non-select execution
$sql_statement = $_POST['sql_statement'];
 
if(mysqli_query($conn, $sql_statement)){
    echo "SQL handled successfully.";
} else{
    echo "ERROR: Not able to execute $sql. " . mysqli_error($conn);
}
 
// Close connection
mysqli_close($conn);
?>
