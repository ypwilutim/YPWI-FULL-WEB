-- =============================================
-- YPWI Luwu Timur - Database Schema v2.0
-- Multi-tenant School Management System
-- =============================================
-- Created: 2026-04-27
-- Purpose: Single-table authentication + class-based student grouping
-- =============================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- --------------------------------------------------------
-- Database: ypwi_db_v2
-- --------------------------------------------------------

-- Drop existing tables (if migrating from v1)
-- WARNING: This will delete all data!
-- Uncomment if you want clean install:
-- DROP TABLE IF EXISTS attendance_requests;
-- DROP TABLE IF EXISTS attendance_rules;
-- DROP TABLE IF EXISTS attendance_devices;
-- DROP TABLE IF EXISTS attendance;
-- DROP TABLE IF EXISTS device_otp_requests;
-- DROP TABLE IF EXISTS jurnal;
-- DROP TABLE IF EXISTS news;
-- DROP TABLE IF EXISTS students;
-- DROP TABLE IF EXISTS teachers;
-- DROP TABLE IF EXISTS classes;
-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS tenants;

-- =============================================
-- 1. TENANTS TABLE (Schools/Units)
-- =============================================

CREATE TABLE `tenants` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) UNIQUE NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `type` ENUM('pusat','sekolah') DEFAULT 'sekolah',
    `address` TEXT,
    `city` VARCHAR(100),
    `province` VARCHAR(100),
    `phone` VARCHAR(20),
    `email` VARCHAR(255),
    `logo_path` VARCHAR(500),
    `principal_id` INT NULL, -- FK to users (Kepala Sekolah)
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_tenant_code (code),
    INDEX idx_tenant_type (type),
    INDEX idx_tenant_active (is_active),
    CONSTRAINT fk_tenants_principal FOREIGN KEY (principal_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 2. USERS TABLE (Central Authentication)
-- =============================================

CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL, -- bcrypt hash
    `role` ENUM('admin','bendahara','ketua','guru','siswa') NOT NULL,
    `tenant_id` VARCHAR(50) NOT NULL,
    `status` ENUM('Aktif','Tidak Aktif') DEFAULT 'Aktif',
    `last_login_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_email (email),
    INDEX idx_tenant_role (tenant_id, role),
    INDEX idx_status (status),
    INDEX idx_last_login (last_login_at),
    CONSTRAINT fk_users_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 3. CLASSES TABLE (Kelas per Sekolah)
-- =============================================

CREATE TABLE `classes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `tenant_id` VARCHAR(50) NOT NULL,
    `kode_kelas` VARCHAR(50) NOT NULL,
    `nama_kelas` VARCHAR(100) NOT NULL,
    `jenjang` VARCHAR(50) NOT NULL, -- TK, SD, SMP, SMA, PPTQ
    `kurikulum` VARCHAR(100) DEFAULT 'K13',
    `wali_kelas_id` INT NULL, -- FK to teachers.id
    `kapasitas_max` INT DEFAULT 40,
    `academic_year` VARCHAR(20) DEFAULT '2024/2025',
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_class_per_tenant (`tenant_id`, `kode_kelas`, `academic_year`),
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE CASCADE,
    FOREIGN KEY (wali_kelas_id) REFERENCES teachers(id) ON DELETE SET NULL,
    INDEX idx_class_tenant (tenant_id),
    INDEX idx_class_jenjang (jenjang),
    INDEX idx_class_wali (wali_kelas_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 4. TEACHERS TABLE (Guru Profile)
-- =============================================

CREATE TABLE `teachers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNIQUE NOT NULL,
    `nip` VARCHAR(50) UNIQUE,
    `nik` VARCHAR(20) UNIQUE,
    `scan_id` VARCHAR(50) UNIQUE, -- untuk QR absensi
    `nama` VARCHAR(255) NOT NULL,
    `jenis_kelamin` ENUM('Laki-laki','Perempuan'),
    `tempat_lahir` VARCHAR(100),
    `tanggal_lahir` DATE,
    `alamat` TEXT,
    `no_wa` VARCHAR(20),
    `email_alternatif` VARCHAR(255),
    `jenjang` VARCHAR(50), -- TKIT, SDIT, SMPIT, etc.
    `jabatan` VARCHAR(100), -- Guru Kelas, Guru Mapel, Kepala Sekolah, dll
    `sebagai` VARCHAR(100), -- Wali Kelas, dll
    `status_kepegawaian` ENUM('PTY','PEGAWAI TETAP','HONOR','PKL','LAINNYA'),
    `tmt` DATE, -- Tanggal Masuk Tenaga
    `foto_path` VARCHAR(500),
    
    -- JSON untuk akses multi-unit
    `accessible_units` JSON DEFAULT NULL, -- ["tkmalili","sdtomoni"]
    `jabatan_tambahan` JSON DEFAULT NULL, -- ["Wakil Ketua", "Koordinator"]
    
    -- Salary components
    `gaji_pokok` DECIMAL(15,2) DEFAULT 0,
    `tunj_kinerja` DECIMAL(15,2) DEFAULT 0,
    `tunj_umum` DECIMAL(15,2) DEFAULT 0,
    `tunj_istri` DECIMAL(15,2) DEFAULT 0,
    `tunj_anak` DECIMAL(15,2) DEFAULT 0,
    `tunj_kepala_sekolah` DECIMAL(15,2) DEFAULT 0,
    `tunj_wali_kelas` DECIMAL(15,2) DEFAULT 0,
    `honor_bendahara` DECIMAL(15,2) DEFAULT 0,
    
    `points` INT DEFAULT 0,
    `keterangan` TEXT,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_teacher_tenant (tenant_id),
    INDEX idx_teacher_scan (scan_id),
    INDEX idx_teacher_nip (nip),
    INDEX idx_teacher_nik (nik),
    INDEX idx_teacher_nama (nama)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 5. STUDENTS TABLE (Siswa Profile)
-- =============================================

CREATE TABLE `students` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNIQUE NOT NULL,
    `nisn` VARCHAR(20) UNIQUE,
    `scan_id` VARCHAR(50) UNIQUE, -- untuk QR absensi
    `nama_siswa` VARCHAR(255) NOT NULL,
    `kelas_id` INT NOT NULL,
    `jenis_kelamin` ENUM('Laki-laki','Perempuan'),
    `tempat_lahir` VARCHAR(100),
    `tanggal_lahir` DATE,
    `alamat` TEXT,
    `no_wa` VARCHAR(20),
    `email_alternatif` VARCHAR(255),
    `nama_orang_tua` VARCHAR(255),
    `no_wa_orang_tua` VARCHAR(20),
    `iuran_bulanan` DECIMAL(10,2) DEFAULT 0,
    `foto_path` VARCHAR(500),
    `keterangan` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (kelas_id) REFERENCES classes(id) ON DELETE SET NULL,
    INDEX idx_student_tenant (tenant_id),
    INDEX idx_student_scan (scan_id),
    INDEX idx_student_nisn (nisn),
    INDEX idx_student_kelas (kelas_id),
    INDEX idx_student_nama (nama_siswa),
    CONSTRAINT fk_students_kelas FOREIGN KEY (kelas_id) REFERENCES classes(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 6. ATTENDANCE_DEVICES TABLE
-- =============================================

CREATE TABLE `attendance_devices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `device_id` VARCHAR(255) UNIQUE NOT NULL,
    `device_name` VARCHAR(255) NOT NULL,
    `device_location` VARCHAR(255) DEFAULT NULL,
    `phone_number` VARCHAR(20) DEFAULT NULL,
    `tenant_id` VARCHAR(50) NOT NULL,
    `created_by` INT NOT NULL, -- user_id
    `status` ENUM('pending','active','inactive') DEFAULT 'pending',
    `last_used_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_device_id (device_id),
    INDEX idx_device_tenant (tenant_id),
    INDEX idx_device_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 7. ATTENDANCE_RULES TABLE (Waktu Absensi)
-- =============================================

CREATE TABLE `attendance_rules` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `tenant_id` VARCHAR(50) NOT NULL,
    `type` ENUM('Datang','Pulang') NOT NULL,
    `waktu_mulai` TIME NOT NULL,
    `waktu_akhir` TIME NOT NULL,
    `keterangan` VARCHAR(100) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE CASCADE,
    INDEX idx_attendance_rules_tenant (tenant_id),
    INDEX idx_attendance_rules_type (type),
    UNIQUE KEY unique_rule_per_tenant (tenant_id, type, waktu_mulai, waktu_akhir)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 8. ATTENDANCE TABLE (Absensi Records)
-- =============================================

CREATE TABLE `attendance` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL, -- FK to users (if registered user)
    `scan_id` VARCHAR(50) NULL, -- untuk QR code
    `device_id` VARCHAR(255) NULL, -- FK to attendance_devices.device_id
    `tenant_id` VARCHAR(50) NOT NULL, -- asal_sekolah
    `kelas_id` INT NULL, -- FK to classes (jika siswa)
    `tanggal` DATE DEFAULT (CURDATE()),
    `jam` TIME DEFAULT (CURTIME()),
    `status` ENUM('Datang','Pulang') DEFAULT 'Datang',
    `keterangan` TEXT,
    `jenis_absen` ENUM('Absen','Izin','Sakit','Cuti') DEFAULT 'Absen',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE CASCADE,
    FOREIGN KEY (kelas_id) REFERENCES classes(id) ON DELETE SET NULL,
    INDEX idx_attendance_scan (scan_id),
    INDEX idx_attendance_user (user_id),
    INDEX idx_attendance_device (device_id),
    INDEX idx_attendance_tanggal (tanggal),
    INDEX idx_attendance_tenant (tenant_id),
    INDEX idx_attendance_kelas (kelas_id),
    INDEX idx_attendance_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 9. ATTENDANCE_REQUESTS TABLE (Pengajuan Izin/Sakit)
-- =============================================

CREATE TABLE `attendance_requests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `tenant_id` VARCHAR(50) NOT NULL,
    `jenis` ENUM('Izin','Sakit') NOT NULL,
    `alasan` TEXT NOT NULL,
    `tanggal_mulai` DATE NOT NULL,
    `tanggal_akhir` DATE NOT NULL,
    `status` ENUM('pending','approved','rejected') DEFAULT 'pending',
    `catatan` TEXT DEFAULT NULL,
    `approved_by` INT NULL, -- user_id (admin/guru)
    `approved_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_request_user (user_id),
    INDEX idx_request_tenant (tenant_id),
    INDEX idx_request_status (status),
    INDEX idx_request_dates (tanggal_mulai, tanggal_akhir)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 10. NEWS TABLE (Berita/Announcements)
-- =============================================

CREATE TABLE `news` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `tenant_id` VARCHAR(50) NULL, -- NULL = sistem-wide (YPWI central)
    `author_id` INT NOT NULL, -- user_id
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `category` VARCHAR(100) DEFAULT 'Umum',
    `image_path` VARCHAR(500),
    `is_published` BOOLEAN DEFAULT FALSE,
    `published_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_news_tenant (tenant_id),
    INDEX idx_news_author (author_id),
    INDEX idx_news_published (is_published, published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 11. JABATAN_OPTIONS (Dropdown jabatan guru)
-- =============================================

CREATE TABLE `jabatan_options` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `jabatan` VARCHAR(100) NOT NULL,
    `deskripsi` TEXT,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_jabatan (jabatan),
    INDEX idx_jabatan_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 12. SEBAGAI_OPTIONS (Dropdown sebagai guru)
-- =============================================

CREATE TABLE `sebagai_options` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `sebagai` VARCHAR(100) NOT NULL,
    `deskripsi` TEXT,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_sebagai (sebagai),
    INDEX idx_sebagai_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 13. DEVICE_OTP_REQUESTS (OTP untuk device registration)
-- =============================================

CREATE TABLE `device_otp_requests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `device_name` VARCHAR(255) NOT NULL,
    `device_location` VARCHAR(255) DEFAULT NULL,
    `tenant_code` VARCHAR(50) NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL,
    `otp` VARCHAR(6) NOT NULL,
    `expires_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `used` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_otp_tenant (tenant_code),
    INDEX idx_otp_used (used),
    INDEX idx_otp_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 14. JURNAL TABLE (Journal/Log entries)
-- =============================================

CREATE TABLE `jurnal` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `teacher_id` INT NULL, -- FK to teachers.id
    `date` DATE DEFAULT (CURDATE()),
    `materi` TEXT,
    `hadir` INT DEFAULT 0,
    `absen` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    INDEX idx_jurnal_teacher (teacher_id),
    INDEX idx_jurnal_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 15. SYSTEM_SETTINGS TABLE (Config global)
-- =============================================

CREATE TABLE `system_settings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) UNIQUE NOT NULL,
    `setting_value` TEXT,
    `description` TEXT,
    `updated_by` INT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_settings_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- SEED DATA: Jabatan Options
-- =============================================

INSERT INTO `jabatan_options` (`jabatan`, `deskripsi`) VALUES
('Guru Kelas', 'Guru yang mengajar di kelas'),
('Guru Mapel', 'Guru mata pelajaran'),
('Kepala Sekolah', 'Kepala Madrasah/Sekolah'),
('Wakil Kepala Sekolah', 'Wakil Kepala Madrasah/Sekolah'),
('Guru BK', 'Guru Bimbingan Konseling'),
('Guru Agama', 'Guru Pendidikan Agama'),
('Guru Olahraga', 'Guru Pendidikan Jasmani dan Kesenian'),
('Guru Bahasa', 'Guru Bahasa Indonesia/Asing'),
('Guru Matematika', 'Guru Matematika'),
('Guru IPA', 'Guru Ilmu Pengetahuan Alam'),
('Guru IPS', 'Guru Ilmu Pengetahuan Sosial'),
('Tata Usaha', 'Staf tata usaha'),
('Operator', 'Operator data'),
('Bendahara', 'Bendahara');

-- =============================================
-- SEED DATA: Sebagai Options
-- =============================================

INSERT INTO `sebagai_options` (`sebagai`, `deskripsi`) VALUES
('Wali Kelas', 'Guru pembimbing kelas'),
('Koordinator Tahun', 'Koordinator untuk tingkat tahun'),
('Koordinator Mapel', 'Koordinator mata pelajaran'),
('Staff Tata Usaha', 'Staf tata usaha'),
('Anggota Komite', 'Anggota komite sekolah'),
('Panitia', 'Panitia kegiatan');

-- =============================================
-- SEED DATA: System Settings
-- =============================================

INSERT INTO `system_settings` (`setting_key`, `setting_value`, `description`) VALUES
('attendance_timeout_minutes', '5', 'Device verification timeout in minutes'),
('max_login_attempts', '5', 'Maximum login attempts before lockout'),
('lockout_duration_minutes', '15', 'Lockout duration in minutes'),
('allow_student_self_register', 'false', 'Allow students to self-register'),
('default_academic_year', '2024/2025', 'Default academic year'),
('whatsapp_enabled', 'false', 'Enable WhatsApp notifications');

-- =============================================
-- SEED DATA: Sample Tenant (Central)
-- =============================================

INSERT INTO `tenants` (`code`, `name`, `type`, `address`, `city`, `province`, `phone`, `email`) VALUES
('YPWILUTIM', 'Yayasan Pesantren Wahdah Islamiyah Luwu Timur', 'pusat', 'Jl. Raya Luwu Timur', 'Luwu Timur', 'Sulawesi Selatan', '081234567890', 'info@ypw lutim.sch.id');

-- =============================================
-- SEED DATA: Sample Classes (for a specific school)
-- Contoh untuk tenant TKITWI01
-- =============================================

-- Classes for TKITWI01 (Taman Kanak-kanak)
-- INSERT INTO `classes` (`tenant_id`, `kode_kelas`, `nama_kelas`, `jenjang`, `wali_kelas_id`) VALUES
-- ('TKITWI01', 'TK-A', 'Kelas Tunas Harapan A', 'TK', NULL),
-- ('TKITWI01', 'TK-B', 'Kelas Tunas Harapan B', 'TK', NULL),
-- ('TKITWI01', 'TK-C', 'Kelas Tunas Harapan C', 'TK', NULL);

-- Classes for SDIT01 (SD)
-- INSERT INTO `classes` (`tenant_id`, `kode_kelas`, `nama_kelas`, `jenjang`, `wali_kelas_id`) VALUES
-- ('SDIT01', '1', 'Kelas 1 A', 'SD', NULL),
-- ('SDIT01', '2', 'Kelas 2 A', 'SD', NULL),
-- ('SDIT01', '3', 'Kelas 3 A', 'SD', NULL),
-- ('SDIT01', '4', 'Kelas 4 A', 'SD', NULL),
-- ('SDIT01', '5', 'Kelas 5 A', 'SD', NULL),
-- ('SDIT01', '6', 'Kelas 6 A', 'SD', NULL);

-- Classes for SMPIT01 (SMP)
-- INSERT INTO `classes` (`tenant_id`, `kode_kelas`, `nama_kelas`, `jenjang`, `wali_kelas_id`) VALUES
-- ('SMPIT01', '7', 'Kelas 7 A', 'SMP', NULL),
-- ('SMPIT01', '8', 'Kelas 8 A', 'SMP', NULL),
-- ('SMPIT01', '9', 'Kelas 9 A', 'SMP', NULL);

-- =============================================
-- SEED DATA: Sample Attendance Rules (SYSTEM)
-- =============================================

INSERT INTO `attendance_rules` (`tenant_id`, `type`, `waktu_mulai`, `waktu_akhir`, `keterangan`) VALUES
('SYSTEM', 'Datang', '06:00:00', '07:00:00', 'Tepat Waktu'),
('SYSTEM', 'Datang', '07:01:00', '07:30:00', 'Terlambat Tahap 1'),
('SYSTEM', 'Datang', '07:31:00', '08:00:00', 'Terlambat Tahap 2'),
('SYSTEM', 'Datang', '08:01:00', '12:00:00', 'Terlambat Lebih'),
('SYSTEM', 'Pulang', '12:00:00', '14:00:00', 'Tepat Waktu'),
('SYSTEM', 'Pulang', '14:01:00', '15:00:00', 'Pulang Cepat'),
('SYSTEM', 'Pulang', '15:01:00', '23:59:59', 'Lembur');

-- =============================================
-- GRANT PERMISSIONS (adjust user/password as needed)
-- =============================================

-- GRANT ALL PRIVILEGES ON ypwi_db_v2.* TO 'ypwi_user'@'localhost' IDENTIFIED BY 'strong_password';
-- FLUSH PRIVILEGES;

COMMIT;
