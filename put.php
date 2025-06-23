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

// Tangkap data dari POST
$email = $_POST['email'] ?? '';
$nama = $_POST['nama'] ?? '';
$telepon = $_POST['telepon'] ?? '';
$alamat = $_POST['alamat'] ?? '';
$tanggal_lahir = $_POST['tanggal_lahir'] ?? '';

if(empty($email)) {
    echo json_encode(['success' => false, 'message' => 'Email wajib diisi']);
    exit;
}

// Query update
$sql = "UPDATE users SET 
            nama = ?, 
            telepon = ?, 
            alamat = ?, 
            tanggal_lahir = ?
        WHERE email = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $nama, $telepon, $alamat, $tanggal_lahir, $email);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Data berhasil diupdate']);
} else {
    echo json_encode(['success' => false, 'message' => 'Gagal mengupdate data: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
