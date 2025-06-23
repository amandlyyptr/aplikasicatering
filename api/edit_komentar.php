<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

$host = "localhost";
$user = "root";
$pass = "";
$db   = "db_pemesanan";

$conn = mysqli_connect($host, $user, $pass, $db);
if (!$conn) {
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi gagal: " . mysqli_connect_error()
    ]);
    exit;
}

// Gunakan isset agar tidak error jika tidak ada POST
$id = isset($_POST['id_komentar']) ? $_POST['id_komentar'] : null;
$komentar = isset($_POST['komentar']) ? $_POST['komentar'] : null;

if (!$id || !$komentar) {
    echo json_encode([
        "status" => "error",
        "message" => "id_komentar atau komentar tidak dikirim"
    ]);
    exit;
}

// UPDATE berdasarkan kolom `id`
$query = "UPDATE komentar SET komentar = '$komentar' WHERE id = '$id'";

if (mysqli_query($conn, $query)) {
    echo json_encode([
        "status" => "success",
        "message" => "Komentar berhasil diperbarui"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal memperbarui komentar: " . mysqli_error($conn)
    ]);
}

mysqli_close($conn);
?>
