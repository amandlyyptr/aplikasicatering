<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

// Pastikan metode adalah POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "success" => false,
        "message" => "Metode tidak diizinkan"
    ]);
    exit;
}

// Ambil data dari request POST
$nama           = $_POST['nama'] ?? '';
$email          = $_POST['email'] ?? '';
$telepon        = $_POST['telepon'] ?? '';
$alamat         = $_POST['alamat'] ?? '';
$tanggal_lahir  = $_POST['tanggal_lahir'] ?? '';

// Validasi data
if ($nama == '' || $email == '') {
    echo json_encode([
        "success" => false,
        "message" => "Nama dan Email wajib diisi!"
    ]);
    exit;
}

// Query insert
$sql = "INSERT INTO users (nama, email, telepon, alamat, tanggal_lahir) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $nama, $email, $telepon, $alamat, $tanggal_lahir);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Data berhasil ditambahkan"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Gagal menambahkan data: " . $stmt->error
    ]);
}


$stmt->close();
$conn->close();
?>
