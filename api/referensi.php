<?php
/**
 * API Referensi - Data referensi wilayah (Indonesia -> Provinsi -> Kabupaten/Kota) & jenis bencana
 * Endpoint: /api/referensi.php
 */
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method !== 'GET') {
    jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
}

$type = $_GET['type'] ?? '';

try {
    switch ($type) {
        case 'jenis_bencana':
            $stmt = $db->query("SELECT * FROM jenis_bencana ORDER BY nama_jenis");
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'indonesia':
        case 'negara':
            $stmt = $db->query("SELECT id, nama_negara FROM indonesia ORDER BY id");
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'provinsi':
            $indonesiaId = $_GET['indonesia_id'] ?? null;
            if ($indonesiaId) {
                $stmt = $db->prepare("SELECT p.*, i.nama_negara 
                    FROM provinsi p 
                    JOIN indonesia i ON p.indonesia_id = i.id 
                    WHERE p.indonesia_id = ? 
                    ORDER BY p.nama_provinsi");
                $stmt->execute([$indonesiaId]);
            } else {
                $stmt = $db->query("SELECT p.*, i.nama_negara 
                    FROM provinsi p 
                    JOIN indonesia i ON p.indonesia_id = i.id 
                    ORDER BY p.nama_provinsi");
            }
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'kabupaten_kota':
            $provinsiId = $_GET['provinsi_id'] ?? null;
            if ($provinsiId) {
                $stmt = $db->prepare("SELECT kk.*, p.nama_provinsi, i.nama_negara 
                    FROM kabupaten_kota kk 
                    JOIN provinsi p ON kk.provinsi_id = p.id 
                    JOIN indonesia i ON p.indonesia_id = i.id 
                    WHERE kk.provinsi_id = ? 
                    ORDER BY kk.nama_kabupaten");
                $stmt->execute([$provinsiId]);
            } else {
                $stmt = $db->query("SELECT kk.*, p.nama_provinsi, i.nama_negara 
                    FROM kabupaten_kota kk 
                    JOIN provinsi p ON kk.provinsi_id = p.id 
                    JOIN indonesia i ON p.indonesia_id = i.id 
                    ORDER BY p.nama_provinsi, kk.nama_kabupaten");
            }
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'wilayah_tree':
            // Kembalikan struktur hierarki lengkap: Indonesia -> Provinsi -> Kabupaten/Kota
            $stmtNegara = $db->query("SELECT * FROM indonesia ORDER BY id");
            $negaraList = $stmtNegara->fetchAll();

            $stmtProv = $db->query("SELECT p.*, 
                (SELECT COUNT(*) FROM kabupaten_kota kk WHERE kk.provinsi_id = p.id) as total_kabupaten,
                (SELECT COUNT(*) FROM bencana b WHERE b.provinsi_id = p.id) as total_bencana
                FROM provinsi p ORDER BY p.nama_provinsi");
            $provinsiList = $stmtProv->fetchAll();

            $stmtKab = $db->query("SELECT kk.*,
                (SELECT COUNT(*) FROM bencana b WHERE b.kabkota_id = kk.id) as total_bencana
                FROM kabupaten_kota kk ORDER BY kk.nama_kabupaten");
            $kabupatenList = $stmtKab->fetchAll();

            // Grouping
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
                foreach ($n['provinsi'] as $pr) {
                    $totalKab += count($pr['kabupaten_kota']);
                }
                $n['total_kabupaten'] = $totalKab;
            }

            jsonResponse(['success' => true, 'data' => $negaraList]);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Type tidak valid. Gunakan: jenis_bencana, indonesia, provinsi, kabupaten_kota, wilayah_tree'], 400);
    }
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
