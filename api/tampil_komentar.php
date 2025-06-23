<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

// Koneksi database
$koneksi = new mysqli("localhost", "root", "", "db_pemesanan");

// Cek koneksi gagal
if ($koneksi->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi gagal: " . $koneksi->connect_error
    ]);
    exit;
}

// Cek apakah menu_id tersedia
if (!isset($_GET['menu_id'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Parameter menu_id tidak ditemukan"
    ]);
    exit;
}

$menu_id = $koneksi->real_escape_string($_GET['menu_id']); // Hindari SQL Injection

$sql = "SELECT * FROM komentar WHERE menu_id = '$menu_id' ORDER BY tanggal DESC";
$result = $koneksi->query($sql);

if (!$result) {
    echo json_encode([
        "status" => "error",
        "message" => "Query gagal: " . $koneksi->error
    ]);
    exit;
}

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

// Respons sukses
echo json_encode($data);
$koneksi->close();
?>
