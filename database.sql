-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: db_sistem_terintegrasi
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `db_sistem_terintegrasi`
--

/*!40000 DROP DATABASE IF EXISTS `db_sistem_terintegrasi`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `db_sistem_terintegrasi` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `db_sistem_terintegrasi`;

--
-- Table structure for table `bencana`
--

DROP TABLE IF EXISTS `bencana`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bencana` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kode_bencana` varchar(20) NOT NULL,
  `jenis_bencana_id` int(11) NOT NULL,
  `provinsi_id` int(11) NOT NULL,
  `kabkota_id` int(11) DEFAULT NULL,
  `judul` varchar(255) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `tanggal_kejadian` date NOT NULL,
  `waktu_kejadian` time DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `tingkat_kerusakan` enum('ringan','sedang','berat','sangat_berat') DEFAULT 'ringan',
  `status` enum('terjadi','tanggap_darurat','pemulihan','selesai') DEFAULT 'terjadi',
  `sumber_data` varchar(100) DEFAULT 'BNPB',
  `foto` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `kode_bencana` (`kode_bencana`),
  KEY `jenis_bencana_id` (`jenis_bencana_id`),
  KEY `provinsi_id` (`provinsi_id`),
  KEY `kabkota_id` (`kabkota_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `bencana_ibfk_1` FOREIGN KEY (`jenis_bencana_id`) REFERENCES `jenis_bencana` (`id`),
  CONSTRAINT `bencana_ibfk_2` FOREIGN KEY (`provinsi_id`) REFERENCES `provinsi` (`id`),
  CONSTRAINT `bencana_ibfk_3` FOREIGN KEY (`kabkota_id`) REFERENCES `kabupaten_kota` (`id`),
  CONSTRAINT `bencana_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bencana`
--

LOCK TABLES `bencana` WRITE;
/*!40000 ALTER TABLE `bencana` DISABLE KEYS */;
INSERT INTO `bencana` VALUES (1,'BNPB-2024-001',1,2,11,'Gempa Bumi Cianjur Magnitudo 5.6','Gempa bumi tektonik kedalaman 10 km mengguncang wilayah Cianjur dan sekitarnya','2024-11-21','13:21:00',NULL,NULL,'berat','selesai','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(2,'BNPB-2024-002',5,4,25,'Erupsi Gunung Semeru Lumajang','Awan panas guguran (APG) Gunung Semeru meluncur sejauh 19 km menimpa wilayah pemukiman','2024-12-04','15:00:00',NULL,NULL,'berat','selesai','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(3,'BNPB-2025-003',3,2,9,'Banjir Luapan Sungai Ciliwung & Cisadane Bogor','Hujan ekstrem memicu luapan sungai merendam pemukiman warga di beberapa kecamatan','2025-01-18','04:30:00',NULL,NULL,'sedang','selesai','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(4,'BNPB-2025-004',9,10,51,'Banjir Bandang & Lahar Dingin Marapi Agam','Banjir lahar dingin bercampur material vulkanik menerjang pemukiman di kaki Gunung Marapi','2025-05-11','21:00:00',NULL,NULL,'berat','selesai','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(5,'BNPB-2025-005',4,10,52,'Tanah Longsor Batipuh Tanah Datar','Curah hujan tinggi menyebabkan tebing perbukitan longsor menimbun jalan dan rumah warga','2025-05-12','02:15:00',NULL,NULL,'berat','selesai','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(6,'BNPB-2025-006',5,9,48,'Erupsi Gunung Lewotobi Laki-laki','Erupsi eksplosif disertai lontaran lava pijar dan batu membakar puluhan rumah di lereng gunung','2025-11-04','00:05:00',NULL,NULL,'berat','pemulihan','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(7,'BNPB-2026-007',3,1,3,'Banjir Luapan Kali Ciliwung Jakarta Timur','Banjir kiriman dari hulu merendam kawasan bantaran Kali Ciliwung hingga ketinggian 1.5 meter','2026-02-14','06:00:00',NULL,NULL,'sedang','selesai','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(8,'BNPB-2026-008',3,3,16,'Banjir Rob & Genangan Pantura Semarang','Kombinasi pasang air laut dan hujan deras merendam jalur Pantura Kaligawe dan sekitarnya','2026-03-01','09:30:00',NULL,NULL,'sedang','selesai','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(9,'BNPB-2026-009',6,15,61,'Karhutla Hutan Lindung Sungai Wain Balikpapan','Kebakaran lahan gambut dan semak belukar pada musim kemarau di area penyangga hutan lindung','2026-08-15','14:10:00',NULL,NULL,'sedang','pemulihan','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(10,'BNPB-2026-010',11,6,35,'Cuaca Ekstrem Angin Kencang Sleman','Hujan lebat disertai angin kencang merobohkan puluhan pohon dan merusak atap bangunan','2026-09-02','16:20:00',NULL,NULL,'ringan','tanggap_darurat','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(11,'BNPB-2026-011',1,7,41,'Gempa Bumi Tektonik Karangasem Bali','Gempa dangkal M 5.2 berpusat di timur laut Karangasem merusak puluhan bangunan warga','2026-09-19','03:45:00',NULL,NULL,'sedang','tanggap_darurat','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(12,'BNPB-2026-012',4,2,13,'Tanah Longsor Jalur Cisompet Garut Selatan','Longsoran tanah menutup akses jalan provinsi dan mengancam pemukiman lereng bukit','2026-10-05','18:30:00',NULL,NULL,'berat','tanggap_darurat','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(13,'BNPB-2026-013',10,5,30,'Gelombang Pasang & Abrasi Pantai Carita Pandeglang','Gelombang pasang setinggi 3 meter merusak tanggul penahan ombak dan warung wisata pesisir','2026-10-10','11:00:00',NULL,NULL,'ringan','tanggap_darurat','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(14,'BNPB-2026-014',1,18,66,'Gempa Bumi Sesar Palu-Koro','Guncangan gempa tektonik dangkal berpusat di darat terasa kuat di Kota Palu dan Sigi','2026-10-14','13:12:00',NULL,NULL,'sedang','terjadi','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(15,'BNPB-2026-015',3,15,62,'Banjir Genangan Kecamatan Sepaku PPU','Luapan Sungai Sepaku akibat hujan intensitas tinggi merendam pemukiman dan akses jalan desa','2026-10-18','07:45:00',NULL,NULL,'ringan','terjadi','BNPB',NULL,1,'2026-10-22 09:19:47','2026-10-22 09:19:47');
/*!40000 ALTER TABLE `bencana` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_bencana`
--

DROP TABLE IF EXISTS `data_bencana`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_bencana` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kabupaten_id` int(11) NOT NULL,
  `jenis_bencana` varchar(100) DEFAULT NULL,
  `tingkat_kerusakan` varchar(50) DEFAULT NULL,
  `jumlah_korban` int(11) DEFAULT NULL,
  `tanggal_kejadian` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kabupaten_id` (`kabupaten_id`),
  CONSTRAINT `data_bencana_ibfk_1` FOREIGN KEY (`kabupaten_id`) REFERENCES `kabupaten_kota` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_bencana`
--

LOCK TABLES `data_bencana` WRITE;
/*!40000 ALTER TABLE `data_bencana` DISABLE KEYS */;
INSERT INTO `data_bencana` VALUES (1,11,'Gempa Bumi','Berat',335,'2024-11-21 13:21:00'),(2,25,'Erupsi Gunung Api','Berat',51,'2024-12-04 15:00:00'),(3,9,'Banjir','Sedang',12,'2025-01-18 04:30:00'),(4,51,'Banjir Bandang & Lahar Dingin','Berat',67,'2025-05-11 21:00:00'),(5,52,'Tanah Longsor','Berat',29,'2025-05-12 02:15:00'),(6,48,'Erupsi Gunung Api','Berat',9,'2025-11-04 00:05:00'),(7,3,'Banjir','Sedang',0,'2026-02-14 06:00:00'),(8,16,'Banjir','Sedang',3,'2026-03-01 09:30:00'),(9,61,'Kebakaran Hutan dan Lahan','Sedang',0,'2026-08-15 14:10:00'),(10,35,'Cuaca Ekstrem','Ringan',4,'2026-09-02 16:20:00'),(11,41,'Gempa Bumi','Sedang',1,'2026-09-19 03:45:00'),(12,13,'Tanah Longsor','Berat',8,'2026-10-05 18:30:00'),(13,30,'Gelombang Pasang dan Abrasi','Ringan',0,'2026-10-10 11:00:00'),(14,66,'Gempa Bumi','Sedang',2,'2026-10-14 13:12:00'),(15,62,'Banjir','Ringan',0,'2026-10-18 07:45:00');
/*!40000 ALTER TABLE `data_bencana` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dokumen`
--

DROP TABLE IF EXISTS `dokumen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dokumen` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bencana_id` int(11) NOT NULL,
  `judul` varchar(200) NOT NULL,
  `tipe` enum('laporan','foto','video','dokumen') DEFAULT 'dokumen',
  `file_path` varchar(255) NOT NULL,
  `ukuran_file` int(11) DEFAULT 0,
  `deskripsi` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `bencana_id` (`bencana_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `dokumen_ibfk_1` FOREIGN KEY (`bencana_id`) REFERENCES `bencana` (`id`) ON DELETE CASCADE,
  CONSTRAINT `dokumen_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dokumen`
--

LOCK TABLES `dokumen` WRITE;
/*!40000 ALTER TABLE `dokumen` DISABLE KEYS */;
/*!40000 ALTER TABLE `dokumen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `indonesia`
--

DROP TABLE IF EXISTS `indonesia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `indonesia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nama_negara` varchar(100) NOT NULL DEFAULT 'Indonesia',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `indonesia`
--

LOCK TABLES `indonesia` WRITE;
/*!40000 ALTER TABLE `indonesia` DISABLE KEYS */;
INSERT INTO `indonesia` VALUES (1,'Indonesia');
/*!40000 ALTER TABLE `indonesia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jenis_bencana`
--

DROP TABLE IF EXISTS `jenis_bencana`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jenis_bencana` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nama_jenis` varchar(100) NOT NULL,
  `kode_jenis` varchar(10) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `ikon` varchar(50) DEFAULT NULL,
  `warna` varchar(7) DEFAULT '#FF0000',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `kode_jenis` (`kode_jenis`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jenis_bencana`
--

LOCK TABLES `jenis_bencana` WRITE;
/*!40000 ALTER TABLE `jenis_bencana` DISABLE KEYS */;
INSERT INTO `jenis_bencana` VALUES (1,'Gempa Bumi','GMB','Getaran atau goncangan yang terjadi di permukaan bumi','fa-house-crack','#E74C3C','2026-10-22 09:10:45'),(2,'Tsunami','TSN','Gelombang laut besar akibat gempa bumi bawah laut','fa-water','#3498DB','2026-10-22 09:10:45'),(3,'Banjir','BJR','Peristiwa tergenangnya daratan oleh air','fa-cloud-showers-heavy','#2980B9','2026-10-22 09:10:45'),(4,'Tanah Longsor','TLG','Perpindahan material pembentuk lereng','fa-mountain','#8B4513','2026-10-22 09:10:45'),(5,'Erupsi Gunung Api','EGA','Keluarnya magma dari dalam gunung berapi','fa-volcano','#FF6347','2026-10-22 09:10:45'),(6,'Kebakaran Hutan','KBH','Kebakaran yang terjadi di area hutan dan lahan','fa-fire','#FF4500','2026-10-22 09:10:45'),(7,'Angin Puting Beliung','APB','Angin kencang berbentuk melingkar','fa-wind','#7F8C8D','2026-10-22 09:10:45'),(8,'Kekeringan','KKR','Ketersediaan air jauh di bawah kebutuhan','fa-sun','#F39C12','2026-10-22 09:10:45'),(9,'Banjir Bandang','BJB','Banjir besar yang datang secara tiba-tiba','fa-house-flood-water','#1ABC9C','2026-10-22 09:10:45'),(10,'Gelombang Pasang','GLP','Gelombang air laut yang melebihi normal','fa-wave-square','#16A085','2026-10-22 09:10:45'),(11,'Cuaca Ekstrem','CEK','Kondisi cuaca tidak biasa yang berpotensi merusak','fa-bolt','#9B59B6','2026-10-22 09:18:39');
/*!40000 ALTER TABLE `jenis_bencana` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kabupaten_kota`
--

DROP TABLE IF EXISTS `kabupaten_kota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kabupaten_kota` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provinsi_id` int(11) NOT NULL,
  `nama_kabupaten` varchar(100) NOT NULL,
  `nama_kabkota` varchar(100) GENERATED ALWAYS AS (`nama_kabupaten`) VIRTUAL,
  `kode_kabkota` varchar(10) DEFAULT NULL,
  `tipe` enum('kabupaten','kota') DEFAULT 'kabupaten',
  PRIMARY KEY (`id`),
  KEY `provinsi_id` (`provinsi_id`),
  CONSTRAINT `kabupaten_kota_ibfk_1` FOREIGN KEY (`provinsi_id`) REFERENCES `provinsi` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kabupaten_kota`
--

LOCK TABLES `kabupaten_kota` WRITE;
/*!40000 ALTER TABLE `kabupaten_kota` DISABLE KEYS */;
INSERT INTO `kabupaten_kota` VALUES (1,1,'Kota Jakarta Pusat','Kota Jakarta Pusat',NULL,'kabupaten'),(2,1,'Kota Jakarta Selatan','Kota Jakarta Selatan',NULL,'kabupaten'),(3,1,'Kota Jakarta Timur','Kota Jakarta Timur',NULL,'kabupaten'),(4,1,'Kota Jakarta Barat','Kota Jakarta Barat',NULL,'kabupaten'),(5,1,'Kota Jakarta Utara','Kota Jakarta Utara',NULL,'kabupaten'),(6,1,'Kabupaten Kepulauan Seribu','Kabupaten Kepulauan Seribu',NULL,'kabupaten'),(7,2,'Kota Bandung','Kota Bandung',NULL,'kabupaten'),(8,2,'Kabupaten Bandung','Kabupaten Bandung',NULL,'kabupaten'),(9,2,'Kabupaten Bogor','Kabupaten Bogor',NULL,'kabupaten'),(10,2,'Kota Bogor','Kota Bogor',NULL,'kabupaten'),(11,2,'Kabupaten Cianjur','Kabupaten Cianjur',NULL,'kabupaten'),(12,2,'Kabupaten Sukabumi','Kabupaten Sukabumi',NULL,'kabupaten'),(13,2,'Kabupaten Garut','Kabupaten Garut',NULL,'kabupaten'),(14,2,'Kabupaten Karawang','Kabupaten Karawang',NULL,'kabupaten'),(15,2,'Kota Bekasi','Kota Bekasi',NULL,'kabupaten'),(16,3,'Kota Semarang','Kota Semarang',NULL,'kabupaten'),(17,3,'Kabupaten Magelang','Kabupaten Magelang',NULL,'kabupaten'),(18,3,'Kabupaten Boyolali','Kabupaten Boyolali',NULL,'kabupaten'),(19,3,'Kabupaten Klaten','Kabupaten Klaten',NULL,'kabupaten'),(20,3,'Kabupaten Cilacap','Kabupaten Cilacap',NULL,'kabupaten'),(21,3,'Kabupaten Banyumas','Kabupaten Banyumas',NULL,'kabupaten'),(22,3,'Kota Surakarta','Kota Surakarta',NULL,'kabupaten'),(23,4,'Kota Surabaya','Kota Surabaya',NULL,'kabupaten'),(24,4,'Kabupaten Malang','Kabupaten Malang',NULL,'kabupaten'),(25,4,'Kabupaten Lumajang','Kabupaten Lumajang',NULL,'kabupaten'),(26,4,'Kabupaten Pasuruan','Kabupaten Pasuruan',NULL,'kabupaten'),(27,4,'Kabupaten Banyuwangi','Kabupaten Banyuwangi',NULL,'kabupaten'),(28,4,'Kabupaten Sidoarjo','Kabupaten Sidoarjo',NULL,'kabupaten'),(29,5,'Kota Serang','Kota Serang',NULL,'kabupaten'),(30,5,'Kabupaten Pandeglang','Kabupaten Pandeglang',NULL,'kabupaten'),(31,5,'Kabupaten Lebak','Kabupaten Lebak',NULL,'kabupaten'),(32,5,'Kota Tangerang','Kota Tangerang',NULL,'kabupaten'),(33,5,'Kota Tangerang Selatan','Kota Tangerang Selatan',NULL,'kabupaten'),(34,6,'Kota Yogyakarta','Kota Yogyakarta',NULL,'kabupaten'),(35,6,'Kabupaten Sleman','Kabupaten Sleman',NULL,'kabupaten'),(36,6,'Kabupaten Bantul','Kabupaten Bantul',NULL,'kabupaten'),(37,6,'Kabupaten Gunungkidul','Kabupaten Gunungkidul',NULL,'kabupaten'),(38,6,'Kabupaten Kulon Progo','Kabupaten Kulon Progo',NULL,'kabupaten'),(39,7,'Kota Denpasar','Kota Denpasar',NULL,'kabupaten'),(40,7,'Kabupaten Badung','Kabupaten Badung',NULL,'kabupaten'),(41,7,'Kabupaten Karangasem','Kabupaten Karangasem',NULL,'kabupaten'),(42,7,'Kabupaten Gianyar','Kabupaten Gianyar',NULL,'kabupaten'),(43,8,'Kota Mataram','Kota Mataram',NULL,'kabupaten'),(44,8,'Kabupaten Lombok Barat','Kabupaten Lombok Barat',NULL,'kabupaten'),(45,8,'Kabupaten Lombok Utara','Kabupaten Lombok Utara',NULL,'kabupaten'),(46,8,'Kabupaten Bima','Kabupaten Bima',NULL,'kabupaten'),(47,9,'Kota Kupang','Kota Kupang',NULL,'kabupaten'),(48,9,'Kabupaten Flores Timur','Kabupaten Flores Timur',NULL,'kabupaten'),(49,9,'Kabupaten Manggarai Barat','Kabupaten Manggarai Barat',NULL,'kabupaten'),(50,10,'Kota Padang','Kota Padang',NULL,'kabupaten'),(51,10,'Kabupaten Agam','Kabupaten Agam',NULL,'kabupaten'),(52,10,'Kabupaten Tanah Datar','Kabupaten Tanah Datar',NULL,'kabupaten'),(53,10,'Kota Bukittinggi','Kota Bukittinggi',NULL,'kabupaten'),(54,11,'Kota Medan','Kota Medan',NULL,'kabupaten'),(55,11,'Kabupaten Deli Serdang','Kabupaten Deli Serdang',NULL,'kabupaten'),(56,11,'Kabupaten Karo','Kabupaten Karo',NULL,'kabupaten'),(57,12,'Kota Banda Aceh','Kota Banda Aceh',NULL,'kabupaten'),(58,12,'Kabupaten Aceh Besar','Kabupaten Aceh Besar',NULL,'kabupaten'),(59,12,'Kabupaten Aceh Tengah','Kabupaten Aceh Tengah',NULL,'kabupaten'),(60,15,'Kota Samarinda','Kota Samarinda',NULL,'kabupaten'),(61,15,'Kota Balikpapan','Kota Balikpapan',NULL,'kabupaten'),(62,15,'Kabupaten Penajam Paser Utara','Kabupaten Penajam Paser Utara',NULL,'kabupaten'),(63,17,'Kota Makassar','Kota Makassar',NULL,'kabupaten'),(64,17,'Kabupaten Gowa','Kabupaten Gowa',NULL,'kabupaten'),(65,17,'Kabupaten Luwu Utara','Kabupaten Luwu Utara',NULL,'kabupaten'),(66,18,'Kota Palu','Kota Palu',NULL,'kabupaten'),(67,18,'Kabupaten Donggala','Kabupaten Donggala',NULL,'kabupaten'),(68,18,'Kabupaten Sigi','Kabupaten Sigi',NULL,'kabupaten');
/*!40000 ALTER TABLE `kabupaten_kota` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `korban`
--

DROP TABLE IF EXISTS `korban`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `korban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bencana_id` int(11) NOT NULL,
  `meninggal` int(11) DEFAULT 0,
  `hilang` int(11) DEFAULT 0,
  `luka_berat` int(11) DEFAULT 0,
  `luka_ringan` int(11) DEFAULT 0,
  `mengungsi` int(11) DEFAULT 0,
  `rumah_rusak_berat` int(11) DEFAULT 0,
  `rumah_rusak_sedang` int(11) DEFAULT 0,
  `rumah_rusak_ringan` int(11) DEFAULT 0,
  `fasilitas_umum_rusak` int(11) DEFAULT 0,
  `kerugian_estimasi` decimal(15,2) DEFAULT 0.00,
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `bencana_id` (`bencana_id`),
  CONSTRAINT `korban_ibfk_1` FOREIGN KEY (`bencana_id`) REFERENCES `bencana` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `korban`
--

LOCK TABLES `korban` WRITE;
/*!40000 ALTER TABLE `korban` DISABLE KEYS */;
INSERT INTO `korban` VALUES (1,1,335,0,1083,3000,114683,22198,11980,22144,0,4000000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(2,2,51,0,169,520,10655,1027,850,1200,0,310000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(3,3,12,0,45,120,2450,85,320,510,0,45000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(4,4,67,14,85,210,3300,250,180,215,0,180000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(5,5,29,2,34,76,1200,95,65,88,0,65000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(6,6,9,0,31,63,12200,2384,1120,1560,0,210000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(7,7,0,0,0,12,850,0,120,450,0,15000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(8,8,3,0,8,25,1100,15,210,380,0,28000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(9,9,0,0,0,15,0,0,5,20,0,35000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(10,10,0,0,0,4,0,2,12,45,0,5000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(11,11,1,0,5,18,320,12,64,125,0,12000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(12,12,8,1,12,28,450,38,25,42,0,22000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(13,13,0,0,0,2,120,5,15,35,0,3500000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(14,14,0,0,0,2,80,2,8,28,0,8000000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(15,15,0,0,0,0,180,0,10,52,0,4200000000.00,NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47');
/*!40000 ALTER TABLE `korban` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `log_aktivitas`
--

DROP TABLE IF EXISTS `log_aktivitas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_aktivitas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `aksi` varchar(50) NOT NULL,
  `tabel_terkait` varchar(50) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `detail` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `log_aktivitas_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_aktivitas`
--

LOCK TABLES `log_aktivitas` WRITE;
/*!40000 ALTER TABLE `log_aktivitas` DISABLE KEYS */;
/*!40000 ALTER TABLE `log_aktivitas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logistik`
--

DROP TABLE IF EXISTS `logistik`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logistik` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bencana_id` int(11) NOT NULL,
  `posko_id` int(11) DEFAULT NULL,
  `nama_barang` varchar(150) NOT NULL,
  `kategori` enum('makanan','minuman','obat','pakaian','tenda','selimut','peralatan','lainnya') DEFAULT 'lainnya',
  `jumlah` int(11) DEFAULT 0,
  `satuan` varchar(30) DEFAULT 'unit',
  `sumber` varchar(150) DEFAULT NULL,
  `tanggal_masuk` date NOT NULL,
  `tanggal_distribusi` date DEFAULT NULL,
  `status` enum('tersedia','didistribusikan','habis') DEFAULT 'tersedia',
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `bencana_id` (`bencana_id`),
  KEY `posko_id` (`posko_id`),
  CONSTRAINT `logistik_ibfk_1` FOREIGN KEY (`bencana_id`) REFERENCES `bencana` (`id`) ON DELETE CASCADE,
  CONSTRAINT `logistik_ibfk_2` FOREIGN KEY (`posko_id`) REFERENCES `posko` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logistik`
--

LOCK TABLES `logistik` WRITE;
/*!40000 ALTER TABLE `logistik` DISABLE KEYS */;
INSERT INTO `logistik` VALUES (1,1,1,'Beras Premium 50kg','makanan',500,'karung','Gudang BNPB Pusat','2024-11-22',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(2,1,1,'Tenda Keluarga BNPB','tenda',150,'unit','BNPB Logistik','2024-11-22',NULL,'didistribusikan',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(3,2,2,'Masker N95 & Bedah','obat',10000,'kotak','Kemenkes RI','2024-12-05',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(4,2,2,'Air Mineral 600ml','minuman',2000,'dus','Donasi PMI','2024-12-05',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(5,4,3,'Selimut & Matras','selimut',1200,'paket','BPBD Sumbar','2025-05-12',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(6,4,3,'Paket Sembako Lengkap','makanan',800,'paket','Kemensos RI','2025-05-13',NULL,'didistribusikan',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(7,6,4,'Family Kit BNPB','peralatan',600,'paket','BNPB Pusat','2025-11-05',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(8,6,4,'Makanan Siap Saji','makanan',3000,'porsi','Dapur Umum Tagana','2025-11-05',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(9,12,5,'Bronjong Kawat Penahan Longsor','peralatan',100,'unit','PUPR Prov. Jabar','2026-10-06',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47'),(10,14,6,'Terpal & Genset Portable','peralatan',50,'unit','BPBD Sulteng','2026-10-15',NULL,'tersedia',NULL,'2026-10-22 09:19:47','2026-10-22 09:19:47');
/*!40000 ALTER TABLE `logistik` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posko`
--

DROP TABLE IF EXISTS `posko`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posko` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bencana_id` int(11) NOT NULL,
  `nama_posko` varchar(150) NOT NULL,
  `alamat` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `kapasitas` int(11) DEFAULT 0,
  `jumlah_pengungsi` int(11) DEFAULT 0,
  `penanggung_jawab` varchar(100) DEFAULT NULL,
  `kontak` varchar(20) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `bencana_id` (`bencana_id`),
  CONSTRAINT `posko_ibfk_1` FOREIGN KEY (`bencana_id`) REFERENCES `bencana` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posko`
--

LOCK TABLES `posko` WRITE;
/*!40000 ALTER TABLE `posko` DISABLE KEYS */;
INSERT INTO `posko` VALUES (1,1,'Posko Utama Lapangan Prawatasari','Jl. Surya Kencana No. 1, Cianjur',NULL,NULL,5000,3200,'Mayor Inf. Hendra W.','081234567801','aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(2,2,'Posko Terpadu Lapangan Candipuro','Jl. Raya Candipuro, Lumajang',NULL,NULL,3000,1850,'Bambang S., S.STP','081234567802','aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(3,4,'Posko Tanggap Darurat Bukik Batabuah','Kecamatan Canduang, Agam',NULL,NULL,1500,950,'Rahmat Hidayat, M.Si','081234567803','aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(4,6,'Posko Pengungsian Konga','Desa Konga, Titehena, Flores Timur',NULL,NULL,2500,1800,'Fransiskus X., S.Sos','081234567804','aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(5,12,'Posko Darurat Bencana Cisompet','Aula Kantor Camat Cisompet, Garut',NULL,NULL,800,420,'Drs. Asep Supriatna','081234567805','aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(6,14,'Posko Siaga Gempa Palu Selatan','Gedung Olahraga Siranindi, Kota Palu',NULL,NULL,1000,80,'Ir. Moh. Taufik','081234567806','aktif','2026-10-22 09:19:47','2026-10-22 09:19:47');
/*!40000 ALTER TABLE `posko` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provinsi`
--

DROP TABLE IF EXISTS `provinsi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provinsi` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `indonesia_id` int(11) NOT NULL,
  `nama_provinsi` varchar(100) NOT NULL,
  `kode_provinsi` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `indonesia_id` (`indonesia_id`),
  CONSTRAINT `provinsi_ibfk_1` FOREIGN KEY (`indonesia_id`) REFERENCES `indonesia` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provinsi`
--

LOCK TABLES `provinsi` WRITE;
/*!40000 ALTER TABLE `provinsi` DISABLE KEYS */;
INSERT INTO `provinsi` VALUES (1,1,'DKI Jakarta',NULL),(2,1,'Jawa Barat',NULL),(3,1,'Jawa Tengah',NULL),(4,1,'Jawa Timur',NULL),(5,1,'Banten',NULL),(6,1,'DI Yogyakarta',NULL),(7,1,'Bali',NULL),(8,1,'Nusa Tenggara Barat',NULL),(9,1,'Nusa Tenggara Timur',NULL),(10,1,'Sumatera Barat',NULL),(11,1,'Sumatera Utara',NULL),(12,1,'Aceh',NULL),(13,1,'Riau',NULL),(14,1,'Sumatera Selatan',NULL),(15,1,'Kalimantan Timur',NULL),(16,1,'Kalimantan Selatan',NULL),(17,1,'Sulawesi Selatan',NULL),(18,1,'Sulawesi Tengah',NULL),(19,1,'Sulawesi Utara',NULL),(20,1,'Papua',NULL);
/*!40000 ALTER TABLE `provinsi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relawan`
--

DROP TABLE IF EXISTS `relawan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relawan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bencana_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `nik` varchar(16) DEFAULT NULL,
  `organisasi` varchar(100) DEFAULT NULL,
  `keahlian` varchar(150) DEFAULT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `tanggal_bergabung` date NOT NULL,
  `tanggal_selesai` date DEFAULT NULL,
  `status` enum('aktif','selesai') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `bencana_id` (`bencana_id`),
  CONSTRAINT `relawan_ibfk_1` FOREIGN KEY (`bencana_id`) REFERENCES `bencana` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relawan`
--

LOCK TABLES `relawan` WRITE;
/*!40000 ALTER TABLE `relawan` DISABLE KEYS */;
INSERT INTO `relawan` VALUES (1,1,'dr. Ahmad Fauzi, Sp.B','3201011203850001','IDI Jawa Barat','Medis / Bedah Darurat','081122334455','fauzi.medis@gmail.com','2024-11-22',NULL,'selesai','2026-10-22 09:19:47','2026-10-22 09:19:47'),(2,1,'Siti Nurhaliza, S.Kep','3201015507920002','PMI Kota Bandung','Perawat Trauma Healing','081122334456','siti.nur@pmi.or.id','2024-11-22',NULL,'selesai','2026-10-22 09:19:47','2026-10-22 09:19:47'),(3,2,'Agus Triyono','3508012308900003','BASARNAS Surabaya','Pencarian & Penyelamatan (SAR)','081122334457','agus.sar@basarnas.go.id','2024-12-05',NULL,'selesai','2026-10-22 09:19:47','2026-10-22 09:19:47'),(4,4,'Ilham Pratama, S.T.','1306011405940004','Tagana Sumatera Barat','Logistik & Dapur Umum','081122334458','ilham.tagana@gmail.com','2025-05-12',NULL,'selesai','2026-10-22 09:19:47','2026-10-22 09:19:47'),(5,6,'Maria Goreti Fernandez','5306014402960005','Caritas Larantuka','Distribusi Logistik & Pengungsian','081122334459','maria.caritas@gmail.com','2025-11-05',NULL,'aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(6,12,'Dedi Suhendar','3205011904880006','BPBD Kabupaten Garut','Operator Alat Berat & Pembersihan','081122334460','dedi.bpbdgarut@gmail.com','2026-10-06',NULL,'aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(7,14,'Faisal Akbar','7271011111950007','KPA Palu Lestari','Asesmen Cepat & Navigasi Darat','081122334461','faisal.kpa@gmail.com','2026-10-15',NULL,'aktif','2026-10-22 09:19:47','2026-10-22 09:19:47'),(8,11,'I Wayan Sudarma','5107010808930008','FPRB Bali','Komunikasi Radio & Logistik','081122334462','wayan.fprb@gmail.com','2026-09-20',NULL,'aktif','2026-10-22 09:19:47','2026-10-22 09:19:47');
/*!40000 ALTER TABLE `relawan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `role` enum('admin','operator','viewer') DEFAULT 'viewer',
  `foto_profil` varchar(255) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Administrator BNPB','admin@bnpb.go.id','admin',NULL,'aktif',NULL,'2026-10-22 09:10:45','2026-10-22 09:10:45'),(2,'operator1','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Operator Satu','operator1@bnpb.go.id','operator',NULL,'aktif',NULL,'2026-10-22 09:10:45','2026-10-22 09:10:45');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-22 16:55:18
