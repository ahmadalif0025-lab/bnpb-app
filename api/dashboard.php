<?php
/**
 * API Dashboard - Statistik & Ringkasan
 * Endpoint: /api/dashboard.php
 */
require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance()->getConnection();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method !== 'GET') {
    jsonResponse(['success' => false, 'message' => 'Method tidak diizinkan'], 405);
}

$action = $_GET['action'] ?? 'summary';

try {
    switch ($action) {
        case 'summary':
            // Total bencana
            $stmt = $db->query("SELECT COUNT(*) as total FROM bencana");
            $totalBencana = $stmt->fetch()['total'];

            // Total korban
            $stmt = $db->query("SELECT 
                COALESCE(SUM(meninggal), 0) as total_meninggal,
                COALESCE(SUM(hilang), 0) as total_hilang,
                COALESCE(SUM(luka_berat), 0) as total_luka_berat,
                COALESCE(SUM(luka_ringan), 0) as total_luka_ringan,
                COALESCE(SUM(mengungsi), 0) as total_mengungsi,
                COALESCE(SUM(rumah_rusak_berat + rumah_rusak_sedang + rumah_rusak_ringan), 0) as total_rumah_rusak,
                COALESCE(SUM(kerugian_estimasi), 0) as total_kerugian
                FROM korban");
            $korban = $stmt->fetch();

            // Bencana aktif (belum selesai)
            $stmt = $db->query("SELECT COUNT(*) as total FROM bencana WHERE status != 'selesai'");
            $bencanaAktif = $stmt->fetch()['total'];

            // Posko aktif
            $stmt = $db->query("SELECT COUNT(*) as total FROM posko WHERE status = 'aktif'");
            $poskoAktif = $stmt->fetch()['total'];

            // Relawan aktif
            $stmt = $db->query("SELECT COUNT(*) as total FROM relawan WHERE status = 'aktif'");
            $relawanAktif = $stmt->fetch()['total'];

            // Total pengungsi aktif
            $stmt = $db->query("SELECT COALESCE(SUM(jumlah_pengungsi), 0) as total FROM posko WHERE status = 'aktif'");
            $pengungsiAktif = $stmt->fetch()['total'];

            jsonResponse([
                'success' => true,
                'data' => [
                    'total_bencana' => (int)$totalBencana,
                    'bencana_aktif' => (int)$bencanaAktif,
                    'posko_aktif' => (int)$poskoAktif,
                    'relawan_aktif' => (int)$relawanAktif,
                    'pengungsi_aktif' => (int)$pengungsiAktif,
                    'korban' => [
                        'meninggal' => (int)$korban['total_meninggal'],
                        'hilang' => (int)$korban['total_hilang'],
                        'luka_berat' => (int)$korban['total_luka_berat'],
                        'luka_ringan' => (int)$korban['total_luka_ringan'],
                        'mengungsi' => (int)$korban['total_mengungsi'],
                        'rumah_rusak' => (int)$korban['total_rumah_rusak'],
                        'total_kerugian' => (float)$korban['total_kerugian'],
                        'total_kerugian_formatted' => formatRupiah($korban['total_kerugian'])
                    ]
                ]
            ]);
            break;

        case 'bencana_per_jenis':
            $stmt = $db->query("SELECT jb.nama_jenis, jb.warna, jb.ikon, COUNT(b.id) as total 
                FROM jenis_bencana jb 
                LEFT JOIN bencana b ON jb.id = b.jenis_bencana_id 
                GROUP BY jb.id, jb.nama_jenis, jb.warna, jb.ikon
                ORDER BY total DESC");
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'bencana_per_provinsi':
            $stmt = $db->query("SELECT p.nama_provinsi, COUNT(b.id) as total 
                FROM provinsi p 
                LEFT JOIN bencana b ON p.id = b.provinsi_id 
                GROUP BY p.id, p.nama_provinsi
                HAVING total > 0
                ORDER BY total DESC
                LIMIT 15");
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'bencana_per_bulan':
            $year = $_GET['year'] ?? date('Y');
            $stmt = $db->prepare("SELECT MONTH(tanggal_kejadian) as bulan, COUNT(*) as total 
                FROM bencana 
                WHERE YEAR(tanggal_kejadian) = ?
                GROUP BY MONTH(tanggal_kejadian) 
                ORDER BY bulan");
            $stmt->execute([$year]);
            
            // Fill in all months
            $data = array_fill(1, 12, 0);
            foreach ($stmt->fetchAll() as $row) {
                $data[(int)$row['bulan']] = (int)$row['total'];
            }
            
            $result = [];
            $bulanNama = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
            for ($i = 1; $i <= 12; $i++) {
                $result[] = ['bulan' => $bulanNama[$i], 'total' => $data[$i]];
            }
            
            jsonResponse(['success' => true, 'data' => $result, 'year' => $year]);
            break;

        case 'bencana_terbaru':
            $limit = min((int)($_GET['limit'] ?? 5), 20);
            $stmt = $db->prepare("SELECT b.*, jb.nama_jenis, jb.ikon, jb.warna, p.nama_provinsi,
                k.meninggal, k.mengungsi
                FROM bencana b
                JOIN jenis_bencana jb ON b.jenis_bencana_id = jb.id
                JOIN provinsi p ON b.provinsi_id = p.id
                LEFT JOIN korban k ON b.id = k.bencana_id
                ORDER BY b.tanggal_kejadian DESC
                LIMIT ?");
            $stmt->execute([$limit]);
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'status_bencana':
            $stmt = $db->query("SELECT status, COUNT(*) as total FROM bencana GROUP BY status");
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        case 'logistik_summary':
            $stmt = $db->query("SELECT kategori, COUNT(*) as jenis_barang, SUM(jumlah) as total_jumlah, status
                FROM logistik 
                GROUP BY kategori, status
                ORDER BY kategori");
            jsonResponse(['success' => true, 'data' => $stmt->fetchAll()]);
            break;

        default:
            jsonResponse(['success' => false, 'message' => 'Action tidak valid'], 400);
    }
} catch (Exception $e) {
    jsonResponse(['success' => false, 'message' => $e->getMessage()], 500);
}
