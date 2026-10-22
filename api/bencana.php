<?php
/**
 * API Bencana - CRUD Kejadian Bencana
 * Endpoint: /api/bencana.php
 */
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

try {
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Detail bencana dengan hierarki wilayah: Indonesia -> Provinsi -> Kabupaten/Kota
                $stmt = $db->prepare("SELECT b.*, jb.nama_jenis, jb.ikon, jb.warna, 
                    COALESCE(i.nama_negara, 'Indonesia') as nama_negara, p.indonesia_id,
                    p.nama_provinsi, kk.nama_kabkota, kk.nama_kabupaten,
                    k.meninggal, k.hilang, k.luka_berat, k.luka_ringan, k.mengungsi,
                    k.rumah_rusak_berat, k.rumah_rusak_sedang, k.rumah_rusak_ringan,
                    k.fasilitas_umum_rusak, k.kerugian_estimasi
                    FROM bencana b
                    JOIN jenis_bencana jb ON b.jenis_bencana_id = jb.id
                    JOIN provinsi p ON b.provinsi_id = p.id
                    LEFT JOIN indonesia i ON p.indonesia_id = i.id
                    LEFT JOIN kabupaten_kota kk ON b.kabkota_id = kk.id
                    LEFT JOIN korban k ON b.id = k.bencana_id
                    WHERE b.id = ?");
                $stmt->execute([$_GET['id']]);
                $bencana = $stmt->fetch();
                
                if (!$bencana) {
                    jsonResponse(['success' => false, 'message' => 'Data bencana tidak ditemukan'], 404);
                }

                // Ambil posko terkait
                $stmt2 = $db->prepare("SELECT * FROM posko WHERE bencana_id = ?");
                $stmt2->execute([$_GET['id']]);
                $bencana['posko'] = $stmt2->fetchAll();

                // Ambil logistik terkait
                $stmt3 = $db->prepare("SELECT * FROM logistik WHERE bencana_id = ?");
                $stmt3->execute([$_GET['id']]);
                $bencana['logistik'] = $stmt3->fetchAll();

                // Ambil relawan terkait
                $stmt4 = $db->prepare("SELECT * FROM relawan WHERE bencana_id = ?");
                $stmt4->execute([$_GET['id']]);
                $bencana['relawan'] = $stmt4->fetchAll();
                
                jsonResponse(['success' => true, 'data' => $bencana]);
            } else {
                // List bencana dengan filter wilayah hierarki (Indonesia -> Provinsi -> Kabupaten/Kota)
                $where = [];
                $params = [];

                if (!empty($_GET['indonesia_id'])) {
                    $where[] = "p.indonesia_id = ?";
                    $params[] = $_GET['indonesia_id'];
                }
                if (!empty($_GET['jenis'])) {
                    $where[] = "b.jenis_bencana_id = ?";
                    $params[] = $_GET['jenis'];
                }
                if (!empty($_GET['provinsi']) || !empty($_GET['provinsi_id'])) {
                    $where[] = "b.provinsi_id = ?";
                    $params[] = $_GET['provinsi'] ?? $_GET['provinsi_id'];
                }
                if (!empty($_GET['kabkota_id']) || !empty($_GET['kabupaten_id'])) {
                    $where[] = "b.kabkota_id = ?";
                    $params[] = $_GET['kabkota_id'] ?? $_GET['kabupaten_id'];
                }
                if (!empty($_GET['status'])) {
                    $where[] = "b.status = ?";
                    $params[] = $_GET['status'];
                }
                if (!empty($_GET['tingkat'])) {
                    $where[] = "b.tingkat_kerusakan = ?";
                    $params[] = $_GET['tingkat'];
                }
                if (!empty($_GET['dari_tanggal'])) {
                    $where[] = "b.tanggal_kejadian >= ?";
                    $params[] = $_GET['dari_tanggal'];
                }
                if (!empty($_GET['sampai_tanggal'])) {
                    $where[] = "b.tanggal_kejadian <= ?";
                    $params[] = $_GET['sampai_tanggal'];
                }
                if (!empty($_GET['search'])) {
                    $where[] = "(b.judul LIKE ? OR b.deskripsi LIKE ? OR b.kode_bencana LIKE ? OR kk.nama_kabupaten LIKE ? OR p.nama_provinsi LIKE ? OR i.nama_negara LIKE ?)";
                    $search = '%' . $_GET['search'] . '%';
                    $params[] = $search;
                    $params[] = $search;
                    $params[] = $search;
                    $params[] = $search;
                    $params[] = $search;
                    $params[] = $search;
                }

                $whereClause = count($where) > 0 ? 'WHERE ' . implode(' AND ', $where) : '';

                // Pagination
                $page = max(1, (int)($_GET['page'] ?? 1));
                $limit = min(50, max(1, (int)($_GET['limit'] ?? 10)));
                $offset = ($page - 1) * $limit;

                // Count total
                $countSql = "SELECT COUNT(*) as total 
                    FROM bencana b 
                    JOIN provinsi p ON b.provinsi_id = p.id
                    LEFT JOIN indonesia i ON p.indonesia_id = i.id
                    LEFT JOIN kabupaten_kota kk ON b.kabkota_id = kk.id
                    $whereClause";
                $countStmt = $db->prepare($countSql);
                $countStmt->execute($params);
                $total = $countStmt->fetch()['total'];

                // Fetch data
                $sql = "SELECT b.*, jb.nama_jenis, jb.ikon, jb.warna, 
                    COALESCE(i.nama_negara, 'Indonesia') as nama_negara, p.indonesia_id,
                    p.nama_provinsi, kk.nama_kabkota, kk.nama_kabupaten,
                    k.meninggal, k.hilang, k.mengungsi, k.kerugian_estimasi
                    FROM bencana b
                    JOIN jenis_bencana jb ON b.jenis_bencana_id = jb.id
                    JOIN provinsi p ON b.provinsi_id = p.id
                    LEFT JOIN indonesia i ON p.indonesia_id = i.id
                    LEFT JOIN kabupaten_kota kk ON b.kabkota_id = kk.id
                    LEFT JOIN korban k ON b.id = k.bencana_id
                    $whereClause
                    ORDER BY b.tanggal_kejadian DESC
                    LIMIT ? OFFSET ?";
                $params[] = $limit;
                $params[] = $offset;

                $stmt = $db->prepare($sql);
                $stmt->execute($params);

                jsonResponse([
                    'success' => true,
                    'data' => $stmt->fetchAll(),
                    'pagination' => [
                        'total' => (int)$total,
                        'page' => $page,
                        'limit' => $limit,
                        'total_pages' => ceil($total / $limit)
                    ]
                ]);
            }
            break;

        case 'POST':
            $data = getRequestBody();
            
            // Validasi
            $required = ['jenis_bencana_id', 'provinsi_id', 'judul', 'tanggal_kejadian'];
            foreach ($required as $field) {
                if (empty($data[$field])) {
                    jsonResponse(['success' => false, 'message' => "Field '$field' wajib diisi"], 400);
                }
            }

            // Generate kode bencana
            $year = date('Y');
            $stmt = $db->query("SELECT COUNT(*) as total FROM bencana WHERE YEAR(created_at) = $year");
            $count = $stmt->fetch()['total'] + 1;
            $kodeBencana = 'BNC-' . $year . '-' . str_pad($count, 3, '0', STR_PAD_LEFT);

            $db->beginTransaction();

            // Insert bencana
            $stmt = $db->prepare("INSERT INTO bencana (kode_bencana, jenis_bencana_id, provinsi_id, kabkota_id, judul, deskripsi, tanggal_kejadian, waktu_kejadian, latitude, longitude, tingkat_kerusakan, status, sumber_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $kodeBencana,
                $data['jenis_bencana_id'],
                $data['provinsi_id'],
                $data['kabkota_id'] ?? null,
                $data['judul'],
                $data['deskripsi'] ?? null,
                $data['tanggal_kejadian'],
                $data['waktu_kejadian'] ?? null,
                $data['latitude'] ?? null,
                $data['longitude'] ?? null,
                $data['tingkat_kerusakan'] ?? 'ringan',
                $data['status'] ?? 'terjadi',
                $data['sumber_data'] ?? 'BNPB'
            ]);
            $bencanaId = $db->lastInsertId();

            // Insert korban jika ada
            if (isset($data['korban'])) {
                $k = $data['korban'];
                $stmt = $db->prepare("INSERT INTO korban (bencana_id, meninggal, hilang, luka_berat, luka_ringan, mengungsi, rumah_rusak_berat, rumah_rusak_sedang, rumah_rusak_ringan, fasilitas_umum_rusak, kerugian_estimasi) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $bencanaId,
                    $k['meninggal'] ?? 0,
                    $k['hilang'] ?? 0,
                    $k['luka_berat'] ?? 0,
                    $k['luka_ringan'] ?? 0,
                    $k['mengungsi'] ?? 0,
                    $k['rumah_rusak_berat'] ?? 0,
                    $k['rumah_rusak_sedang'] ?? 0,
                    $k['rumah_rusak_ringan'] ?? 0,
                    $k['fasilitas_umum_rusak'] ?? 0,
                    $k['kerugian_estimasi'] ?? 0
                ]);
            }

            $db->commit();

            // Sinkronkan ke data_bencana
            try {
                $stmtJB = $db->prepare("SELECT nama_jenis FROM jenis_bencana WHERE id = ?");
                $stmtJB->execute([$data['jenis_bencana_id']]);
                $namaJenis = $stmtJB->fetchColumn() ?: 'Lainnya';
                $totalKorban = ($k['meninggal'] ?? 0) + ($k['luka_berat'] ?? 0) + ($k['luka_ringan'] ?? 0);
                $tk = ucfirst(strtolower($data['tingkat_kerusakan'] ?? 'Ringan'));
                $tglWaktu = $data['tanggal_kejadian'] . ' ' . ($data['waktu_kejadian'] ?? '00:00:00');
                
                $stmtDB = $db->prepare("INSERT INTO data_bencana (id, kabupaten_id, jenis_bencana, tingkat_kerusakan, jumlah_korban, tanggal_kejadian) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE kabupaten_id=VALUES(kabupaten_id), jenis_bencana=VALUES(jenis_bencana), tingkat_kerusakan=VALUES(tingkat_kerusakan), jumlah_korban=VALUES(jumlah_korban), tanggal_kejadian=VALUES(tanggal_kejadian)");
                $stmtDB->execute([$bencanaId, $data['kabkota_id'] ?? 1, $namaJenis, $tk, $totalKorban, $tglWaktu]);
            } catch (Exception $e) {}

            jsonResponse([
                'success' => true,
                'message' => 'Data bencana berhasil ditambahkan',
                'data' => ['id' => (int)$bencanaId, 'kode_bencana' => $kodeBencana]
            ], 201);
            break;

        case 'PUT':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID bencana diperlukan'], 400);
            }

            $data = getRequestBody();
            $id = $_GET['id'];

            // Check exists
            $stmt = $db->prepare("SELECT id FROM bencana WHERE id = ?");
            $stmt->execute([$id]);
            if (!$stmt->fetch()) {
                jsonResponse(['success' => false, 'message' => 'Data bencana tidak ditemukan'], 404);
            }

            $db->beginTransaction();

            $fields = [];
            $values = [];
            $allowed = ['jenis_bencana_id', 'provinsi_id', 'kabkota_id', 'judul', 'deskripsi', 'tanggal_kejadian', 'waktu_kejadian', 'latitude', 'longitude', 'tingkat_kerusakan', 'status', 'sumber_data'];
            
            foreach ($allowed as $field) {
                if (isset($data[$field])) {
                    $fields[] = "$field = ?";
                    $values[] = $data[$field];
                }
            }

            if (!empty($fields)) {
                $values[] = $id;
                $sql = "UPDATE bencana SET " . implode(', ', $fields) . " WHERE id = ?";
                $stmt = $db->prepare($sql);
                $stmt->execute($values);
            }

            // Update korban jika ada
            if (isset($data['korban'])) {
                $k = $data['korban'];
                $stmt = $db->prepare("SELECT id FROM korban WHERE bencana_id = ?");
                $stmt->execute([$id]);
                
                if ($stmt->fetch()) {
                    $stmt = $db->prepare("UPDATE korban SET meninggal=?, hilang=?, luka_berat=?, luka_ringan=?, mengungsi=?, rumah_rusak_berat=?, rumah_rusak_sedang=?, rumah_rusak_ringan=?, fasilitas_umum_rusak=?, kerugian_estimasi=? WHERE bencana_id=?");
                    $stmt->execute([
                        $k['meninggal'] ?? 0, $k['hilang'] ?? 0, $k['luka_berat'] ?? 0,
                        $k['luka_ringan'] ?? 0, $k['mengungsi'] ?? 0, $k['rumah_rusak_berat'] ?? 0,
                        $k['rumah_rusak_sedang'] ?? 0, $k['rumah_rusak_ringan'] ?? 0,
                        $k['fasilitas_umum_rusak'] ?? 0, $k['kerugian_estimasi'] ?? 0, $id
                    ]);
                } else {
                    $stmt = $db->prepare("INSERT INTO korban (bencana_id, meninggal, hilang, luka_berat, luka_ringan, mengungsi, rumah_rusak_berat, rumah_rusak_sedang, rumah_rusak_ringan, fasilitas_umum_rusak, kerugian_estimasi) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    $stmt->execute([
                        $id, $k['meninggal'] ?? 0, $k['hilang'] ?? 0, $k['luka_berat'] ?? 0,
                        $k['luka_ringan'] ?? 0, $k['mengungsi'] ?? 0, $k['rumah_rusak_berat'] ?? 0,
                        $k['rumah_rusak_sedang'] ?? 0, $k['rumah_rusak_ringan'] ?? 0,
                        $k['fasilitas_umum_rusak'] ?? 0, $k['kerugian_estimasi'] ?? 0
                    ]);
                }
            }

            $db->commit();

            // Sinkronkan ke data_bencana
            try {
                $stmtB = $db->prepare("SELECT b.*, jb.nama_jenis, k.meninggal, k.luka_berat, k.luka_ringan FROM bencana b JOIN jenis_bencana jb ON b.jenis_bencana_id = jb.id LEFT JOIN korban k ON b.id = k.bencana_id WHERE b.id = ?");
                $stmtB->execute([$id]);
                $curr = $stmtB->fetch();
                if ($curr) {
                    $totalKorban = ($curr['meninggal'] ?? 0) + ($curr['luka_berat'] ?? 0) + ($curr['luka_ringan'] ?? 0);
                    $tk = ucfirst(strtolower($curr['tingkat_kerusakan'] ?? 'Ringan'));
                    $tglWaktu = $curr['tanggal_kejadian'] . ' ' . ($curr['waktu_kejadian'] ?? '00:00:00');
                    $stmtDB = $db->prepare("INSERT INTO data_bencana (id, kabupaten_id, jenis_bencana, tingkat_kerusakan, jumlah_korban, tanggal_kejadian) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE kabupaten_id=VALUES(kabupaten_id), jenis_bencana=VALUES(jenis_bencana), tingkat_kerusakan=VALUES(tingkat_kerusakan), jumlah_korban=VALUES(jumlah_korban), tanggal_kejadian=VALUES(tanggal_kejadian)");
                    $stmtDB->execute([$id, $curr['kabkota_id'] ?? 1, $curr['nama_jenis'], $tk, $totalKorban, $tglWaktu]);
                }
            } catch (Exception $e) {}

            jsonResponse(['success' => true, 'message' => 'Data bencana berhasil diperbarui']);
            break;

        case 'DELETE':
            if (empty($_GET['id'])) {
                jsonResponse(['success' => false, 'message' => 'ID bencana diperlukan'], 400);
            }

            $stmt = $db->prepare("SELECT id FROM bencana WHERE id = ?");
            $stmt->execute([$_GET['id']]);
            if (!$stmt->fetch()) {
                jsonResponse(['success' => false, 'message' => 'Data bencana tidak ditemukan'], 404);
            }

            $stmt = $db->prepare("DELETE FROM bencana WHERE id = ?");
            $stmt->execute([$_GET['id']]);

            try {
                $db->prepare("DELETE FROM data_bencana WHERE id = ?")->execute([$_GET['id']]);
            } catch (Exception $e) {}

            jsonResponse(['success' => true, 'message' => 'Data bencana berhasil dihapus']);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
    }
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
