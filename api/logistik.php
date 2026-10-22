<?php
/**
 * API Logistik - CRUD Data Logistik
 * Endpoint: /api/logistik.php
 */
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

try {
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                $stmt = $db->prepare("SELECT l.*, b.judul as nama_bencana, p.nama_posko
                    FROM logistik l
                    JOIN bencana b ON l.bencana_id = b.id
                    LEFT JOIN posko p ON l.posko_id = p.id
                    WHERE l.id = ?");
                $stmt->execute([$_GET['id']]);
                $data = $stmt->fetch();
                if (!$data) {
                    jsonResponse(['success' => false, 'message' => 'Data logistik tidak ditemukan'], 404);
                }
                jsonResponse(['success' => true, 'data' => $data]);
            } else {
                $where = [];
                $params = [];
                if (!empty($_GET['bencana_id'])) {
                    $where[] = "l.bencana_id = ?";
                    $params[] = $_GET['bencana_id'];
                }
                if (!empty($_GET['kategori'])) {
                    $where[] = "l.kategori = ?";
                    $params[] = $_GET['kategori'];
                }
                if (!empty($_GET['status'])) {
                    $where[] = "l.status = ?";
                    $params[] = $_GET['status'];
                }

                $whereClause = count($where) > 0 ? 'WHERE ' . implode(' AND ', $where) : '';
                $stmt = $db->prepare("SELECT l.*, b.judul as nama_bencana, p.nama_posko
                    FROM logistik l
                    JOIN bencana b ON l.bencana_id = b.id
                    LEFT JOIN posko p ON l.posko_id = p.id
                    $whereClause
                    ORDER BY l.tanggal_masuk DESC");
                $stmt->execute($params);
                jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            }
            break;

        case 'POST':
            $data = getRequestBody();
            $required = ['bencana_id', 'nama_barang', 'tanggal_masuk'];
            foreach ($required as $field) {
                if (empty($data[$field])) {
                    jsonResponse(['success' => false, 'message' => "Field '$field' wajib diisi"], 400);
                }
            }

            $stmt = $db->prepare("INSERT INTO logistik (bencana_id, posko_id, nama_barang, kategori, jumlah, satuan, sumber, tanggal_masuk, tanggal_distribusi, status, keterangan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['bencana_id'], $data['posko_id'] ?? null, $data['nama_barang'],
                $data['kategori'] ?? 'lainnya', $data['jumlah'] ?? 0, $data['satuan'] ?? 'unit',
                $data['sumber'] ?? null, $data['tanggal_masuk'], $data['tanggal_distribusi'] ?? null,
                $data['status'] ?? 'tersedia', $data['keterangan'] ?? null
            ]);

            jsonResponse(['success' => true, 'message' => 'Data logistik berhasil ditambahkan', 'data' => ['id' => (int)$db->lastInsertId()]], 201);
            break;

        case 'PUT':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID logistik diperlukan'], 400);
            }
            $data = getRequestBody();
            $id = $_GET['id'];

            $fields = [];
            $values = [];
            $allowed = ['bencana_id', 'posko_id', 'nama_barang', 'kategori', 'jumlah', 'satuan', 'sumber', 'tanggal_masuk', 'tanggal_distribusi', 'status', 'keterangan'];
            foreach ($allowed as $field) {
                if (isset($data[$field])) {
                    $fields[] = "$field = ?";
                    $values[] = $data[$field];
                }
            }
            if (empty($fields)) {
                jsonResponse(['success' => false, 'message' => 'Tidak ada field yang diperbarui'], 400);
            }
            $values[] = $id;
            $stmt = $db->prepare("UPDATE logistik SET " . implode(', ', $fields) . " WHERE id = ?");
            $stmt->execute($values);

            jsonResponse(['success' => true, 'message' => 'Data logistik berhasil diperbarui']);
            break;

        case 'DELETE':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID logistik diperlukan'], 400);
            }
            $stmt = $db->prepare("DELETE FROM logistik WHERE id = ?");
            $stmt->execute([$_GET['id']]);
            jsonResponse(['success' => true, 'message' => 'Data logistik berhasil dihapus']);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
    }
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
