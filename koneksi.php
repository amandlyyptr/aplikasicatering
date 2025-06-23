<?php
$host = "localhost";
$user = "root";
$password = "";
$db = "user_akun";

// Membuat koneksi
$conn = new mysqli($host, $user, $password, $db);

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Koneksi gagal: " . $conn->connect_error
    ]));
}
?>
