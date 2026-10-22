<?php
/**
 * API Relawan - CRUD Data Relawan
 * Endpoint: /api/relawan.php
 */
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

try {
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                $stmt = $db->prepare("SELECT r.*, b.judul as nama_bencana
                    FROM relawan r
                    JOIN bencana b ON r.bencana_id = b.id
                    WHERE r.id = ?");
                $stmt->execute([$_GET['id']]);
                $data = $stmt->fetch();
                if (!$data) {
                    jsonResponse(['success' => false, 'message' => 'Data relawan tidak ditemukan'], 404);
                }
                jsonResponse(['success' => true, 'data' => $data]);
            } else {
                $where = [];
                $params = [];
                if (!empty($_GET['bencana_id'])) {
                    $where[] = "r.bencana_id = ?";
                    $params[] = $_GET['bencana_id'];
                }
                if (!empty($_GET['status'])) {
                    $where[] = "r.status = ?";
                    $params[] = $_GET['status'];
                }
                if (!empty($_GET['organisasi'])) {
                    $where[] = "r.organisasi LIKE ?";
                    $params[] = '%' . $_GET['organisasi'] . '%';
                }

                $whereClause = count($where) > 0 ? 'WHERE ' . implode(' AND ', $where) : '';
                $stmt = $db->prepare("SELECT r.*, b.judul as nama_bencana
                    FROM relawan r
                    JOIN bencana b ON r.bencana_id = b.id
                    $whereClause
                    ORDER BY r.tanggal_bergabung DESC");
                $stmt->execute($params);
                jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            }
            break;

        case 'POST':
            $data = getRequestBody();
            $required = ['bencana_id', 'nama', 'tanggal_bergabung'];
            foreach ($required as $field) {
                if (empty($data[$field])) {
                    jsonResponse(['success' => false, 'message' => "Field '$field' wajib diisi"], 400);
                }
            }

            $stmt = $db->prepare("INSERT INTO relawan (bencana_id, nama, nik, organisasi, keahlian, no_telepon, email, tanggal_bergabung, tanggal_selesai, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['bencana_id'], $data['nama'], $data['nik'] ?? null,
                $data['organisasi'] ?? null, $data['keahlian'] ?? null,
                $data['no_telepon'] ?? null, $data['email'] ?? null,
                $data['tanggal_bergabung'], $data['tanggal_selesai'] ?? null,
                $data['status'] ?? 'aktif'
            ]);

            jsonResponse(['success' => true, 'message' => 'Data relawan berhasil ditambahkan', 'data' => ['id' => (int)$db->lastInsertId()]], 201);
            break;

        case 'PUT':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID relawan diperlukan'], 400);
            }
            $data = getRequestBody();
            $id = $_GET['id'];

            $fields = [];
            $values = [];
            $allowed = ['bencana_id', 'nama', 'nik', 'organisasi', 'keahlian', 'no_telepon', 'email', 'tanggal_bergabung', 'tanggal_selesai', 'status'];
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
            $stmt = $db->prepare("UPDATE relawan SET " . implode(', ', $fields) . " WHERE id = ?");
            $stmt->execute($values);

            jsonResponse(['success' => true, 'message' => 'Data relawan berhasil diperbarui']);
            break;

        case 'DELETE':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID relawan diperlukan'], 400);
            }
            $stmt = $db->prepare("DELETE FROM relawan WHERE id = ?");
            $stmt->execute([$_GET['id']]);
            jsonResponse(['success' => true, 'message' => 'Data relawan berhasil dihapus']);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
    }
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
