<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');

$uid = $_POST['uid'] ?? '';
$nama = $_POST['nama_makanan'] ?? '';

if (!$uid || !$nama) {
  echo json_encode(['success' => false, 'message' => 'Data kurang']);
  exit;
}

$host = "localhost";
$user = "root";
$pass = "";
$db = "db_pemesanan";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
  echo json_encode(['success' => false, 'message' => 'Koneksi gagal']);
  exit;
}

$stmt = $conn->prepare("INSERT INTO history_pemesanan (uid, nama_makanan, waktu_pesan) VALUES (?, ?, NOW())");
$stmt->bind_param("ss", $uid, $nama);
$stmt->execute();

echo json_encode(['success' => true, 'message' => 'Berhasil disimpan']);

$stmt->close();
$conn->close();
?>
