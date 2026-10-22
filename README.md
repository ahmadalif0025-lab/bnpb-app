# BNPB - Sistem Informasi Penanggulangan Bencana

Sistem terintegrasi untuk monitoring dan pengelolaan data bencana oleh Badan Nasional Penanggulangan Bencana (BNPB).

## Struktur Proyek

```
bnpb/
├── index.html              # Halaman utama (SPA Dashboard)
├── database.sql            # SQL schema & seed data
├── config/
│   └── database.php        # Konfigurasi database PDO
├── api/
│   ├── dashboard.php       # API statistik & ringkasan
│   ├── bencana.php         # CRUD data bencana (filter hierarki wilayah)
│   ├── wilayah.php         # API hierarki wilayah (Indonesia -> Provinsi -> Kab/Kota)
│   ├── posko.php           # CRUD data posko
│   ├── logistik.php        # CRUD data logistik
│   ├── relawan.php         # CRUD data relawan
│   └── referensi.php       # Data referensi (indonesia, provinsi, kab/kota, jenis)
└── assets/
    ├── css/
    │   └── style.css       # Stylesheet premium dark theme
    ├── js/
    │   └── app.js          # JavaScript aplikasi utama
    └── img/
```

## Struktur Hierarki Wilayah

Sistem mengimplementasikan struktur wilayah berjenjang 3 tingkat:
```
Tingkat 1: indonesia (id, nama_negara)
   │
   ▼ (one-to-many via indonesia_id)
Tingkat 2: provinsi (id, indonesia_id, nama_provinsi, kode_provinsi)
   │
   ▼ (one-to-many via provinsi_id)
Tingkat 3: kabupaten_kota (id, provinsi_id, nama_kabupaten, nama_kabkota, tipe)
   │
   ▼ (one-to-many via kabupaten_id / kabkota_id)
data_bencana & bencana (kejadian bencana berlokasi di kab/kota spesifik)
```

## Fitur

- **Dashboard** - 8 kartu statistik ringkasan, grafik bulanan & donat jenis bencana, daftar bencana terkini
- **Hierarki Wilayah (Indonesia ➔ Provinsi ➔ Kab/Kota)**:
  - Menu khusus **Data Wilayah** untuk mengeksplorasi wilayah berjenjang secara interaktif
  - Filter berantai di halaman bencana (Pilih Negara ➔ Provinsi ➔ Kabupaten/Kota)
  - Indikator badge wilayah lengkap di tabel dan modal detail kejadian bencana
  - Form tambah bencana dengan 3 langkah pemilihan wilayah berjenjang
- **Data Bencana** - CRUD kejadian bencana tersinkronisasi dua arah ke `data_bencana` & `bencana`
- **Posko Pengungsian** - Monitoring posko dengan persentase daya tampung
- **Logistik Bantuan** - Manajemen stok bantuan per kategori
- **Data Relawan** - Pendataan relawan per bencana dan keahlian

## API Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/dashboard.php?action=summary` | Ringkasan statistik |
| GET | `/api/dashboard.php?action=bencana_per_bulan` | Chart bulanan |
| GET | `/api/dashboard.php?action=bencana_per_jenis` | Chart per jenis |
| GET | `/api/bencana.php` | List bencana |
| GET | `/api/bencana.php?id=1` | Detail bencana |
| POST | `/api/bencana.php` | Tambah bencana |
| PUT | `/api/bencana.php?id=1` | Update bencana |
| DELETE | `/api/bencana.php?id=1` | Hapus bencana |
| GET | `/api/posko.php` | List posko |
| GET | `/api/logistik.php` | List logistik |
| GET | `/api/relawan.php` | List relawan |
| GET | `/api/referensi.php?type=jenis_bencana` | Jenis bencana |
| GET | `/api/referensi.php?type=provinsi` | Daftar provinsi |

## Login Default
- Username: `admin` / Password: `admin123`
- Username: `operator1` / Password: `admin123`

## Teknologi
- **Frontend**: HTML5, CSS3 (Dark Theme), JavaScript ES6, Chart.js
- **Backend**: PHP 7.4+, PDO
- **Database**: MySQL / MariaDB
