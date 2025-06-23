<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if (!isset($_GET['uid']) || empty($_GET['uid'])) {
  http_response_code(400);
  echo json_encode(["error" => "Missing parameters"]);
  exit();
}

$uid = $_GET['uid'];

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "db_pemesanan";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  http_response_code(500);
  echo json_encode(["error" => "Database connection failed"]);
  exit();
}

$sql = "SELECT id, nama_makanan, waktu_pesan FROM history_pemesanan WHERE uid = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $uid);
$stmt->execute();
$result = $stmt->get_result();

$history = [];
while ($row = $result->fetch_assoc()) {
  $history[] = $row;
}

echo json_encode($history);

$stmt->close();
$conn->close();
?>
