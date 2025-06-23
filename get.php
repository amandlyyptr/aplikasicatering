<?php
include 'koneksi.php';

$sql = "SELECT * FROM users";
$result = $conn->query($sql);

if (!$result) {
    echo json_encode(["success" => false, "message" => "Query error: " . $conn->error]);
    exit;
}

if ($result->num_rows > 0) {
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(["success" => true, "data" => $data]);
} else {
    echo json_encode(["success" => false, "message" => "Data kosong"]);
}

$conn->close();
?>
