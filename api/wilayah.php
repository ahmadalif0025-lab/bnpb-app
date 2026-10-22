<?php
/**
 * API Wilayah - Hierarki Wilayah (Indonesia -> Provinsi -> Kabupaten/Kota)
 * Endpoint: /api/wilayah.php
 */
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

$action = $_GET['action'] ?? 'tree';

try {
    switch ($method) {
        case 'GET':
            switch ($action) {
                case 'summary':
                    $negaraCount = $db->query("SELECT COUNT(*) FROM indonesia")->fetchColumn();
                    $provCount = $db->query("SELECT COUNT(*) FROM provinsi")->fetchColumn();
                    $kabCount = $db->query("SELECT COUNT(*) FROM kabupaten_kota")->fetchColumn();
                    $provTerdampak = $db->query("SELECT COUNT(DISTINCT provinsi_id) FROM bencana")->fetchColumn();
                    $kabTerdampak = $db->query("SELECT COUNT(DISTINCT kabkota_id) FROM bencana WHERE kabkota_id IS NOT NULL")->fetchColumn();

                    jsonResponse([
                        'success' => true,
                        'data' => [
                            'total_negara' => (int)$negaraCount,
                            'total_provinsi' => (int)$provCount,
                            'total_kabupaten' => (int)$kabCount,
                            'provinsi_terdampak' => (int)$provTerdampak,
                            'kabupaten_terdampak' => (int)$kabTerdampak,
                            'negara_utama' => 'Indonesia'
                        ]
                    ]);
                    break;

                case 'provinsi':
                    $indonesiaId = $_GET['indonesia_id'] ?? 1;
                    $stmt = $db->prepare("SELECT p.*, i.nama_negara,
                        (SELECT COUNT(*) FROM kabupaten_kota kk WHERE kk.provinsi_id = p.id) as total_kabupaten,
                        (SELECT COUNT(*) FROM bencana b WHERE b.provinsi_id = p.id) as total_bencana
                        FROM provinsi p
                        JOIN indonesia i ON p.indonesia_id = i.id
                        WHERE p.indonesia_id = ?
                        ORDER BY p.nama_provinsi");
                    $stmt->execute([$indonesiaId]);
                    jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
                    break;

                case 'kabupaten':
                    $provinsiId = $_GET['provinsi_id'] ?? null;
                    if (!$provinsiId) {
                        jsonResponse(['success' => false, 'message' => 'provinsi_id diperlukan'], 400);
                    }
                    $stmt = $db->prepare("SELECT kk.*, p.nama_provinsi, i.nama_negara,
                        (SELECT COUNT(*) FROM bencana b WHERE b.kabkota_id = kk.id) as total_bencana
                        FROM kabupaten_kota kk
                        JOIN provinsi p ON kk.provinsi_id = p.id
                        JOIN indonesia i ON p.indonesia_id = i.id
                        WHERE kk.provinsi_id = ?
                        ORDER BY kk.nama_kabupaten");
                    $stmt->execute([$provinsiId]);
                    jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
                    break;

                case 'tree':
                default:
                    // Ambil Negara
                    $stmtNegara = $db->query("SELECT * FROM indonesia ORDER BY id");
                    $negaraList = $stmtNegara->fetchAll();

                    // Ambil Provinsi beserta statistik
                    $stmtProv = $db->query("SELECT p.*, i.nama_negara,
                        (SELECT COUNT(*) FROM kabupaten_kota kk WHERE kk.provinsi_id = p.id) as total_kabupaten,
                        (SELECT COUNT(*) FROM bencana b WHERE b.provinsi_id = p.id) as total_bencana
                        FROM provinsi p
                        JOIN indonesia i ON p.indonesia_id = i.id
                        ORDER BY p.nama_provinsi");
                    $provinsiList = $stmtProv->fetchAll();

                    // Ambil Kabupaten beserta statistik
                    $stmtKab = $db->query("SELECT kk.*,
                        (SELECT COUNT(*) FROM bencana b WHERE b.kabkota_id = kk.id) as total_bencana
                        FROM kabupaten_kota kk
                        ORDER BY kk.nama_kabupaten");
                    $kabupatenList = $stmtKab->fetchAll();

                    $kabByProv = [];
                    foreach ($kabupatenList as $k) {
                        $kabByProv[$k['provinsi_id']][] = $k;
                    }

                    $provByNegara = [];
                    foreach ($provinsiList as $p) {
                        $p['kabupaten_kota'] = $kabByProv[$p['id']] ?? [];
                        $provByNegara[$p['indonesia_id']][] = $p;
                    }

                    foreach ($negaraList as &$n) {
                        $n['provinsi'] = $provByNegara[$n['id']] ?? [];
                        $n['total_provinsi'] = count($n['provinsi']);
                        $totalKab = 0;
                        $totalBenc = 0;
                        foreach ($n['provinsi'] as $pr) {
                            $totalKab += count($pr['kabupaten_kota']);
                            $totalBenc += (int)$pr['total_bencana'];
                        }
                        $n['total_kabupaten'] = $totalKab;
                        $n['total_bencana'] = $totalBenc;
                    }

                    jsonResponse(['success' => true, 'data' => $negaraList]);
                    break;
            }
            break;

        case 'POST':
            $data = getRequestBody();
            $target = $_GET['target'] ?? 'kabupaten';

            if ($target === 'kabupaten') {
                if (empty($data['provinsi_id']) || empty($data['nama_kabupaten'])) {
                    jsonResponse(['success' => false, 'message' => 'provinsi_id dan nama_kabupaten wajib diisi'], 400);
                }
                $stmt = $db->prepare("INSERT INTO kabupaten_kota (provinsi_id, nama_kabupaten, tipe) VALUES (?, ?, ?)");
                $stmt->execute([
                    $data['provinsi_id'],
                    $data['nama_kabupaten'],
                    $data['tipe'] ?? 'kabupaten'
                ]);
                jsonResponse(['success' => true, 'message' => 'Kabupaten/Kota berhasil ditambahkan', 'id' => (int)$db->lastInsertId()], 201);
            } elseif ($target === 'provinsi') {
                if (empty($data['nama_provinsi'])) {
                    jsonResponse(['success' => false, 'message' => 'nama_provinsi wajib diisi'], 400);
                }
                $stmt = $db->prepare("INSERT INTO provinsi (indonesia_id, nama_provinsi, kode_provinsi) VALUES (?, ?, ?)");
                $stmt->execute([
                    $data['indonesia_id'] ?? 1,
                    $data['nama_provinsi'],
                    $data['kode_provinsi'] ?? null
                ]);
                jsonResponse(['success' => true, 'message' => 'Provinsi berhasil ditambahkan', 'id' => (int)$db->lastInsertId()], 201);
            } else {
                jsonResponse(['success' => false, 'message' => 'Target tidak valid. Gunakan kabupaten atau provinsi'], 400);
            }
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
    }
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
