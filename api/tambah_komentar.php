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
    die("Koneksi gagal: " . mysqli_connect_error());
}

$menu_id = $_POST['menu_id'] ?? '';
$uid = $_POST['uid'] ?? '';
$nama_user = $_POST['nama_user'] ?? '';
$komentar = $_POST['komentar'] ?? '';
$tanggal = date("Y-m-d H:i:s");

// Debug: Tampilkan data yg diterima
echo "Diterima: menu_id=$menu_id, uid=$uid, nama_user=$nama_user, komentar=$komentar\n";

if ($menu_id == '' || $uid == '' || $komentar == '') {
    echo "Data tidak lengkap";
    exit;
}

$query = "INSERT INTO komentar (menu_id, uid, nama_user, komentar, tanggal)
          VALUES ('$menu_id', '$uid', '$nama_user', '$komentar', '$tanggal')";

if (mysqli_query($conn, $query)) {
    echo "Komentar berhasil ditambahkan";
} else {
    echo "Gagal: " . mysqli_error($conn);
}

mysqli_close($conn);
?>
