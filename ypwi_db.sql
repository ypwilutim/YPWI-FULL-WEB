-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 21 Apr 2026 pada 06.07
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ypwi_db`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `attendance`
--

CREATE TABLE `attendance` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `asal_sekolah` varchar(255) DEFAULT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `tanggal` date DEFAULT curdate(),
  `jam` time DEFAULT curtime(),
  `status` enum('Datang','Pulang') DEFAULT 'Datang',
  `keterangan` text DEFAULT NULL,
  `sebagai` varchar(100) DEFAULT NULL,
  `no_wa` varchar(20) DEFAULT NULL,
  `jenis_absen` varchar(50) DEFAULT 'Absen',
  `device_id` varchar(255) DEFAULT NULL,
  `scan_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `attendance_devices`
--

CREATE TABLE `attendance_devices` (
  `id` int(11) NOT NULL,
  `device_id` varchar(255) NOT NULL,
  `device_name` varchar(255) NOT NULL,
  `device_location` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `tenant_id` varchar(50) NOT NULL,
  `created_by` int(11) NOT NULL,
  `status` enum('pending','active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `attendance_devices`
--

INSERT INTO `attendance_devices` (`id`, `device_id`, `device_name`, `device_location`, `phone_number`, `tenant_id`, `created_by`, `status`, `created_at`, `updated_at`) VALUES
(1, '99eb09f3-1fc6-41f1-9963-37fd8fc5c269', 'Fadli', 'Gerbang', '6285290359293', 'YPWILUTIM', 0, 'active', '2026-04-17 10:30:38', '2026-04-17 23:05:04');

-- --------------------------------------------------------

--
-- Struktur dari tabel `attendance_requests`
--

CREATE TABLE `attendance_requests` (
  `id` int(11) NOT NULL,
  `guru_id` int(11) NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `tenant_id` varchar(50) DEFAULT NULL,
  `alasan` text NOT NULL,
  `jenis` enum('Izin','Sakit') NOT NULL,
  `tanggal_mulai` date NOT NULL,
  `tanggal_akhir` date NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `attendance_rules`
--

CREATE TABLE `attendance_rules` (
  `id` int(11) NOT NULL,
  `tenant_id` varchar(50) NOT NULL,
  `type` enum('Datang','Pulang') NOT NULL,
  `waktu_mulai` time NOT NULL,
  `waktu_akhir` time NOT NULL,
  `keterangan` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `attendance_rules`
--

INSERT INTO `attendance_rules` (`id`, `tenant_id`, `type`, `waktu_mulai`, `waktu_akhir`, `keterangan`, `created_at`, `updated_at`) VALUES
(2, 'SYSTEM', 'Datang', '07:01:00', '07:30:00', 'Terlambat Tahap 1', '2026-04-18 10:40:19', '2026-04-18 10:40:19'),
(3, 'SYSTEM', 'Datang', '07:31:00', '08:00:00', 'Terlambat Tahap 2', '2026-04-18 10:40:19', '2026-04-18 10:40:19'),
(4, 'SYSTEM', 'Datang', '08:01:00', '12:00:00', 'Terlambat Lebih', '2026-04-18 10:40:19', '2026-04-18 10:40:19'),
(5, 'SYSTEM', 'Pulang', '12:00:00', '14:00:00', 'Tepat Waktu', '2026-04-18 10:40:19', '2026-04-18 10:40:19'),
(6, 'SYSTEM', 'Pulang', '14:01:00', '15:00:00', 'Pulang Cepat', '2026-04-18 10:40:19', '2026-04-18 10:40:19'),
(7, 'SYSTEM', 'Pulang', '15:01:00', '23:59:59', 'Lembur', '2026-04-18 10:40:19', '2026-04-18 10:40:19'),
(8, 'SYSTEM', 'Datang', '06:00:00', '07:00:00', 'Tepat Waktu', '2026-04-18 11:04:57', '2026-04-18 11:04:57');

-- --------------------------------------------------------

--
-- Struktur dari tabel `device_otp_requests`
--

CREATE TABLE `device_otp_requests` (
  `id` int(11) NOT NULL,
  `device_name` varchar(255) NOT NULL,
  `device_location` varchar(255) DEFAULT NULL,
  `tenant_code` varchar(50) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `otp` varchar(6) NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `device_otp_requests`
--

INSERT INTO `device_otp_requests` (`id`, `device_name`, `device_location`, `tenant_code`, `phone_number`, `otp`, `expires_at`, `used`, `created_at`) VALUES
(2, 'PC', 'Gerbang', 'YPWILUTIM', '628296859771', '840907', '2026-04-17 05:42:21', 0, '2026-04-17 05:32:21'),
(3, 'PC', 'Gerbang', 'YPWILUTIM', '628296859771', '352259', '2026-04-17 05:47:26', 0, '2026-04-17 05:37:26'),
(4, 'PC', 'Gerbang', 'YPWILUTIM', '628296859771', '183927', '2026-04-17 05:50:45', 0, '2026-04-17 05:40:45'),
(5, 'PC', 'Gerbang', 'YPWILUTIM', '628296859771', '407729', '2026-04-17 05:58:21', 0, '2026-04-17 05:48:21'),
(6, 'PC', 'Gerbang', 'YPWILUTIM', '628296859771', '922127', '2026-04-17 05:59:08', 0, '2026-04-17 05:49:08'),
(7, 'PC', 'Gerbang', 'YPWILUTIM', '628296859771', '307271', '2026-04-17 06:17:04', 0, '2026-04-17 06:07:04'),
(8, 'PC', 'Gerbang', 'YPWILUTIM', '628296859771', '338731', '2026-04-17 06:17:04', 0, '2026-04-17 06:07:04'),
(9, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '716811', '2026-04-17 06:20:15', 0, '2026-04-17 06:10:15'),
(10, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '929263', '2026-04-17 06:20:15', 0, '2026-04-17 06:10:15'),
(11, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '166307', '2026-04-17 06:35:35', 0, '2026-04-17 06:25:35'),
(12, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '735934', '2026-04-17 06:39:42', 0, '2026-04-17 06:29:42'),
(13, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '761062', '2026-04-17 06:49:48', 0, '2026-04-17 06:39:48'),
(14, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '593020', '2026-04-17 07:16:18', 0, '2026-04-17 07:06:18'),
(15, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '678843', '2026-04-17 07:21:48', 0, '2026-04-17 07:11:48'),
(16, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '399527', '2026-04-17 07:26:47', 0, '2026-04-17 07:16:47'),
(17, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '831327', '2026-04-17 07:44:17', 0, '2026-04-17 07:34:17'),
(18, 'PC', 'Gerbang', 'YPWILUTIM', '6282396859771', '208720', '2026-04-17 08:26:19', 0, '2026-04-17 08:16:19'),
(19, 'Qpc', 'fsdhk', 'YPWILUTIM', '6285290359293', '280503', '2026-04-17 08:52:29', 0, '2026-04-17 08:42:29'),
(20, 'Qpc', 'aa', 'YPWILUTIM', '6285290359293', '855727', '2026-04-17 09:01:52', 0, '2026-04-17 08:51:52'),
(21, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '619084', '2026-04-17 09:02:45', 0, '2026-04-17 08:52:45'),
(22, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '715327', '2026-04-17 09:03:10', 0, '2026-04-17 08:53:10'),
(23, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '324538', '2026-04-17 09:03:18', 0, '2026-04-17 08:53:18'),
(24, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '374279', '2026-04-17 09:09:05', 0, '2026-04-17 08:59:05'),
(25, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '812273', '2026-04-17 09:13:13', 0, '2026-04-17 09:03:13'),
(26, 'Test Device 2', 'Test Location 2', 'tkwahdah01', '6281234567890', '617934', '2026-04-17 09:13:57', 0, '2026-04-17 09:03:57'),
(27, 'Qpc', 'Gerbang', 'YPWILUTIM', '6282396859771', '826311', '2026-04-17 09:24:45', 0, '2026-04-17 09:14:45'),
(28, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '156756', '2026-04-17 09:27:19', 0, '2026-04-17 09:17:19'),
(29, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '530881', '2026-04-17 09:27:28', 0, '2026-04-17 09:17:28'),
(30, 'Test Device', 'Test Location', 'tkwahdah01', '082396859771', '129656', '2026-04-17 09:33:43', 0, '2026-04-17 09:23:43'),
(31, 'Test Device', 'Test Location', 'tkwahdah01', '6282396859771', '872249', '2026-04-17 09:34:55', 0, '2026-04-17 09:24:55'),
(32, 'Test Device', 'Test Location', 'tkwahdah01', '082396859771', '108231', '2026-04-17 09:35:42', 0, '2026-04-17 09:25:42'),
(33, 'Test Device', 'Test Location', 'tkwahdah01', '082396859771', '488979', '2026-04-17 09:36:19', 0, '2026-04-17 09:26:19'),
(34, 'Test Device', 'Test Location', 'tkwahdah01', '082396859771', '403743', '2026-04-17 09:36:36', 0, '2026-04-17 09:26:36'),
(35, 'Test Device', 'Test Location', 'tkwahdah01', '082396859771', '448214', '2026-04-17 09:36:54', 0, '2026-04-17 09:26:54'),
(36, 'Test Device', 'Test Location', 'tkwahdah01', '082396859771', '770550', '2026-04-17 09:39:09', 0, '2026-04-17 09:29:09'),
(37, 'Test Device', 'Test Location', 'tkwahdah01', '082396859771', '252854', '2026-04-17 09:39:56', 0, '2026-04-17 09:29:56'),
(38, 'Fadli', 'Gerbang', 'YPWILUTIM', '6285290359293', '158556', '2026-04-17 10:30:38', 1, '2026-04-17 10:30:24');

-- --------------------------------------------------------

--
-- Struktur dari tabel `jurnal`
--

CREATE TABLE `jurnal` (
  `id` int(11) NOT NULL,
  `teacher_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `materi` text DEFAULT NULL,
  `hadir` int(11) DEFAULT NULL,
  `absen` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `tenant_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `nama_siswa` varchar(255) NOT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') DEFAULT NULL,
  `tenant_id` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `jenjang` varchar(50) DEFAULT NULL,
  `nama_sheet` varchar(255) DEFAULT NULL,
  `nisn` varchar(20) DEFAULT NULL,
  `scan_id` varchar(50) DEFAULT NULL,
  `kelas` varchar(50) DEFAULT NULL,
  `iuran_bulanan` decimal(10,2) DEFAULT NULL,
  `nama_orang_tua` varchar(255) DEFAULT NULL,
  `no_wa` varchar(20) DEFAULT NULL,
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `teachers`
--

CREATE TABLE `teachers` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `niy` varchar(50) DEFAULT NULL,
  `nik` varchar(20) DEFAULT NULL,
  `scan_id` varchar(50) DEFAULT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') DEFAULT NULL,
  `tempat_lahir` varchar(100) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `no_wa` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `tenant_id` varchar(50) DEFAULT NULL,
  `jenjang` varchar(50) DEFAULT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `sebagai` varchar(100) DEFAULT NULL,
  `status_kepegawaian` varchar(100) DEFAULT NULL,
  `tmt` date DEFAULT NULL,
  `status_aktif` enum('Aktif','Tidak Aktif') DEFAULT 'Aktif',
  `keterangan` text DEFAULT NULL,
  `link_foto` varchar(500) DEFAULT NULL,
  `terima_notifikasi` tinyint(1) DEFAULT 1,
  `gaji_pokok` decimal(15,2) DEFAULT NULL,
  `tunj_kinerja` decimal(15,2) DEFAULT NULL,
  `tunj_umum` decimal(15,2) DEFAULT NULL,
  `tunj_istri` decimal(15,2) DEFAULT NULL,
  `tunj_anak` decimal(15,2) DEFAULT NULL,
  `tunj_kepala_sekolah` decimal(15,2) DEFAULT NULL,
  `tunj_wali_kelas` decimal(15,2) DEFAULT NULL,
  `honor_bendahara` decimal(15,2) DEFAULT NULL,
  `points` int(11) DEFAULT 0,
  `accessible_units` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`accessible_units`)),
  `jabatan_tambahan` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `teachers`
--

INSERT INTO `teachers` (`id`, `nama`, `niy`, `nik`, `scan_id`, `jenis_kelamin`, `tempat_lahir`, `tanggal_lahir`, `alamat`, `no_wa`, `email`, `password`, `tenant_id`, `jenjang`, `jabatan`, `sebagai`, `status_kepegawaian`, `tmt`, `status_aktif`, `keterangan`, `link_foto`, `terima_notifikasi`, `gaji_pokok`, `tunj_kinerja`, `tunj_umum`, `tunj_istri`, `tunj_anak`, `tunj_kepala_sekolah`, `tunj_wali_kelas`, `honor_bendahara`, `points`, `accessible_units`, `jabatan_tambahan`) VALUES
(768, 'Abu Bakar', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI01', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(769, 'Dra. Jasmiati', '', '', '', 'Perempuan', 'KALOSI', '1963-09-20', 'KOMPLEKS PONDOK SANTRI DARUSSALAM RANTE MARIO', '6282191739881', 'jasmiati09@admin.paud.belajar.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI01', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', '2013-07-07', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(770, 'Evha', '', '7324084107840052', '7324084107840052', 'Perempuan', 'Tomoni', '1984-09-16', 'Tomoni', '6281342232939', 'evhaaries16@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI01', '01 TKIT', 'Guru', 'Guru', 'Honor', '2019-01-01', '', 'Nama yang benar sesuai ktp dan ijazah Eva', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(771, 'Firda Harun', '-', '7324086103980001', '7324086103980001', 'Perempuan', 'Luwu Timur ', '1998-03-21', 'Dusun kebun rami 1 desa mandiri kec tomoni kab Luwu Timur ', '6282296855055', 'firdaharun98@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI01', '01 TKIT', 'Guru', 'Guru', 'Honor', '2019-01-07', '', '-', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(772, 'Fitriani', '', '', '', 'Perempuan', 'mandiri', '1990-04-27', 'perumahan melati 3 blok A22, desa beringin jaya', '6285123023837', 'fitricikgu@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI01', '01 TKIT', 'Guru', 'Guru', 'PTY', '2013-07-07', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(773, 'Rusmini, S.Pd', '', '73244084102780001', '73244084102780001', 'Perempuan', 'Tomoni', '1978-02-01', 'Lorong Rantemario Desa mandiri,kec Tomoni.Sping TK wahdah 01Tomoni ', '6282393617878', 'rusminigasari@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI01', '01 TKIT', 'Guru', 'Guru', 'Honor', '2014-07-07', '', 'Mulai mengajar 2014', 'uploads/RUSMINI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(774, 'St.Aswianih', '', '7324086404720001', '7324086404720001', 'Perempuan', 'Tomoni', '1972-04-24', 'Ds mandiri kec Tompni luwu timur', '6281259797914', 'st.aswiani@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI01', '01 TKIT', '', 'Guru', 'Honor', '2016-07-04', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(775, 'Brenda Clarita, S.AN., Gr', '1710199702201805002', '7324045710970002', '1710199702201805002', 'Perempuan', 'Bandung', '1997-10-17', 'Perumahan Bumi Sawita Permai, Blok G3 No. 6, Puncak Indah', '6282293613476', 'brendaclarita12@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', 'Walikelas', 'Guru', 'PTY', '2018-02-12', 'Aktif', '', 'uploads/BRENDA_CLARITA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(776, 'Fitriani', '', '', '', 'Laki-laki', '', '1990-04-27', '', '6285168729082', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', '', 'Guru', '', '2013-07-07', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(777, 'Idayati, S.Pd , Gr', '', '', '', 'Laki-laki', '', NULL, '', '6285284029835', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(778, 'Nadia Rahmayanti', '', '', '', 'Laki-laki', '', NULL, '', '6285256598051', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(779, 'Nuraeni Puspita, S.Pd', '', '', '', 'Laki-laki', '', NULL, '', '6285395070172', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(780, 'Nurhidayanti, S.E , Gr', '', '', '', 'Perempuan', 'Pangkep', '1992-12-21', 'Jalan Poros Malili Desa Ussu Dusun Salociu', '6285358585188', 'nhykara3112@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', 'Walikelas', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(781, 'Nurmianti', '', '', '', 'Laki-laki', '', NULL, '', '6285299032775', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', '', 'Guru', '', NULL, '', '', 'uploads/NURMIANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(782, 'Siti Faridah , S.Pd , Gr', '', '', '', 'Laki-laki', '', NULL, '', '6282121754604', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI02', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(783, 'Munira, S.Pd', '3005200107202408007', '7324117005010002', '3005200107202408007', 'Perempuan', 'Wasuponda ', '2001-05-30', 'Jln.Lasemba, Desa ledu-ledu, Kec. Wasuponda, Kab. Luwu timur ', '6281351302674', 'nhiramuni117@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI03', '01 TKIT', 'Guru', 'Guru', 'PTY', '2024-10-07', 'Aktif', '', 'uploads/MUNIRA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(784, 'Nilmalasari Ma, S.Pd', '270519910202514007', '7324116705990001', '270519910202514007', 'Perempuan', 'Wasuponda', '1999-05-27', 'Jalan sungai baliase 286 ', '6281248160004', 'nirmalaimha@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI03', '01 TKIT', 'Guru', 'Guru', 'PTY', '2021-07-04', '', '', 'uploads/NILMALASARI_MA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(785, 'Siti Khalimah, S.Si.,S.Pd', '2009198908201808001', '7322086009890001', '2009198908201808001', 'Perempuan', 'CENDANA PUTIH 1', '1989-09-20', 'Desa Ledu-Ledu, Kec. Wasuponda', '6285394968838', 'imhaumair7575@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI03', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', '2018-08-01', 'Aktif', '', 'uploads/SITI_KHALIMAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(786, 'Anggita Wulan Sary', '1005199407201909003', '7324015005940001', '1005199407201909003', 'Perempuan', 'Kalaena kiri', '1994-05-10', 'Desa Kalaena Kiri, Kec Kalaena,Kab Luwu Timur', '6285334633005', 'anggitawulansary36@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI04', '01 TKIT', 'Operator', 'Guru', 'PTY', '2019-04-10', '', '', 'uploads/ANGGITA_WULAN_SARY.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(787, 'Oelfionny Susanty,S.Pd', '1502199107201809001', '7324095502910001', '1502199107201809001', 'Perempuan', 'Kalaena kiri', '1991-02-15', 'Dusun tambak Yoso RT/RW: 002/00, Des. Kalaena kiri, Kec. Kalaena ', '6285342342857', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI04', '01 TKIT', 'Kepala Sekolah', 'Guru', 'Honor', '2018-07-09', 'Aktif', '', 'uploads/OELFIONNY_SUSANTY.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(788, 'WIDIAWATI ', '', '7324094112070001', '7324094112070001', 'Perempuan', 'KALAENA KIRI', '2007-07-09', 'Desa Mekarsari, kecamatan KALAENA, kabupaten LUWU TIMUR, provinsi SULAWESI SELATAN.', '6281946001224', 'dhyaayhaa@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI04', '01 TKIT', 'Guru', 'Guru', 'Honor', '2026-02-02', 'Aktif', '', 'uploads/WIDIAWATI_.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(789, 'Kartina', '1003199107202412002', '', '1003199107202412002', 'Laki-laki', '', NULL, '', '6285950625954', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI05', '01 TKIT', '', 'Guru', '', NULL, '', '', 'uploads/KARTINA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(790, 'Tutik Wartini, S.P.,Gr.', '3003199401202012001', '7324077003940001', '3003199401202012001', 'Perempuan', 'Lambarese', '1994-03-30', 'Dusun Majaleje, Desa Lambarese, Kecamatan Burau', '6285964390450', 'tutikwartini3394@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI05', '05 TK IT', 'Guru', 'Guru', 'PTY', '2020-01-01', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(791, 'Asmarawati', '101200501202321003', '7324064101050001', '101200501202321003', 'Perempuan', 'Wotu', '2005-01-01', 'jalan sangkuruwira kab.luwu timur kec.wotu desa.arolipu', '62822022975493', 'asmarawhatyr@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI06', '01 TKIT', 'Walikelas', 'Guru', 'PTY', '2022-11-01', 'Aktif', 'Selesai', 'uploads/ASMARAWATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(792, 'Fauziah Mumtahara', '2707200110202321005', '7324076707010001', '2707200110202321005', 'Perempuan', 'Bone - Bone ', '2001-07-27', 'Desa. Laro, Kecamatan. Burau, Kabupaten. Luwu Timur, Sulawesi Selatan.', '6282393023936', 'fauziyahchia@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI06', '01 TKIT', 'Guru', 'Guru', 'PTY', '2023-10-20', 'Aktif', 'Selesai ', 'uploads/FAUZIAH_MUMTAHARA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(793, 'Harmiyanti, S.P', '1006199806202117004', '7324066112990001', '1006199806202117004', 'Perempuan', 'Tarengge', '1999-12-21', 'Jl. SM. Al jufri, desa tarengge, kec.wotu, kab. Luwu timur', '628135445429', 'harmiyanti021@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI06', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', '2025-01-01', 'Aktif', '', 'uploads/HARMIYANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(794, 'Tenriani, S.E', '1402199206202221002', '7324065402920003', '1402199206202221002', 'Perempuan', 'Wotu', '1992-02-14', 'Desa Lera, Kecamatan Wotu, Sulawesi Selatan ', '6282293202069', 'tenriani51@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI06', '01 TKIT', 'Bendahara', 'Guru', 'PTY', '2022-06-01', 'Aktif', '', 'uploads/TENRIANI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(795, 'Hasnani', '1404198020230723003', '73240854404800002', '1404198020230723003', 'Perempuan', 'Tomoni ', '1980-04-14', 'Sindu agung kec.mangkutana kab.luwu timur ', '6282293003240', 'nanih0009@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI07', '01 TKIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(796, 'Peni Hamidah Kinasih', '', '7324015711890001', '7324015711890001', 'Perempuan', 'Trenggalek, 17 November 1989', '1989-11-17', 'Ds. Wonorejo Timur Kec. Mangkutana Kab. Luwu Timur, Sulsel', '628534369042', 'penihamidahkinasih@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI07', '01 TKIT', 'Guru', 'Guru', 'PTY', '2025-07-07', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(797, 'Reni Susanti.S,Pd.I', '1010199020230723001', '7314095010900012', '1010199020230723001', 'Perempuan', 'Pallae 10 Oktober 1990', '1990-10-10', 'Jln gagak.dusun sendang sari 1 desa Wonorejo kec.mangkutana Kab.Luwu timur ', '6282583545', 'reniballa90@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI07', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', '2023-07-17', 'Aktif', '', 'uploads/RENI_SUSANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(798, 'Titin Kumalasari. S.Pd', '1706198520230723002', '', '1706198520230723002', 'Perempuan', 'Wonorejo ', '2026-07-17', 'Kalpataru kecamatan Tomoni', '6285823022797', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI07', '01 TKIT', 'Guru', 'Guru', 'Honor', '2026-04-12', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(799, 'Zulfaturrohmi', '', '', '', 'Laki-laki', '', NULL, '', '6285341206181', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITWI08', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(800, 'FITRIANI HAWING, ST ., Gr.', '', '7324026804810004', '7324026804810004', 'Laki-laki', '', '1990-04-27', '', '6285331072870', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITRABBANI', '01 TKIT', '', 'Guru', '', '2013-07-07', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(801, 'JUNIARSIH AZIS, SE., Gr.', '', '', '', 'Laki-laki', '', NULL, '', '6281328671709', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITRABBANI', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(802, 'ARINI PUTRI, S.Kom', '', '7317065601970001', '7317065601970001', 'Laki-laki', '', NULL, '', '6282343575949', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITRABBANI', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(803, 'RESKY KHULDIAH', '', '7371104405030001', '7371104405030001', 'Laki-laki', '', NULL, '', '6285242873803', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITRABBANI', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(804, 'ANDI HILWA', '', '7207045510990001', '7207045510990001', 'Laki-laki', '', NULL, '', '6281282473682', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'TKITRABBANI', '01 TKIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(805, 'Ade Asmi Pratiwi, S.E., Gr.', '3010199301201702011', '7324047010930002', '3010199301201702011', 'Perempuan', 'Balantang', '1993-10-30', 'Jl. Peda-Peda Desa Balantang, Kec. Malili, Kab. Luwu Timur', '6281341778120', 'aa.pratiwi20@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2017-01-11', 'Aktif', '-', 'uploads/ADE_ASMI_PRATIWI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(806, 'Andi Kastiar Latif, S.Pd', '2312199307201702013', '', '2312199307201702013', 'Laki-laki', '', NULL, '', '6285242950927', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(807, 'Andini Putri Patrisia', '', '7324046910010001', '7324046910010001', 'Perempuan', 'MALILI', '2001-10-29', 'Desa wewangriu dusun salabu ', '6282190164267', 'andiniputripatrisia29@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'TU', 'Guru', 'Honor', '2026-02-02', '', '', 'uploads/ANDINI_PUTRI_PATRISIA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(808, 'Asrina, S.Pd.Gr', '2908198307201702015', '730666908830002', '2908198307201702015', 'Perempuan', 'Sungguminasa', '1983-08-29', 'Perumahan Bumi Batara Guru E1/L Ussu\'', '6285241646566', 'rhienachika@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2017-07-17', 'Aktif', '', 'uploads/ASRINA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(809, 'Dian Ekaviyanti R, Sp', '0407198501201902027', '7324044407850001', '0407198501201902027', 'Perempuan', 'Selayar', '1985-07-04', '', '6285299886477', 'dianekaviyantirusydi@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(810, 'Dwi Oktaviana, S.Pd., Gr.', '2610199807202102040', '7322026610980002', '2610199807202102040', 'Perempuan', 'BONE-BONE', '1998-10-26', 'JALAN POROS MALILI SOROAKO KILO 4, KABUPATEN LUWU TIMUR, SULAWESI SELATAN', '6285340978098', 'dwioktaviana2602@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2021-07-01', 'Aktif', '-', 'uploads/DWI_OKTAVIANA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(811, 'Elvira Fatriana, S.Pd., Gr.', '2105199909202302057', '9104016105990001', '2105199909202302057', 'Perempuan', 'Nabire', '1999-05-21', 'Jl. Soekarno Hatta, Dusun Mallaulu Indah, Kel. Puncak Indah, Kec. Malili, Kab. Luwu Timur, Sulawesi Selatan', '6285342142793', 'elvirafatriana@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2023-11-01', 'Aktif', '', 'uploads/ELVIRA_FATRIANA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(812, 'Ertika, S.Pd', '2703199711201804006', '', '2703199711201804006', 'Laki-laki', '', NULL, '', '6287833367139', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(813, 'Gisjawinta Ardo Maretza Nahary', '2203199901201902030', '9105016203990004', '2203199901201902030', 'Perempuan', 'Abepura', '1999-03-22', 'Jl. RA. KARTINI Desa Puncak Indah Kec. Malili', '6281283946264', 'gisja96@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'PTY', '2019-07-08', 'Aktif', '', 'uploads/GISJAWINTA_ARDO_MARETZA_NAHARY.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(814, 'Harmawati B, S.Pd., Gr. ', '3012199407201702014', '7324047012940001', '3012199407201702014', 'Perempuan', 'Malili', '1994-12-30', 'Jalan Poros Trans Sulawesi, Rt 1 Dusun Pabeta Desa Manurung', '6282151832923', 'harmawatiburhan@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2017-06-01', 'Aktif', '', 'uploads/HARMAWATI_B.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(815, 'Hasmiati, S.Pd', '0109197905201302005', '', '0109197905201302005', 'Perempuan', 'Macorawalie', NULL, 'Jl. H. Abdullah ', '6285341993378', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', '1979-09-01', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(816, 'Hasriani, S.Pd., Gr.', '2303199508201902029', '7317206302950001', '2303199508201902029', 'Perempuan', 'Kadong-Kadong', '1995-03-23', 'Jalan poros malili sorowako, km 4, puncak indah. ', '6282293333689', 'anhymuhlis23@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2019-08-01', 'Aktif', '', 'uploads/HASRIANI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(817, 'Hera Nasruddin, S.Pd', '', '7324046408000001', '7324046408000001', 'Perempuan', 'Takalar', '2000-08-24', 'Jl. H. Abdullah', '6282296132315', 'heranasruddin00@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'Honor', '2025-08-04', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(818, 'Hidayatunnisa, S.Pd, Gr.', '0505200007202202050', '7317024505000004', '0505200007202202050', 'Perempuan', 'komba', '2000-05-05', 'perumahan bumi batara guru, Blok D', '6281242451581', 'hidayatunnisa050500@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'PTY', '2022-07-01', 'Aktif', 'aktif mengajar', 'uploads/HIDAYATUNNISA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(819, 'Hildawati Dulla, S.Pd', '1612199501201902028', '7324115812950001', '1612199501201902028', 'Perempuan', 'Kawata', '1995-12-16', 'Dsn Kawata, Desa Kawata, Kecamatan Wasuponda, \nKabupaten Luwu Timur', '6285396726741', 'hildawatidulla62@guru.sd.belajar.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2019-07-01', 'Aktif', 'Tidak ada', 'uploads/HILDAWATI_DULLA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(820, 'Hizratul Laily, S.H', '0709199707202102038', '7322104709970001', '0709199707202102038', 'Perempuan', 'Sumber Ase', '1997-09-07', 'Sumber Ase', '6285342714652', 'hizratullaily1997@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'PTY', '2021-07-01', 'Aktif', '-', 'uploads/HIZRATUL_LAILY.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(821, 'Iin, S.Pd.Gr', '2701199408201902031', '7317206708900001', '2701199408201902031', 'Perempuan', 'Dadeko', '1994-01-27', 'Jln Poros Sorowako Malili Km 4 Desa Puncak Indah', '6285255148455', 'iinchubby66@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2019-08-01', 'Aktif', '-', 'uploads/IIN.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(822, 'Ita Nurhasanah, S.Pd., Gr.', '1206199507202002032', '7324056305980001', '1206199507202002032', 'Perempuan', 'Tawakua', '1995-06-12', 'Desa Tawakua, Kec. Angkona Kab. Luwu Timur ', '6285256487593', 'itanurhasanah255@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'PTY', '2020-07-06', 'Aktif', '.', 'uploads/ITA_NURHASANAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(823, 'Julianti, S.Pd.,Gr', '1207200001202302053', '7324045207990002', '1207200001202302053', 'Perempuan', 'Lakawali ', '2000-07-12', 'Dusun Balimas, Desa Lakawali, Kec. Malili, Kab. Luwu Timur ', '6287704710579', 'juliantyanty1@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2023-01-02', 'Aktif', '.', 'uploads/JULIANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(824, 'Kurniati, A.Md, Pd. Or', '0512198010201802024', '7373094312800002', '0512198010201802024', 'Perempuan', 'Sorowako', '1980-12-05', 'Perumahan PNS Malili Homebass  ', '6285255007658', 'kurniatimangenre@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'PTY', '2018-10-08', 'Aktif', '', 'uploads/KURNIATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(825, 'Mama Ratna', '123456789', '', '123456789', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(826, 'Maya Prasetya, S.E', '1303199809202302056', '7373095303980001', '1303199809202302056', 'Perempuan', 'Rampoang', '1998-03-13', 'JL. SUNGAI PIKUNG NO.84', '6285240298161', 'mayaprasetya1112@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2023-11-01', 'Aktif', '-', 'uploads/MAYA_PRASETYA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(827, 'Maya Puspita Djasnah, S.Pd., Gr.', '1903198709202202051', '7373095903870003', '1903198709202202051', 'Perempuan', 'Palopo', '1987-03-19', 'Trans lor.1 ,Perum sawita permai blok C6 Puncak Indah Malili', '6282271071557', 'mayapuspitadjasnha@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2022-09-01', 'Aktif', '-', 'uploads/MAYA_PUSPITA_DJASNAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(828, 'Misnatun', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(829, 'Muthiah', '2401200607202402060', '7324046401060002', '2401200607202402060', 'Perempuan', 'MACORAWALIE ', '2006-01-24', 'Jl.H.Abdullah,Malili', '6285245175674', 'tiaaamuthiah@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'Honor', '2024-07-08', 'Aktif', '', 'uploads/MUTHIAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(830, 'Nadia Az Zahra', '2703200607202402059', '', '2703200607202402059', 'Perempuan', 'Manurung', '2006-03-27', 'Lakawali, depan kantor pertanian', '6281340407911', 'narah2736@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', '', '2024-05-13', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(831, 'Nadya Pithazmi Bukhari, S.H', '2405200107202402061', '1305056405010003', '2405200107202402061', 'Perempuan', 'Pariaman', '2001-05-24', 'Jl. Dr. Sam Ratulangi', '6285215038392', 'nadya.pithazmi24@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'Honor', '2024-09-02', 'Aktif', '-', 'uploads/NADYA_PITHAZMI_BUKHARI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(832, 'Nur Azizah, S.Pd', '2907199001201702016', '', '2907199001201702016', 'Laki-laki', '', NULL, '', '6281259798206', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(833, 'Nur Halisah, S.Pd, Gr. ', '0604199901202202049', '7324044604990001', '0604199901202202049', 'Perempuan', 'Malili', '1999-04-06', 'JL. H. ABDULLAH KEL. MALILI, KEC. MALILI, KAB. LUWU TIMUR', '6285256111582', 'nurhalisahaminu4@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2022-01-10', 'Aktif', 'Sudah lengkap', 'uploads/NUR_HALISAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(834, 'Nur Fajriani. US, S.S.,Gr', '1212199307201602010', '7324045212930002', '1212199307201602010', 'Perempuan', 'Same', '1993-12-12', 'Jln. Jenderal sudirman Lr. Al Misfalah', '6282292791522', 'fajrianinur66@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2016-07-01', 'Aktif', '', 'uploads/NUR_FAJRIANI._US,_S.s.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(835, 'Nurhaeni, S.Pd., M.Pd', '-', '7308195509960001', '7308195509960001', 'Perempuan', 'BONE', '1996-09-15', 'Jln poros Malili-sorowako, Desa Ussu, kec. Malili, Luwu Timur', '6285242896894', 'nurhaeniqm18@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'Honor', '2025-07-21', '', '-', 'uploads/NURHAENI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(836, 'Reski Elvira Sari, S.Pd., Gr.', '0707199909202202052', '7324044707990002', '0707199909202202052', 'Perempuan', 'Soroako ', '1999-07-07', 'Dusun Salabu, Desa Wewangriu', '6285146346540', 'reski.e.s.07@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2022-09-01', 'Aktif', '-', 'uploads/RESKI_ELVIRA_SARI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(837, 'Rismawati, S.Pd,Gr', '2505199507201802022', '7324046505950003', '2505199507201802022', 'Perempuan', 'Malili', '1995-05-25', 'Jln. Bandeng Balantang ', '6285396643325', 'rismawati44612@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2018-07-09', 'Aktif', '-', 'uploads/RISMAWATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(838, 'Sabaria, S.Pd', '1210199610202402062', '7601015210960004', '1210199610202402062', 'Perempuan', 'Kalola', '1996-12-10', 'KM.4 Jl. Poros sorowako. Kec. Malili', '6282290449324', 'sabaria121096@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'Honor', '2024-11-10', 'Aktif', '', 'uploads/SABARIA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(839, 'Saidatul Musayyada, S.Pd', '0112199802202202048', '', '0112199802202202048', 'Laki-laki', '', NULL, '', '6287720276180', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(840, 'Sri Mulyani, S.Pd., Gr.', '1705199811202102046', '7324045705980001', '1705199811202102046', 'Perempuan', 'Tator', '1998-05-17', 'Dsn Puncak Desa Tarabbi Kec Malili Kab Luwu Timur ', '6282293674236', 'Srisrimulyani10@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Walikelas', 'Guru', 'Honor', '2021-04-12', 'Aktif', '-', 'uploads/SRI_MULYANI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(841, 'Sri Rahayu, S.Pd,Gr', '2110199502201802018', '7311056110950001', '2110199502201802018', 'Perempuan', 'Barantang', '1995-10-21', 'Puncak Indah, Lorong depan satpol PP', '6285341377101', 'srirahayu211095@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'PTY', '2018-01-01', 'Aktif', '', 'uploads/SRI_RAHAYU.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(842, 'Susilawati, S.Pd., Gr', '0709199003201802020', '7324074709900003', '0709199003201802020', 'Laki-laki', 'Malaysia', '1990-09-07', 'Jl. Poros Malili-Sorowako kilometer 4 puncak Indah', '6281241847365', 'susilawatihaeruddin1990@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', 'Guru', 'Guru', 'PTY', '2018-03-05', 'Aktif', '', 'uploads/SUSILAWATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(843, 'Uppi Erniati H, S.Pd', '1410198901201902026', '', '1410198901201902026', 'Laki-laki', '', NULL, '', '628114250589', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITIRA', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(844, 'Andi Hildayanti, S.H, Gr', '1707199507202107017', '7324025707960001', '1707199507202107017', 'Perempuan', 'Sorowako ', '1995-07-17', 'Jln. Andi Jemma no. 4 Sorowako, kecamatan Nuha kabupaten Luwu Timur ', '6285334327660', 'andihildayanti147@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2021-01-25', '', '', 'uploads/ANDI_HILDAYANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(845, 'Arifin Azis', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(846, 'Asma Sahir', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(847, 'Eka Setya Ningsih', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(848, 'Eki Arif', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(849, 'Fatimah Uswah Choriyah', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/FATIMAH_USWAH_CHORIYAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(850, 'Hartati', '737109450676001', '', '737109450676001', 'Laki-laki', '', NULL, '', '623', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(851, 'Indah Dara Ayu', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/INDAH_DARA_AYU_GITA_SARI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(852, 'Ismawati, S.T.', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(853, 'Lisa Ariyanti, S.Pd.,Gr.', '0603199707202007011', '7322114603970001', '0603199707202007011', 'Perempuan', 'Sabah', '1997-03-06', 'Jln. Krakatau F274 Kec. Nuha Kel. Magani kab. Luwu Timur', '6281354613825', 'lisaariyanti006@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', 'Guru', 'Guru', 'PTY', '2020-07-20', 'Aktif', '...', 'uploads/LISA_ARIYANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(854, 'Lisdayanti S.M', '06022000007202407033', '7322114602000001', '06022000007202407033', 'Perempuan', 'Tarobok', '2000-02-06', 'Jl Tosalili No 89 Kelurahan Nikkel Kecamatan Nuha Kab. Luwu Timur\n', '6285397367054', 'lisdayantiilyas9@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2024-07-08', 'Aktif', 'Syukron Jazakillahu Khair', 'uploads/LISDAYANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(855, 'Mardiana, S.St', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/MARDIANA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(856, 'Mawar, S.Pd.I', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/MAWAR.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(857, 'Muhammad Syahrul', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/MUHAMMAD_SYAHRUL.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(858, 'Mutmainnah, S.Pd.', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/MUTMAINNAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(859, 'Nurazizah', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(860, 'Nursal', '7324021801800001', '', '7324021801800001', 'Laki-laki', '', NULL, '', '623', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(861, 'Rafiqa Dilah ', '0808199801202407032', '7324014112030003', '0808199801202407032', 'Perempuan', 'Balai Kembang ', '1998-08-08', 'Jl. Danau Matano lr 1, Desa Sorowako, Kec. Nuha', '6285396233362', 'rafiqadilah88@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', 'Walikelas', 'Guru', 'Honor', '2024-01-08', 'Aktif', '', 'uploads/RAFIQA_DILAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(862, 'Sartika Ainun B.', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/SARTIKA_AINUN_B..jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(863, 'Sukmawati', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/SUKMAWATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(864, 'Try Nur Handayani, S.Pd., M.Pd.', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(865, 'Wahidah, S.Pd.', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI03', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(866, 'Adi Farham Mahada, S.H.,M.Pd., Gr.', '1804199406202201022', '7316031804940001', '1804199406202201022', 'Laki-laki', 'Bone-Bone ', '1994-04-18', 'Sumber Alam, kec Tomoni', '6285242510615', 'adifarhan180494@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Guru', 'Guru', 'PTY', '2018-10-15', 'Aktif', '?', 'uploads/ADI_FARHAM_MAHADA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(867, 'Ainun Latifah S, S.H.', '1411200101202504045', '7324075411020001', '1411200101202504045', 'Perempuan', 'Laro', '2001-11-14', 'Desa Lambara Harapan Kec. Burau Kab. Luwu Timur', '628282333835399', 'nurulatifahalain@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2025-01-01', 'Aktif', 'Aktif mengajar hingga saat ini', 'uploads/AINUN_LATIFAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(868, 'Amira Khairiyah, S.H.', '', '', '', 'Laki-laki', '', NULL, '', '6287798421435', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(869, 'Andryani, S.Pd.,Gr.', '1807199507201904013', '7324065806950001', '1807199507201904013', 'Perempuan', 'Kanawatu', '1995-06-18', 'Desa Kanawatu, Kec. Wotu', '6281243725451', 'andryani86@guru.sd.belajar.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2019-07-09', 'Aktif', 'Aktif mengajar hingga saat ini', 'uploads/ANDRYANI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(870, 'Angsar Arif, S.Pd', '', '', '', 'Laki-laki', '', NULL, '', '628285242008838', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(871, 'Annis. S.Pd.,Gr', '0501198007198004004', '7324080507800001', '0501198007198004004', 'Laki-laki', 'TOMONI', '1980-01-05', 'Desa Mandiri, Kec Tomoni, kab luwu Timur', '6282348074057', 'annisrazak51@guru.sd.belajar.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', 'SD', 'Guru', 'Guru', 'PTY', '2018-07-01', 'Aktif', '-', 'uploads/ANNIS.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(872, 'Ayu Wulandari, S.A.N.', '', '', '', 'Laki-laki', '', NULL, '', '62895406569115', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(873, 'Bella Angriani, S.Pd., Gr.', '', '7324066301950001', '7324066301950001', 'Perempuan', 'Wotu', '1995-01-23', 'Jalan Rante Mario, Desa Kalpataru, Kecamatan Tomoni', '628282291607767', 'Ummuzakiyah0511@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', 'PTY', '2023-01-09', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(874, 'Fitriana', '1010199707201604003', '7324085010970001', '1010199707201604003', 'Perempuan', 'Tomoni', '1997-10-10', 'Jl. Sangkuruwira\nKel. Tomoni\nKec. Tomoni\nKab. Luwu Timur', '6282190248357', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Guru', 'Guru', 'PTY', '2016-07-04', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(875, 'Gr. Nita Jalil, S.Pd', '1003199601201904011', '7317195003960001', '1003199601201904011', 'Laki-laki', 'Salubua', '1996-03-10', 'Jl.Rantemario Desa Kalpataru Kec.Tomoni Kab.Luwu Timur', '6282395747460', 'nitajalil4@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2019-01-01', 'Aktif', '-', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(876, 'Gr.Rahmadani, S.Pd.', '1403198811201404002', '7324015204880001', '1403198811201404002', 'Perempuan', 'Wonorejo ', '1988-03-14', 'Desa Wonorejo, kec Mangkutana, kab Luwu Timur ', '628285241589800', 'rahmadani202021@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Guru', 'Guru', 'PTY', '2014-07-01', 'Aktif', 'Alhamdulillah ', 'uploads/GR.RAHMADANI,_S.PD..jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(877, 'Hasan', '', '', '', 'Laki-laki', '', NULL, '', '628281342996386', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(878, 'Husnul Khotimah, S.Pd., Gr.', '1609199710202204027', '7324105609970002', '1609199710202204027', 'Perempuan', 'Luwu Timur ', '1997-09-16', 'Lr. 13 barat, Desa Margomulyo, Kec. Tomoni Timur Kab Luwu timur ', '628282261154776', 'kaktuspalopo@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2022-10-01', 'Aktif', 'Aktif mengajar hingga saat ini', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(879, 'Kiki Nuryanti M, S.Pd., Gr.', '3108199801202204023', '7322117108980003', '3108199801202204023', 'Perempuan', 'Sassa', '1998-08-31', 'Desa Sassa kecamatan baebunta ', '628285240564386', 'kikinuryanti409@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2022-01-10', '', 'Aktif sampai sekarang', 'uploads/KIKI_NURYANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(880, 'Lia Samdani, S.Pd.', '0303200301202304040', '7322024303030003', '0303200301202304040', 'Perempuan', 'Masamba', '2003-03-03', 'Desa Kalpataru, Kec.Tomoni, Kab. Luwu Timur', '628285246331652', 'liasamdani102@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2024-09-30', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(881, 'Muhammad Nur, S.H.', '', '', '', 'Laki-laki', '', NULL, '', '6282346659462', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(882, 'Nur Aisyah', '-', '7371124101880022', '7371124101880022', 'Perempuan', '', NULL, 'Dusun marannu, des. Kalpataru, Kec. tomoni', '628285340964936', 'aisyahmattoreang88@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PKY', '2014-06-01', 'Aktif', 'Lupa tanggal dan bulan pastinya  masuk ', 'uploads/NUR_AISYAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(883, 'Nurazizatul Mukarramah, S.Pd., Gr.', '', '', '', 'Laki-laki', '', NULL, '', '628282391886892', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(884, 'Nurjaya Syamsualam, S.Si., Gr.', '', '', '', 'Laki-laki', '', NULL, '', '628282291115056', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(885, 'Nurmianti, S.Pd., M.Pd.,Gr.', '', '', '', 'Laki-laki', '', NULL, '', '628282333825794', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/NURMIANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(886, 'Peni Zulaika, S.P., Gr.', '', '7322085109990003', '7322085109990003', 'Perempuan', 'Salobongko', '1999-09-11', 'Jln. Rantemario desa kalpataru kec. Tomoni kab. Luwu Timur ', '6282319736352', 'penisaruddin@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Guru', 'Guru', 'PTY', '2022-02-03', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(887, 'Ratnawati, S.Pd.', '0408198907202004014', '7324094408980002', '0408198907202004014', 'Perempuan', 'Pertasi Kencana', '1998-08-04', 'Kel. Tomoni, Kec. Tomoni, Kab. Luwu Timur', '6282214846194', 'nurratnawati48@guru.sd.belajar.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2019-07-08', 'Aktif', 'Aktif mengajar hingga saat ini. ', 'uploads/RATNAWATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(888, 'Widia Sakir, S.Kom.', '27109901202504046', '7322086710990001', '27109901202504046', 'Perempuan', 'Mario', '1999-10-27', 'Jl. Rantemario Desa Kalpataru, Kec.Tomoni Kab.Luwu Timur', '6285240873905', 'Widiasakirftkom2016@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI02', '02 SDIT', 'TU', 'Guru', 'PTY', '2025-01-01', 'Aktif', 'Aktif sampai sekarang', 'uploads/WIDIA_SAKIR.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(889, 'Abd. Habib  S.Pd', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI04', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(890, 'Juhaena Renta S.Pd., Gr. ', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI04', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(891, 'Lilis Saputri', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI04', '02 SDIT', '', 'Guru', '', NULL, '', '', 'uploads/LILIS_SAPUTRI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(892, 'Muh. Ali', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI04', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(893, 'Nadia', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI04', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(894, 'Nur Fadillah', '2005200006202211007', '7322025003010006', '2005200006202211007', 'Perempuan', 'Ujung tanah ', '2001-03-10', 'Jln trans Sulawesi kab.luwu Utara kec.tana lili desa Bungadidi dusun ujung tanah ', '6282346767661', 'fadhilahnur368@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI04', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2023-09-20', '', 'Sebagai guru ', 'uploads/NUR_FADILLAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(895, 'Ramang S.Pd., Gr. ', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI04', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(896, 'Amy Fidyaningsih, S.Pd.', '', '7324094212010002', '7324094212010002', 'Laki-laki', '', NULL, '', '6282350465725', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL);
INSERT INTO `teachers` (`id`, `nama`, `niy`, `nik`, `scan_id`, `jenis_kelamin`, `tempat_lahir`, `tanggal_lahir`, `alamat`, `no_wa`, `email`, `password`, `tenant_id`, `jenjang`, `jabatan`, `sebagai`, `status_kepegawaian`, `tmt`, `status_aktif`, `keterangan`, `link_foto`, `terima_notifikasi`, `gaji_pokok`, `tunj_kinerja`, `tunj_umum`, `tunj_istri`, `tunj_anak`, `tunj_kepala_sekolah`, `tunj_wali_kelas`, `honor_bendahara`, `points`, `accessible_units`, `jabatan_tambahan`) VALUES
(897, 'Anisa Lusiana, S.E.', '0406200008202312008', '7324094406000001', '0406200008202312008', 'Laki-laki', '', NULL, '', '6282329514625', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(898, 'Anisa, Sp.', '2208199606202013005', '7324088208960001', '2208199606202013005', 'Laki-laki', '', NULL, '', '6282259333326', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(899, 'Lisma, S.Pd.', '0601199610202013006', '7324054601960001', '0601199610202013006', 'Laki-laki', '', NULL, '', '6285942923397', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(900, 'Putrilia Ismawati, S.Pd.', '3003199507202113007', '7324017003950001', '3003199507202113007', 'Laki-laki', '', NULL, '', '6282345744032', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(901, 'Salsabila Khaerunnisa', '', '7324095409060001', '7324095409060001', 'Laki-laki', '', NULL, '', '6287882839234', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(902, 'Sasi Eva Sulastri, S.Pd.', '0606199607201913002', '7324094606960002', '0606199607201913002', 'Laki-laki', '', NULL, '', '6285399539648', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(903, 'Wanasri, S.Pd. Gr.', '0810198907201913001', '73240848110900001', '0810198907201913001', 'Laki-laki', '', NULL, '', '6282318392228', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(904, 'Wiwin Fujianti, S.Pd.', '', '7324094208020001', '7324094208020001', 'Laki-laki', '', NULL, '', '6282375735197', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI05', '02 SDIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(905, 'RUDIANTO, S. Pd.,Gr', '2704198007201910000', '7324022704600001', '2704198007201910000', 'Laki-laki', 'MADINING ', '1980-04-27', 'JL.G.MERAPI WASUPONDA ', '6281355682040', 'rudi24829@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', 'SDIT', 'Kepala Sekolah', 'Guru', 'PTY', '2019-07-11', 'Aktif', '-', 'uploads/RUDIANTO.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(906, 'RASLIA, S. Pd', '0511198908202014003', '7373015105890001', '0511198908202014003', 'Perempuan', 'Sorowako ', '1989-05-11', 'Jln.sangkis no.8 desa ledu-ledu ', '6282228576601', 'lhyakhansa5@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2021-07-05', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(907, 'NUR SRININGSIH', '2908198910202214007', '7324116908890001', '2908198910202214007', 'Perempuan', 'Wasuponda', '1989-08-29', 'Jl.gunung bawakaraeng, no.44 ', '6282187417349', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', '02 SDIT', 'Walikelas', 'Guru', 'Honor', '2022-10-03', '', '', 'uploads/NUR_SRININGSIH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(908, 'SUKMAYANTI MASDING', '0510198404202314008', '7324114510840002', '0510198404202314008', 'Perempuan', 'Wasuponda', '1984-10-05', 'Jln.nenas poros matabuntu\nDesa: Ledu-Ledu \nKec: Wasuponda ', '6285341406598', 'sukmayantimasding2022@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', '02 SDIT', 'Walikelas', 'Guru', 'Honor', '2023-04-03', 'Aktif', '-', 'uploads/SUKMAYANTI_MASDING.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(909, 'ST. FATIMAH MASDING, S. Pd', '2008200007202414009', '7324116008000003', '2008200007202414009', 'Perempuan', 'Wasuponda', '2000-08-20', 'Jl. Manggis, Desa Ledu-ledu, Kec. Wasuponda ', '6282347394198', 'fatimahmasd87@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', '02 SDIT', 'Walikelas', 'Guru', 'Honor', '2024-07-08', 'Aktif', '-', 'uploads/ST_FATIMAH_MASDING.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(910, 'HERMAWATI', '1912197909202414010', '7324115912790003', '1912197909202414010', 'Perempuan', 'SOROAKO', NULL, 'JL.SANGKE NO.74\nDESA :LEDU-LEDU  KEC : WASUPONDA', '6281243835546', 'hw9798688@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', '02 SDIT', 'Walikelas', 'Guru', '', '2024-12-09', '', '', 'uploads/HERMAWATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(911, 'MEGAWATI JUANDA, S.Pd', '0608198911202514011', '7324114808890001', '0608198911202514011', 'Perempuan', 'Bonepute', '1989-08-06', 'Jalan jambu, Wasuponda', '6285398229586', 'megajuanda89@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', '02 SDIT', 'Walikelas', 'Guru', 'Honor', '2025-11-10', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(912, 'NUR TANTI AULIA,S.Pd', '0309199709202114005', '', '0309199709202114005', 'Laki-laki', '', NULL, '', '6282344915054', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI06', '', '', '', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(913, 'Abdul Wafiq Kadir, S.Pd', '1006199806202117004', '7313101006960001', '1006199806202117004', 'Laki-laki', 'BULUTIRONG', '1998-06-10', 'Desa Tarengge, Jln SMA Al Jufri', '6285240643713', 'kadirwafiq291@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI07', '02 SDIT', 'Kepala Sekolah', 'Guru', 'PTY', '2021-04-11', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(914, 'Harmiyanti, S.P', '2112199906202117001', '7324066112990001', '2112199906202117001', 'Perempuan', 'Tarengge', '1999-12-21', 'Jl. SM Al jufri, desa tarengge, kec. Wotu, kab. Luwu timur', '628135445429', 'harmiyanti021@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI07', '02 SDIT', 'Guru', 'Guru', 'PTY', '2025-01-01', 'Aktif', 'Amanah di SD: Bendahara, wali kelas, dan guru mapel', 'uploads/HARMIYANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(915, 'Hasnia, S.Ag', '', '7324065201010004', '7324065201010004', 'Perempuan', 'Korombua', '2001-10-12', 'Desa Rinjani Kecamatan  Wotu Kabupaten Luwu Timur ', '6285946507315', 'hasniahllp18@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI07', '02 SDIT', 'Guru', 'Guru', 'Honor', '2025-08-08', 'Aktif', 'Guru Baru', 'uploads/HASNIA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(916, 'Siti Nabila', '0107200607202417006', '7317090000000000', '0107200607202417006', 'Perempuan', 'Lamasi', '2006-07-01', 'Dusun Gerumbul 2, Desa wiwitan timur, kec.lamasi, kab.luwu, sulawesi selatan', '62895425681616', 'nabilaasiti04@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI07', '02 SDIT', 'Guru', 'Guru', 'PTY', '2023-06-06', 'Aktif', '', 'uploads/SITI_NABILA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(917, 'Tenriani, S.E', '1402199206202221002', '7324065402920003', '1402199206202221002', 'Perempuan', 'Wotu', '1992-02-14', 'Desa Lera, Kecamatan Wotu, Sulawesi Selatan', '6282293202069', 'tenriani51@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI07', '02 SDIT', 'Guru', 'Guru', 'PTY', '2022-06-01', 'Aktif', '', 'uploads/TENRIANI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(918, 'Indah Kurniati, S.Pd', '1204199807202318004', '7371125204980001', '1204199807202318004', 'Perempuan', 'Ujung Pandang ', NULL, 'Perumahan Griya Alam Towuti, blok A no 1.3 ', '6285241182668', 'indahkurniati118@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI08', '02 SDIT', 'Walikelas', 'Guru', 'PKY', NULL, '', '', 'uploads/INDAH_KURNIATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(919, 'Isti Maisarah, S.Si', '1505199107202118002', '7322105505910005', '1505199107202118002', 'Perempuan', 'cendana putih I', '1991-05-15', 'jalan harimau no 1B desa langkea raya kecamatan Towuti', '6282344915562', 'istymaisarah@gamail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI08', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2021-07-01', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(920, 'Marsha Cikita, S.Pd', '0612200007202318003', '7324044612000003', '0612200007202318003', 'Perempuan', 'Malili Luwu Timur', '2000-12-06', 'Wawondula jalan labu masjid babul jannah', '6282291277833', 'marshacikita06@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI08', '08 SDIT', 'Walikelas', 'Guru', 'PTY', '2023-07-11', 'Aktif', '', 'uploads/MARSHA_CIKITA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(921, 'Mini Kusmiana,S.Sos', '', '7324035512020002', '7324035512020002', 'Perempuan', 'Bantilang', '2002-12-15', 'Perumahan Ninda kenzu6 matompi ', '6282245260159', 'Miniksmiana M', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI08', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2025-07-01', '', '', 'uploads/MINI_KUSMIANA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(922, 'Muh Kurniawan, S.H.', '3103199607202118001', '7324023103960001', '3103199607202118001', 'Laki-laki', 'Sorowako', '1996-03-31', 'Jl. jend. Sudirman 82, Timampu', '6282194954503', 'muhk68@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI08', '02 SDIT', 'Kepala Sekolah', 'Guru', 'PTY', '2021-07-07', 'Aktif', '', 'uploads/MUH_KURNIAWAN,_S.H..jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(923, 'Nur Sartisyah', '-', '7324035502060002', '7324035502060002', 'Perempuan', 'Wawondula/KAB.LUTIM', '2006-02-15', ' JL. Garuda No. 06, Desa Langkea Raya, Kec. Towuti, Kab. Luwu Timur ', '6281241659346', 'nursartisyah04@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI08', '02 SDIT', 'Guru', 'Guru', 'PKY', '2025-07-01', 'Aktif', '-', 'uploads/NUR_SARTISYAH.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(924, 'Tiara Nurainun, S.Pd.', '1803199507202418005', '7317085803950002', '1803199507202418005', 'Perempuan', 'Kandoa', '1995-03-18', 'Jalan Gunung Sora No. 4, Kontrakan ke 10, Desa Wawondula, Kecamatan Towuti', '6285656272289', 'Uwaistiaranurainun@gmail.com/Tiaranurainunecce@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI08', '02 SDIT', 'Walikelas', 'Guru', 'PTY', '2024-07-01', 'Aktif', 'Wali Kelas sekaligus Tata Usaha', 'uploads/TIARA_NURAINUN,_S.PD..jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(925, 'Muh. Taufiq, S.Pd.,Gr.', '2503199301202425001', '7324082503930001', '2503199301202425001', 'Laki-laki', 'Kawarasan', '1993-03-25', 'Jl. Nuri, Kel. Tomoni, Kec. Tomoni', '6282249939502', 'muhtaufiq139@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI09', '02 SDIT', 'Kepala Sekolah', 'Guru', 'PTY', '2024-07-01', 'Aktif', '', 'uploads/MUH_TAUFIQ.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(926, 'Winda Arjuna, S.Pd.,Gr.', '', '7317136306940001', '7317136306940001', 'Perempuan', '', '1994-06-23', 'Jl. Nuri, Kel. Tomoni, Kec. Tomoni', '6285397430091', 'windaarjuna134@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SDITWI09', '02 SDIT', 'Bendahara', 'Guru', 'PTY', '2025-07-01', '', '', 'uploads/WINDA_ARJUNA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(927, 'Andi Bay, S.Pd.I., Gr.', '28081986072013004', '', '28081986072013004', 'Laki-laki', '', NULL, '', '6287791867810', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(928, 'Asma Djaling, S.Pd.I., Gr.', '1105198207202215016', '', '1105198207202215016', 'Laki-laki', '', NULL, '', '6282291565622', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', '', 'Guru', '', NULL, '', '', 'uploads/ASMA_DJALING.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(929, 'Dahlima Jufri, S.Pd., Gr.', '05051995072018689', '7317084505950003', '05051995072018689', 'Perempuan', 'Minanga', '1995-05-05', 'Jln emy saelan, trans lr 2, desa puncak indah. ', '6285255405420', 'jufridahlima005@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', 'Guru', 'Guru', 'PTY', '2018-07-31', 'Aktif', 'Sudah', 'uploads/DAHLIMA_JUFRI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(930, 'Gustiana R, S.Pd., M.Pd., Gr.', '1508198506201302008', '7324045508850001', '1508198506201302008', 'Perempuan', 'Labokong-Soppeng', '1985-08-15', 'Jl. Syuhada RT 001, Dusun Puncak Indah, Desa Puncak Indah, Kec.Malili, Kab. Luwu Timur ', '6285319589132', 'gustiana.r0885@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', 'Guru', 'Guru', 'PTY', '2013-06-03', 'Aktif', 'Aktif', 'uploads/GUSTIANA_R.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(931, 'Hikmawati, S.Pd., Gr.', '2810199407201915010', '7324046810940001', '2810199407201915010', 'Perempuan', 'Malili', '1994-10-28', 'Lorong 2 Jl. Poros PPI Dusun Salabu Desa Wewangriu Kec. Malili Kab. Luwu Timur ', '6285240804944', 'hikmawati2894@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', 'Guru', 'Guru', 'PTY', '2019-08-19', 'Aktif', 'Sudah Selesai', 'uploads/HIKMAWATI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(932, 'Irfan, S.Pd', '2808198607201915004', '', '2808198607201915004', 'Laki-laki', '', NULL, '', '6282292247131', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(933, 'Isruddin', '0902199207201915006', '', '0902199207201915006', 'Laki-laki', '', NULL, '', '6282358866872', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(934, 'La Ode Pola Kota, S.Pd.I., Gr.', '1506197807202315015', '', '1506197807202315015', 'Laki-laki', '', NULL, '', '6281242553959', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(935, 'Muh. Nurdiansyah', '1407199510202315017', '', '1407199510202315017', 'Laki-laki', '', NULL, '', '6281333790046', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(936, 'Nursakia, S.H.', '', '7324116606020002', '7324116606020002', 'Perempuan', 'Luwu', '2002-06-26', 'Desa Laro, Kec. Burau, Kab. Luwu Timur ', '6285395662222', 'nursakiaajang@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', 'Guru', 'Guru', 'PKY', '2025-09-08', '', '', 'uploads/NURSAKIA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(937, 'Rahmat Saputra, S.H, M.Pd., Gr.', '2610199607201915001', '7324092610960001', '2610199607201915001', 'Laki-laki', 'Sumber Agung', '1996-10-26', 'Jln.Syuhada\nDesa : Puncak Indah\nKec. Malili\nKab. Luwu Timur', '6282347594756', 'rahmatsaputra51@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', 'Kepala Sekolah', 'Guru', 'PTY', '2019-07-01', 'Aktif', 'Aktif ', 'uploads/RAHMAT_SAPUTRA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(938, 'Samsul Bahri, S.Pd., Gr.', '16081994072018688', '7313071608940002', '16081994072018688', 'Laki-laki', 'Luwu', '1994-08-16', 'Jl Emy saelan, trans lr 2. Desa puncak indah', '6282393282166', 'ancyubahri@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI01', '03 SMPIT', 'Guru', 'Guru', 'PTY', '2018-07-15', 'Aktif', 'Sudah', 'uploads/SAMSUL_BAHRI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(939, 'Andreawan, S.Pd.', '', '7324092808990002', '7324092808990002', 'Laki-laki', 'Kalaena Kiri ', '1999-08-28', 'Dusun Tanjung Sari, Desa Mekar Sari, Kec. Kalaena, Kabupaten Luwu Timur ', '6285246018294', 'andreawwan28@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI02', '03 SMPIT ', 'Walikelas', 'Guru', 'Honor', '2025-10-06', 'Aktif', 'Aktif mengajar hingga saat ini', 'uploads/ANDREAWAN.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(940, 'Basman, S.Pd.I., Gr.', '2107199402201904012', '7324080110940001', '2107199402201904012', 'Laki-laki', 'Soppeng', '1993-10-01', 'Kel. Tomoni, Kec. Tomoni, Kab. Lueu Timur\n', '6285240062532', 'basman10@guru.sd.belajar.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI02', '03 SMPIT', 'Kepala Sekolah', 'Guru', 'PTY', '2019-07-08', 'Aktif', 'Aktif mengajar hingga saat ini. ', 'uploads/BASMAN.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(941, 'Salahuddin Alayubi, S.Pd.', '', '7324101005000001', '7324101005000001', 'Laki-laki', 'Kalaena', '2000-10-05', 'dusun jati sari, desa kalaena kiri, kecamatan kalaena, kabupaten luwu timur', '6282261094769', 'muhayub32@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMPITWI02', '03 SMPIT', 'Guru', 'Guru', 'Honor', '2026-12-01', '', '', 'uploads/SALAHUDDIN_ALAYUBI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(942, 'Amira Khairiyah, S.H.', '', '', '', 'Laki-laki', '', NULL, '', '6287798421435', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(943, 'Bella Angriani, S.Pd., Gr.', '', '7324066301950001', '7324066301950001', 'Perempuan', 'Wotu', '1995-01-23', 'Jalan Rante Mario, Desa Kalpataru, Kecamatan Tomoni', '628282291607767', 'bella.angriani15@guru.sma.belajar.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', 'Walikelas', 'Guru', 'PTY', '2023-01-09', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(944, 'Gr.Rahmadani, S.Pd.', '', '', '', 'Laki-laki', '', '1988-03-14', '', '628285241589800', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', '2014-07-01', '', '', 'uploads/GR.RAHMADANI,_S.PD..jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(945, 'Hardianti, S.Si.', '', '', '', 'Laki-laki', '', NULL, '', '6282251771595', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(946, 'Husnul Khotimah, S.Pd., Gr.', '', '', '', 'Laki-laki', '', '1997-09-16', '', '628282261154776', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', '2022-10-01', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(947, 'Junaid Kadir, S.Pd., M.Pd.,Gr.', '', '', '', 'Laki-laki', '', NULL, '', '628282317768824', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(948, 'Nurjaya Syamsualam, S.Si., Gr.', '', '', '', 'Laki-laki', '', NULL, '', '628282291115056', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(949, 'Nurmianti, S.Pd., M.Pd.,Gr.', '', '', '', 'Laki-laki', '', NULL, '', '628282333825794', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', NULL, '', '', 'uploads/NURMIANTI.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(950, 'Peni Zulayka, S.P., Gr.', '', '', '', 'Laki-laki', '', NULL, '', '6282319736352', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'SMAITWI01', '04 SMAIT', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(951, 'Aminasari', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PONDOKWI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(952, 'IRWAN JAYA', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PONDOKWI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(953, 'Muhammad Idham', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PONDOKWI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(954, 'Syamsuddin', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PONDOKWI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(955, 'Akhmad Al Islamy, S.Pd.I.,M.Pd', '', '', '', 'Laki-laki', '', NULL, '', '6281244681451', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(956, 'Umar S.Pd.I., S.H.,M.Pd', '2907199001201806001', '7324022907900001', '2907199001201806001', 'Laki-laki', 'Ujung pandang', NULL, 'Jl. Ahmad Razak lorong 5 Trans puncak indah ', '6285242952790', 'umarbinbatri@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', 'Kepala Sekolah', 'Guru', 'PTY', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(957, 'Risman M', '2107198401201906004', '', '2107198401201906004', 'Laki-laki', '', NULL, '', '6285399782196', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(958, 'Hasanuddin, S.Pd. I', '0505198306201607001', '', '0505198306201607001', 'Laki-laki', '', NULL, '', '6281355634705', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(959, 'Herman', '0407199505202406021', '', '0407199505202406021', 'Laki-laki', '', NULL, '', '6285399180578', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(960, 'Nur Jamila, S.Kom., M.Kom', '', '', '', 'Laki-laki', '', NULL, '', '6285242236363', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(961, 'Nur Maidah Kurohman, S.H', '1809200001202106017', '7324045809000001', '1809200001202106017', 'Perempuan', 'Malili', '2000-09-18', 'Jln. Jenral Ahmad Yani Lorong 3 Puncak Indah ', '6282271473958', 'bossmaaideyy@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', 'Guru', 'Guru', 'PTY', '2021-10-01', '', '', 'uploads/NUR_MAIDAH_KUROHMAN.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(962, 'Fitriani Hornai, S.S', '12101994010202306015', '', '12101994010202306015', 'Laki-laki', 'Ossu', '1990-04-27', 'Jl. Ki Hajar dewantara trans lr. 8 puncak indah kec. Malili kab. Luwu Timur', '6285256445653', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', '2013-07-07', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(963, 'Nur Ilma S.H', '0711199901202306015', '', '0711199901202306015', 'Laki-laki', '', NULL, '', '6287731293768', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(964, 'Wahyuni Syam Nur Hornai, S.H', '1611200109202406019', '', '1611200109202406019', 'Laki-laki', '', NULL, '', '6281242573008', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(965, 'Ismi Basira S.H', '2107200109202406020', '', '2107200109202406020', 'Laki-laki', '', NULL, '', '6281774157915', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(966, 'Idha Kuratun Ayuni Hornai, Amd. Kep', '2505200011202406025', '', '2505200011202406025', 'Laki-laki', '', NULL, '', '6281243390402', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(967, 'Irma Muh. Seni S.Pd', '1303199301202506026', '', '1303199301202506026', 'Laki-laki', '', NULL, '', '6285340515461', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(968, 'Marhuni S.Pd.I', '1509198201202506027', '', '1509198201202506027', 'Laki-laki', '', NULL, '', '6282148384265', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(969, 'Nur Halisa', '', '', '', 'Laki-laki', '', NULL, '', '6282193788960', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQMALILI', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(970, 'Adifarham Mahada S.H, M.Pd.', '1804199406202201022', '7316031804940001', '1804199406202201022', 'Laki-laki', 'Bone-Bone ', '1994-04-18', 'Sumber Alam, Tomoni', '6285242510615', 'adifarhan180494@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Ketua', 'Guru', 'PTY', '2022-09-12', 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(971, 'Firman S.H', '', '', '', 'Laki-laki', 'Mandiri', '2001-01-31', '', '6282271568749', 'firmanfaudhi31@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Guru', 'Guru', 'PTY', '2023-09-01', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(972, 'H. Amung', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', '', 'Guru', 'Honor', NULL, 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(973, 'H. Muh. Ikbal', '', '7371141004840010', '7371141004840010', 'Laki-laki', 'Aceh', '1984-04-10', 'Ponpes Tahfidzul Qur\"an Salman Al Farisi Sumber Alam Tomoni', '6282217707156', 'ikbal.biruenaceh84@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Guru', 'Guru', '', '2018-04-20', '', '', 'uploads/MUH_IKBAL.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(974, 'Irfan Sahabu', '', '7324080903990002', '7324080903990002', 'Laki-laki', 'Dsn. Kaya\'a', '1999-03-09', 'Dsn. Kaya\'a, Desa. Beringin jaya, Kab. Luwu Timur, Prov. Sulawesi Selatan ', '6285215064547', 'irfansahabu02@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Guru', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(975, 'Medis, S.H', '', '', '', 'Laki-laki', '', NULL, '', '6282316414720', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(976, 'Munawir, S.Pd', '', '', '', 'Laki-laki', '', NULL, '', '6281243700632', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(977, 'Muzakkir Hasan', '', '', '', 'Laki-laki', 'Meuraksa', '1979-08-10', '', '6282334728532', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(978, 'Rahman', '', '7324012805910001', '7324012805910001', 'Laki-laki', 'Kalaena kanan', '1991-05-27', 'Ds. Sumber alam. Kec tomoni. Luwu timur', '6282373234678', 'rahmanrauff958@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Security', 'Guru', 'PTY', '2022-04-11', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(979, 'Rahmat, S.Pd.,I', '', '7302051505900001', '7302051505900001', 'Laki-laki', 'BORONG ', '1990-05-15', 'DSN. Sendang Sari 1, Wonorejo, Mangkutana, Luwu Timur, Sulawesi Selatan ', '6282271639889', 'aburahmat12@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Guru', 'Guru', 'PTY', '2017-01-01', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(980, 'Riswan', '', '', '', 'Laki-laki', '', NULL, '', '6285147386456', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(981, 'Sainal, A.Md', '', '7324041001810002', '7324041001810002', 'Laki-laki', 'Enrekang ', '1981-01-10', 'Jln Kebun rami 1, Desa Mandiri, Kecamatan Tomoni, kabupaten Luwu Timur ', '6285398070188', 'abuzainal507@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Bendahara', 'Guru', 'PTY', '2012-01-10', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(982, 'Shiddik', '', '', '', 'Laki-laki', 'Tomoni', '1997-10-05', 'LING.KUWARASAN 1\nKelurahan tomoni. Kec.tomoni. Kab.luwu timur', '6285343663599', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Guru', 'Guru', 'PTY', '2023-07-11', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(983, 'Ummu Fadlan', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(984, 'Ummu Ulfa', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(985, 'Wahyunis, Sh', '', '', '', 'Laki-laki', 'Wotu', '1993-03-13', 'Sumber Alam, kec. Tomoni', '6281296527812', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSAF', '05 PONDOK', 'Guru', 'Guru', 'PTY', '2020-07-01', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(986, 'Budirman', '1409200000000000000', '', '1409200000000000000', 'Laki-laki', 'Soppeng', '1977-09-14', 'Jl G Merapi F. 124', '6285342583031', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSOROWAKO', '05 PONDOK', 'Ketua', 'Guru', 'Honor', '2025-02-20', '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(987, 'Hamria', '1205197810202310004', '', '1205197810202310004', 'Laki-laki', '', NULL, '', '6281527945432', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSOROWAKO', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(988, 'Irdawaty Daming', '905198310202310003', '', '905198310202310003', 'Laki-laki', '', NULL, '', '6282189588826', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSOROWAKO', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(989, 'Rahmawati', '0810198501202510006', '', '0810198501202510006', 'Laki-laki', '', NULL, '', '6282291865819', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSOROWAKO', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(990, 'Sitti Mawaddah', '0609199910202510007', '', '0609199910202510007', 'Laki-laki', '', NULL, '', '6281248835998', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSOROWAKO', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(991, 'Ummul Khair', '0106198306201810001', '', '0106198306201810001', 'Laki-laki', '', NULL, '', '6285255385559', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'PPTQSOROWAKO', '05 PONDOK', '', 'Guru', '', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(992, 'Akbar Irwansya', '2201199901202502064', '7324090101990001', '2201199901202502064', 'Laki-laki', 'Kalaena', '1999-01-22', 'Malili', '6282396859771', 'akbarirwansyahtkj@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'YPWILUTIM', '06 YPWI', 'Admin', 'Guru', 'PKY', '2024-01-08', 'Aktif', '-', 'uploads/FOTO_AKBAR_IRWANSYA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(993, 'Anwar, S.Ag.', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'YPWILUTIM', '06 YPWI', '', 'Guru', 'GTY/PTY', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(994, 'Budiman, S.Hut,. M.M.', '', '', '', 'Laki-laki', '', NULL, '', '', '', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'YPWILUTIM', '06 YPWI', 'Sekretaris', 'Guru', 'GTY/PTY', NULL, '', '', NULL, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(995, 'Muh. Fadli', '0710200205202400006', '7317210710020001', '0710200205202400006', NULL, 'Sompu-sompu', '2002-10-06', 'Dusun Sompu-Sompu, Desa Tarramatekkeng, Kec. Ponrang Selatan, Kab. Luwu', '6285290359293', 'f70050119@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'YPWILUTIM', '06 YPWI', 'Bendahara', NULL, 'PTY', NULL, NULL, 'Masih bujang', 'uploads/FOTO_MUH_FADLI.png', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(996, 'Muhammad Sultan Nur Kara, S.E.,Gr', '20081990062020005', '7324042008900001', '20081990062020005', 'Laki-laki', 'Pangkep', '1990-08-20', 'Perumahan Atap Hijau Sawita, Blok 3 No.6', '6285396556673', 'muh.sultan.nur289@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'YPWILUTIM', '06 YPWI', 'Operator', 'Guru', 'PTY', '2020-06-01', 'Aktif', '', 'uploads/MUHAMMAD_SULTAN_NUR_KARA.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL),
(997, 'Usman, S.Pd.I.,Gr', '3112198706201402006', '7324043112870004', '3112198706201402006', 'Laki-laki', 'Tamatto', '1987-12-31', 'Perumahan Sawitta Blok K2 No.5 \nTrans  Desa puncak indah Kec. Malili Luwu Timu', '6285340631022', 'abunabil352@gmail.com', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'YPWILUTIM', '06 YPWI', 'Ketua', 'Guru', '', '2026-02-01', 'Aktif', '', 'uploads/USMAN.jpg', 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `teacher_assignments`
--

CREATE TABLE `teacher_assignments` (
  `id` int(11) NOT NULL,
  `teacher_id` int(11) DEFAULT NULL,
  `tenant_id` varchar(50) DEFAULT NULL,
  `asal_sekolah` varchar(255) DEFAULT NULL,
  `jenjang` varchar(50) DEFAULT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `sebagai` varchar(100) DEFAULT NULL,
  `status_kepegawaian` varchar(100) DEFAULT NULL,
  `tmt` date DEFAULT NULL,
  `status_aktif` enum('Aktif','Tidak Aktif') DEFAULT 'Aktif',
  `gaji_pokok` decimal(15,2) DEFAULT NULL,
  `tunj_kinerja` decimal(15,2) DEFAULT NULL,
  `tunj_umum` decimal(15,2) DEFAULT NULL,
  `tunj_istri` decimal(15,2) DEFAULT NULL,
  `tunj_anak` decimal(15,2) DEFAULT NULL,
  `tunj_kepala_sekolah` decimal(15,2) DEFAULT NULL,
  `tunj_wali_kelas` decimal(15,2) DEFAULT NULL,
  `honor_bendahara` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `teacher_assignments`
--

INSERT INTO `teacher_assignments` (`id`, `teacher_id`, `tenant_id`, `asal_sekolah`, `jenjang`, `jabatan`, `sebagai`, `status_kepegawaian`, `tmt`, `status_aktif`, `gaji_pokok`, `tunj_kinerja`, `tunj_umum`, `tunj_istri`, `tunj_anak`, `tunj_kepala_sekolah`, `tunj_wali_kelas`, `honor_bendahara`) VALUES
(767, 768, 'TKITWI01', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(768, 769, 'TKITWI01', '01 TKIT', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(769, 770, 'TKITWI01', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(770, 771, 'TKITWI01', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(771, 772, 'TKITWI01', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(772, 773, 'TKITWI01', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(773, 774, 'TKITWI01', '01 TKIT', '01 TKIT', '', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(774, 775, 'TKITWI02', '01 TKIT', '01 TKIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(775, 776, 'TKITWI02', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(776, 777, 'TKITWI02', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(777, 778, 'TKITWI02', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(778, 779, 'TKITWI02', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(779, 780, 'TKITWI02', '01 TKIT', '01 TKIT', 'Walikelas', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(780, 781, 'TKITWI02', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(781, 782, 'TKITWI02', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(782, 783, 'TKITWI03', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(783, 784, 'TKITWI03', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(784, 785, 'TKITWI03', '01 TKIT', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(785, 786, 'TKITWI04', '01 TKIT', '01 TKIT', 'Operator', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(786, 787, 'TKITWI04', '01 TKIT', '01 TKIT', 'Kepala Sekolah', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(787, 788, 'TKITWI04', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(788, 789, 'TKITWI05', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(789, 790, 'TKITWI05', '05 TK IT', '05 TK IT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(790, 791, 'TKITWI06', '01 TKIT', '01 TKIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(791, 792, 'TKITWI06', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(792, 793, 'TKITWI06', '01 TKIT', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(793, 794, 'TKITWI06', '01 TKIT', '01 TKIT', 'Bendahara', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(794, 795, 'TKITWI07', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(795, 796, 'TKITWI07', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(796, 797, 'TKITWI07', '01 TKIT', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(797, 798, 'TKITWI07', '01 TKIT', '01 TKIT', 'Guru', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(798, 799, 'TKITWI08', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(799, 800, 'TKITRABBANI', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(800, 801, 'TKITRABBANI', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(801, 802, 'TKITRABBANI', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(802, 803, 'TKITRABBANI', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(803, 804, 'TKITRABBANI', '01 TKIT', '01 TKIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(804, 805, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(805, 806, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(806, 807, 'SDITIRA', '02 SDIT', '02 SDIT', 'TU', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(807, 808, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(808, 809, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(809, 810, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(810, 811, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(811, 812, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(812, 813, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(813, 814, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(814, 815, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(815, 816, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(816, 817, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(817, 818, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(818, 819, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(819, 820, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(820, 821, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(821, 822, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(822, 823, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(823, 824, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(824, 825, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(825, 826, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(826, 827, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(827, 828, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(828, 829, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(829, 830, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(830, 831, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(831, 832, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(832, 833, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(833, 834, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(834, 835, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(835, 836, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(836, 837, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(837, 838, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(838, 839, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(839, 840, 'SDITIRA', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(840, 841, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(841, 842, 'SDITIRA', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(842, 843, 'SDITIRA', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(843, 844, 'SDITWI03', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(844, 845, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(845, 846, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(846, 847, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(847, 848, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(848, 849, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(849, 850, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(850, 851, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(851, 852, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(852, 853, 'SDITWI03', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(853, 854, 'SDITWI03', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(854, 855, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(855, 856, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(856, 857, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(857, 858, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(858, 859, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(859, 860, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(860, 861, 'SDITWI03', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(861, 862, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(862, 863, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(863, 864, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(864, 865, 'SDITWI03', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(865, 866, 'SDITWI02', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(866, 867, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(867, 868, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(868, 869, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(869, 870, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(870, 871, 'SDITWI02', 'SD', 'SD', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(871, 872, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(872, 873, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(873, 874, 'SDITWI02', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(874, 875, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(875, 876, 'SDITWI02', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(876, 877, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(877, 878, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(878, 879, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(879, 880, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(880, 881, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(881, 882, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PKY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(882, 883, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(883, 884, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(884, 885, 'SDITWI02', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(885, 886, 'SDITWI02', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(886, 887, 'SDITWI02', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(887, 888, 'SDITWI02', '02 SDIT', '02 SDIT', 'TU', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(888, 889, 'SDITWI04', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(889, 890, 'SDITWI04', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(890, 891, 'SDITWI04', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(891, 892, 'SDITWI04', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(892, 893, 'SDITWI04', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(893, 894, 'SDITWI04', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(894, 895, 'SDITWI04', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(895, 896, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(896, 897, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(897, 898, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(898, 899, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(899, 900, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(900, 901, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(901, 902, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(902, 903, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(903, 904, 'SDITWI05', '02 SDIT', '02 SDIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(904, 905, 'SDITWI06', 'SDIT', 'SDIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(905, 906, 'SDITWI06', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(906, 907, 'SDITWI06', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(907, 908, 'SDITWI06', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(908, 909, 'SDITWI06', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(909, 910, 'SDITWI06', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(910, 911, 'SDITWI06', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(911, 912, 'YPWILUTIM', '', '', '', '', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(912, 913, 'SDITWI07', '02 SDIT', '02 SDIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(913, 914, 'SDITWI07', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(914, 915, 'SDITWI07', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(915, 916, 'SDITWI07', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(916, 917, 'SDITWI07', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(917, 918, 'SDITWI08', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PKY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(918, 919, 'SDITWI08', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(919, 920, 'SDITWI08', '08 SDIT', '08 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(920, 921, 'SDITWI08', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(921, 922, 'SDITWI08', '02 SDIT', '02 SDIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(922, 923, 'SDITWI08', '02 SDIT', '02 SDIT', 'Guru', 'Guru', 'PKY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(923, 924, 'SDITWI08', '02 SDIT', '02 SDIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(924, 925, 'SDITWI09', '02 SDIT', '02 SDIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(925, 926, 'SDITWI09', '02 SDIT', '02 SDIT', 'Bendahara', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(926, 927, 'SMPITWI01', '03 SMPIT', '03 SMPIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(927, 928, 'SMPITWI01', '03 SMPIT', '03 SMPIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(928, 929, 'SMPITWI01', '03 SMPIT', '03 SMPIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(929, 930, 'SMPITWI01', '03 SMPIT', '03 SMPIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(930, 931, 'SMPITWI01', '03 SMPIT', '03 SMPIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(931, 932, 'SMPITWI01', '03 SMPIT', '03 SMPIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(932, 933, 'SMPITWI01', '03 SMPIT', '03 SMPIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(933, 934, 'SMPITWI01', '03 SMPIT', '03 SMPIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(934, 935, 'SMPITWI01', '03 SMPIT', '03 SMPIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(935, 936, 'SMPITWI01', '03 SMPIT', '03 SMPIT', 'Guru', 'Guru', 'PKY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(936, 937, 'SMPITWI01', '03 SMPIT', '03 SMPIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(937, 938, 'SMPITWI01', '03 SMPIT', '03 SMPIT', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(938, 939, 'SMPITWI02', '03 SMPIT ', '03 SMPIT ', 'Walikelas', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(939, 940, 'SMPITWI02', '03 SMPIT', '03 SMPIT', 'Kepala Sekolah', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(940, 941, 'SMPITWI02', '03 SMPIT', '03 SMPIT', 'Guru', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(941, 942, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(942, 943, 'SMAITWI01', '04 SMAIT', '04 SMAIT', 'Walikelas', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(943, 944, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(944, 945, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(945, 946, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(946, 947, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(947, 948, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(948, 949, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(949, 950, 'SMAITWI01', '04 SMAIT', '04 SMAIT', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(950, 951, 'PONDOKWI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(951, 952, 'PONDOKWI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(952, 953, 'PONDOKWI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(953, 954, 'PONDOKWI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(954, 955, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(955, 956, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', 'Kepala Sekolah', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(956, 957, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(957, 958, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(958, 959, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(959, 960, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(960, 961, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(961, 962, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(962, 963, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(963, 964, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(964, 965, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(965, 966, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(966, 967, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(967, 968, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(968, 969, 'PPTQMALILI', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(969, 970, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Ketua', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(970, 971, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(971, 972, 'PPTQSAF', '05 PONDOK', '05 PONDOK', '', 'Guru', 'Honor', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(972, 973, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(973, 974, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(974, 975, 'PPTQSAF', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(975, 976, 'PPTQSAF', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(976, 977, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(977, 978, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Security', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(978, 979, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(979, 980, 'PPTQSAF', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(980, 981, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Bendahara', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(981, 982, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(982, 983, 'PPTQSAF', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(983, 984, 'PPTQSAF', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(984, 985, 'PPTQSAF', '05 PONDOK', '05 PONDOK', 'Guru', 'Guru', 'PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(985, 986, 'PPTQSOROWAKO', '05 PONDOK', '05 PONDOK', 'Ketua', 'Guru', 'Honor', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(986, 987, 'PPTQSOROWAKO', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(987, 988, 'PPTQSOROWAKO', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(988, 989, 'PPTQSOROWAKO', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(989, 990, 'PPTQSOROWAKO', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(990, 991, 'PPTQSOROWAKO', '05 PONDOK', '05 PONDOK', '', 'Guru', '', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(991, 992, 'YPWILUTIM', '06 YPWI', '06 YPWI', 'Admin', 'Guru', 'PKY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(992, 993, 'YPWILUTIM', '06 YPWI', '06 YPWI', '', 'Guru', 'GTY/PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(993, 994, 'YPWILUTIM', '06 YPWI', '06 YPWI', 'Sekretaris', 'Guru', 'GTY/PTY', NULL, '', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(994, 995, 'YPWILUTIM', '06 YPWI', '06 YPWI', 'Bendahara', 'Guru', 'GTY/PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(995, 996, 'YPWILUTIM', '06 YPWI', '06 YPWI', 'Operator', 'Guru', 'PTY', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(996, 997, 'YPWILUTIM', '06 YPWI', '06 YPWI', 'Ketua', 'Guru', '', NULL, 'Aktif', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `tenants`
--

CREATE TABLE `tenants` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tenants`
--

INSERT INTO `tenants` (`id`, `name`, `code`) VALUES
(101, 'TKIT WAHDAH ISLAMIYAH 01 TOMONI', 'TKITWI01'),
(102, 'TKIT WAHDAH ISLAMIYAH 02 MALILI', 'TKITWI02'),
(103, 'TKIT WAHDAH ISLAMIYAH 03 WASUPONDA', 'TKITWI03'),
(104, 'TKIT WAHDAH ISLAMIYAH 04 KALAENA', 'TKITWI04'),
(105, 'TKIT WAHDAH ISLAMIYAH 05 BURAU', 'TKITWI05'),
(106, 'TKIT WAHDAH ISLAMIYAH 06 WOTU', 'TKITWI06'),
(107, 'TKIT WAHDAH ISLAMIYAH 07 MANGKUTANA', 'TKITWI07'),
(108, 'TKIT WAHDAH ISLAMIYAH 08 TOWUTI', 'TKITWI08'),
(109, 'TKIT RABBANI SOROWAKO', 'TKITRABBANI'),
(110, 'SDIT INSAN RABBANI', 'SDITIRA'),
(111, 'SDIT QURANI WAHDAH ISLAMIYAH 03 SOROWAKO', 'SDITWI03'),
(112, 'SDIT WAHDAH ISLAMIYAH 02 TOMONI', 'SDITWI02'),
(113, 'SDIT WAHDAH ISLAMIYAH 04 BURAU', 'SDITWI04'),
(114, 'SDIT WAHDAH ISLAMIYAH 05 KALAENA', 'SDITWI05'),
(115, 'SDIT WAHDAH ISLAMIYAH 06 WASUPONDA', 'SDITWI06'),
(116, 'SDIT WAHDAH ISLAMIYAH 07 WOTU', 'SDITWI07'),
(117, 'SDIT WAHDAH ISLAMIYAH 08 TOWUTI', 'SDITWI08'),
(118, 'SDIT WAHDAH ISLAMIYAH 09 MANGKUTANA', 'SDITWI09'),
(119, 'SMPIT WAHDAH ISLAMIYAH 01 MALILI', 'SMPITWI01'),
(120, 'SMPIT WAHDAH ISLAMIYAH 02 KALAENA', 'SMPITWI02'),
(121, 'SMAIT WAHDAH ISLAMIYAH 01 TOMONI', 'SMAITWI01'),
(122, 'PONDOK PESANTREN INFORMATIKA DAN BAHASA WAHDAH ISLAMIYAH', 'PONDOKWI'),
(123, 'PPTQ Malili', 'PPTQMALILI'),
(124, 'PPTQ SALMAN ALFARISI PUTRA', 'PPTQSAF'),
(125, 'PPTQ Sorowako', 'PPTQSOROWAKO'),
(126, 'YPWI LUTIM', 'YPWILUTIM');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('Admin Yayasan','Admin Sekolah','Bendahara Yayasan','Bendahara Sekolah','Guru','Siswa') NOT NULL,
  `tenant_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `role`, `tenant_id`) VALUES
(1, 'adminyayasan', 'b0/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Admin Yayasan', NULL),
(2, 'adsekolah', 'b0/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Admin Sekolah', NULL),
(3, 'bendyayasan', 'b0/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Bendahara Yayasan', NULL),
(4, 'bendsekolah', 'b0/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Bendahara Sekolah', NULL),
(5, 'gurutest', 'b0/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Guru', NULL),
(6, 'siswatest', 'b0/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Siswa', NULL),
(7, 'admin_yayasan', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Admin Yayasan', 'YPWILUTIM'),
(8, 'bendahara_yayasan', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'Bendahara Yayasan', 'YPWILUTIM');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `attendance_devices`
--
ALTER TABLE `attendance_devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `device_id` (`device_id`);

--
-- Indeks untuk tabel `attendance_requests`
--
ALTER TABLE `attendance_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `attendance_rules`
--
ALTER TABLE `attendance_rules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tenant_type` (`tenant_id`,`type`);

--
-- Indeks untuk tabel `device_otp_requests`
--
ALTER TABLE `device_otp_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `jurnal`
--
ALTER TABLE `jurnal`
  ADD PRIMARY KEY (`id`),
  ADD KEY `teacher_id` (`teacher_id`);

--
-- Indeks untuk tabel `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tenant_id` (`tenant_id`);

--
-- Indeks untuk tabel `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `tenants`
--
ALTER TABLE `tenants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `tenant_id` (`tenant_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT untuk tabel `attendance_devices`
--
ALTER TABLE `attendance_devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `attendance_requests`
--
ALTER TABLE `attendance_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `attendance_rules`
--
ALTER TABLE `attendance_rules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `device_otp_requests`
--
ALTER TABLE `device_otp_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT untuk tabel `jurnal`
--
ALTER TABLE `jurnal`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4634;

--
-- AUTO_INCREMENT untuk tabel `teachers`
--
ALTER TABLE `teachers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=998;

--
-- AUTO_INCREMENT untuk tabel `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=997;

--
-- AUTO_INCREMENT untuk tabel `tenants`
--
ALTER TABLE `tenants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `jurnal`
--
ALTER TABLE `jurnal`
  ADD CONSTRAINT `jurnal_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`);

--
-- Ketidakleluasaan untuk tabel `news`
--
ALTER TABLE `news`
  ADD CONSTRAINT `news_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`code`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`code`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
