<?php
/**
 * API Posko - CRUD Posko Pengungsian
 * Endpoint: /api/posko.php
 */
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

try {
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                $stmt = $db->prepare("SELECT p.*, b.judul as nama_bencana, b.kode_bencana
                    FROM posko p
                    JOIN bencana b ON p.bencana_id = b.id
                    WHERE p.id = ?");
                $stmt->execute([$_GET['id']]);
                $posko = $stmt->fetch();
                if (!$posko) {
                    jsonResponse(['success' => false, 'message' => 'Data posko tidak ditemukan'], 404);
                }

                // Logistik di posko
                $stmt2 = $db->prepare("SELECT * FROM logistik WHERE posko_id = ?");
                $stmt2->execute([$_GET['id']]);
                $posko['logistik'] = $stmt2->fetchAll();

                jsonResponse(['success' => true, 'data' => $posko]);
            } else {
                $where = [];
                $params = [];

                if (!empty($_GET['bencana_id'])) {
                    $where[] = "p.bencana_id = ?";
                    $params[] = $_GET['bencana_id'];
                }
                if (!empty($_GET['status'])) {
                    $where[] = "p.status = ?";
                    $params[] = $_GET['status'];
                }

                $whereClause = count($where) > 0 ? 'WHERE ' . implode(' AND ', $where) : '';

                $stmt = $db->prepare("SELECT p.*, b.judul as nama_bencana, b.kode_bencana
                    FROM posko p
                    JOIN bencana b ON p.bencana_id = b.id
                    $whereClause
                    ORDER BY p.created_at DESC");
                $stmt->execute($params);
                jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            }
            break;

        case 'POST':
            $data = getRequestBody();
            $required = ['bencana_id', 'nama_posko'];
            foreach ($required as $field) {
                if (empty($data[$field])) {
                    jsonResponse(['success' => false, 'message' => "Field '$field' wajib diisi"], 400);
                }
            }

            $stmt = $db->prepare("INSERT INTO posko (bencana_id, nama_posko, alamat, latitude, longitude, kapasitas, jumlah_pengungsi, penanggung_jawab, kontak, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['bencana_id'], $data['nama_posko'], $data['alamat'] ?? null,
                $data['latitude'] ?? null, $data['longitude'] ?? null,
                $data['kapasitas'] ?? 0, $data['jumlah_pengungsi'] ?? 0,
                $data['penanggung_jawab'] ?? null, $data['kontak'] ?? null,
                $data['status'] ?? 'aktif'
            ]);

            jsonResponse(['success' => true, 'message' => 'Data posko berhasil ditambahkan', 'data' => ['id' => (int)$db->lastInsertId()]], 201);
            break;

        case 'PUT':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID posko diperlukan'], 400);
            }
            $data = getRequestBody();
            $id = $_GET['id'];

            $fields = [];
            $values = [];
            $allowed = ['bencana_id', 'nama_posko', 'alamat', 'latitude', 'longitude', 'kapasitas', 'jumlah_pengungsi', 'penanggung_jawab', 'kontak', 'status'];
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
            $stmt = $db->prepare("UPDATE posko SET " . implode(', ', $fields) . " WHERE id = ?");
            $stmt->execute($values);

            jsonResponse(['success' => true, 'message' => 'Data posko berhasil diperbarui']);
            break;

        case 'DELETE':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID posko diperlukan'], 400);
            }
            $stmt = $db->prepare("DELETE FROM posko WHERE id = ?");
            $stmt->execute([$_GET['id']]);
            jsonResponse(['success' => true, 'message' => 'Data posko berhasil dihapus']);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
    }
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
