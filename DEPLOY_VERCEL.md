# Panduan Lengkap Hosting Website BNPB ke Vercel

Sistem Informasi Penanggulangan Bencana BNPB telah dioptimalkan agar **siap 100% di-deploy ke Vercel** secara langsung, baik sebagai aplikasi frontend interaktif dengan *Smart Cloud Storage Engine* maupun terhubung ke database cloud remote.

---

## 🚀 Cara 1: Deploy via GitHub (Paling Mudah & Direkomendasikan ⭐️)

Metode ini adalah cara standar Vercel dan otomatis mendapatkan SSL (HTTPS) serta domain gratis `*.vercel.app`.

### Langkah 1: Upload Folder ke GitHub
1. Buka [github.com](https://github.com) dan login ke akun Anda.
2. Buat repository baru, misalnya beri nama `bnpb-sistem-terintegrasi` (pilih **Public** atau **Private**).
3. Upload seluruh file dari folder `d:\bnpb` ke repository tersebut:
   - Bisa menggunakan aplikasi **GitHub Desktop**
   - Atau menggunakan Git CLI:
     ```bash
     cd d:\bnpb
     git init
     git add .
     git commit -m "Initial commit website BNPB"
     git branch -M main
     git remote add origin https://github.com/USERNAME/bnpb-sistem-terintegrasi.git
     git push -u origin main
     ```
   - Atau langsung drag & drop file melalui fitur **"uploading an existing file"** di halaman repository GitHub.

### Langkah 2: Hubungkan & Deploy di Vercel
1. Buka [vercel.com](https://vercel.com) lalu login (disarankan login menggunakan akun GitHub Anda).
2. Di halaman Dashboard Vercel, klik tombol **"Add New..."** lalu pilih **"Project"**.
3. Di daftar repository GitHub Anda, pilih `bnpb-sistem-terintegrasi` lalu klik **"Import"**.
4. Di bagian konfigurasi project:
   - **Project Name**: `bnpb-sistem-terintegrasi` (atau nama lain yang Anda inginkan)
   - **Framework Preset**: Pilih **Other**
   - **Root Directory**: Biarkan `./`
5. Klik tombol **"Deploy"**.
6. Tunggu sekitar 30–60 detik hingga proses build selesai. 🎉 **Website Anda langsung online!**

---

## ⚡ Cara 2: Deploy Cepat via Vercel CLI

Jika Anda memiliki Node.js di komputer:

1. Buka Terminal / PowerShell:
   ```bash
   npm install -g vercel
   ```
2. Masuk ke direktori project:
   ```bash
   cd d:\bnpb
   ```
3. Jalankan perintah deploy:
   ```bash
   vercel
   ```
4. Ikuti instruksi login dan konfirmasi di layar (tekan Enter untuk pilihan default).
5. Untuk deploy ke production, jalankan:
   ```bash
   vercel --prod
   ```

---

## 🗄️ Opsi Koneksi Database Remote Cloud (Opsional)

Secara default, saat dihosting di Vercel, sistem otomatis mengaktifkan **Smart Client Storage Engine** yang:
- Sudah terisi lengkap dengan **15 data bencana, 20 provinsi, 68 kabupaten/kota, 6 posko, 10 logistik, dan 8 relawan**.
- Mendukung fitur tambah, ubah, dan hapus (CRUD) secara interaktif langsung di browser.

Jika Anda ingin menghubungkan API PHP di Vercel ke server MySQL cloud sungguhan (misalnya menggunakan database gratis dari **Aiven MySQL**, **TiDB Serverless**, atau **Clever Cloud**):

1. Buat database MySQL gratis di penyedia cloud (seperti [aiven.io](https://aiven.io) atau [tidbcloud.com](https://tidbcloud.com)).
2. Import file `database.sql` ke database cloud tersebut.
3. Di Dashboard Vercel project Anda:
   - Buka menu **Settings** ➔ **Environment Variables**.
   - Tambahkan variabel berikut:
     - `DB_HOST`: Host server cloud (misal: `mysql-xxx.aivencloud.com`)
     - `DB_PORT`: Port MySQL (misal: `3306` atau port dari provider)
     - `DB_NAME`: `db_sistem_terintegrasi`
     - `DB_USER`: Username database cloud
     - `DB_PASS`: Password database cloud
4. Redeploy project Anda di Vercel.

---

## ✅ Fitur yang Berjalan di Vercel
- **Dashboard Ringkasan & 8 Kartu Statistik**
- **Grafik Tren Bulanan (Chart.js Bar) & Donat Jenis Bencana**
- **Daftar Bencana Terbaru**
- **Data Bencana Lengkap dengan Filter Berjenjang**
- **Hierarki Wilayah (Indonesia ➔ Provinsi ➔ Kabupaten/Kota)**
- **Manajemen Posko Pengungsian, Logistik, dan Relawan**
- **Form Tambah Kejadian Bencana Baru**
