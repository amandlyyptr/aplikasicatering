<?php
// Izinkan akses dari mana saja
header("Access-Control-Allow-Origin: *");
// Izinkan semua header
header("Access-Control-Allow-Headers: *");
// Izinkan metode POST
header("Access-Control-Allow-Methods: POST");
// Set jenis konten ke JSON
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

// Ambil data email dari POST
$email = $_POST['email'] ?? '';

if (empty($email)) {
    echo json_encode(['success' => false, 'message' => 'Email wajib diisi']);
    exit;
}

$sql = "DELETE FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Data berhasil dihapus']);
} else {
    echo json_encode(['success' => false, 'message' => 'Gagal menghapus data: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
