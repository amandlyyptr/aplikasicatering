<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$host = "localhost";
$user = "root";
$pass = "";
$db = "db_pemesanan";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
  echo json_encode(["success" => false, "message" => "Koneksi gagal"]);
  exit;
}

$id = $_POST['id'] ?? '';
if (!$id) {
  echo json_encode(["success" => false, "message" => "ID kosong"]);
  exit;
}

$stmt = $conn->prepare("DELETE FROM history_pemesanan WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();

if ($stmt->affected_rows > 0) {
  echo json_encode(["success" => true, "message" => "Data berhasil dihapus"]);
} else {
  echo json_encode(["success" => false, "message" => "ID tidak ditemukan"]);
}

$stmt->close();
$conn->close();
?>
