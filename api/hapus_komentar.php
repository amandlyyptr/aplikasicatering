<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST");

$koneksi = new mysqli("localhost", "root", "", "db_pemesanan");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['id'])) {
        $id = $_POST['id'];

        $sql = "DELETE FROM komentar WHERE id = '$id'";
        $result = $koneksi->query($sql);

        if ($result) {
            echo json_encode(["status" => "success", "message" => "Komentar berhasil dihapus"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal menghapus komentar"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "ID komentar tidak ditemukan dalam POST"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Metode tidak valid"]);
}

$koneksi->close();
?>
