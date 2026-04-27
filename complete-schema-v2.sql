-- =============================================
-- YPWI Luwu Timur - Complete Database Schema v2.0
-- Multi-tenant School Management System
-- Created: 2026-04-27
-- =============================================
-- IMPORTANT: Execute this file as a whole in phpMyAdmin or MySQL CLI
-- Foreign key order: tenants → users → teachers → classes → students → other tables
-- =============================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- =============================================
-- DROP EXISTING TABLES (for fresh install)
-- =============================================

DROP TABLE IF EXISTS `jurnal`;
DROP TABLE IF EXISTS `attendance_requests`;
DROP TABLE IF EXISTS `attendance_rules`;
DROP TABLE IF EXISTS `attendance_devices`;
DROP TABLE IF EXISTS `attendance`;
DROP TABLE IF EXISTS `device_otp_requests`;
DROP TABLE IF EXISTS `news`;
DROP TABLE IF EXISTS `students`;
DROP TABLE IF EXISTS `classes`;
DROP TABLE IF EXISTS `teachers`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `tenants`;
DROP TABLE IF EXISTS `jabatan_options`;
DROP TABLE IF EXISTS `sebagai_options`;
DROP TABLE IF EXISTS `system_settings`;

-- =============================================
-- 1. TENANTS TABLE (Unit Sekolah)
-- Created FIRST — no dependencies
-- =============================================

CREATE TABLE `tenants` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) UNIQUE NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `type` ENUM('pusat','sekolah') DEFAULT 'sekolah',
    `address` TEXT,
    `city` VARCHAR(100),
    `province` VARCHAR(100) DEFAULT 'Sulawesi Selatan',
    `phone` VARCHAR(20),
    `email` VARCHAR(255),
    `logo_path` VARCHAR(500),
    `principal_id` INT NULL,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX `idx_tenant_code` (`code`),
    INDEX `idx_tenant_type` (`type`),
    INDEX `idx_tenant_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 2. USERS TABLE (Central Authentication)
-- Depends on: tenants (tenant_id FK)
-- =============================================

CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('admin','bendahara','ketua','guru','siswa') NOT NULL,
    `tenant_id` VARCHAR(50) DEFAULT NULL,
    `status` ENUM('Aktif','Tidak Aktif') DEFAULT 'Aktif',
    `last_login_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX `idx_email` (`email`),
    INDEX `idx_tenant_role` (`tenant_id`, `role`),
    INDEX `idx_status` (`status`),
    INDEX `idx_last_login` (`last_login_at`),

    CONSTRAINT `fk_users_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 3. TEACHERS TABLE (Guru Profile)
-- Depends on: users (user_id FK), tenants (tenant_id FK)
-- =============================================

CREATE TABLE `teachers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNIQUE NOT NULL,
    `nip` VARCHAR(50) UNIQUE,
    `nik` VARCHAR(20) UNIQUE,
    `scan_id` VARCHAR(50) UNIQUE,
    `nama` VARCHAR(255) NOT NULL,
    `jenis_kelamin` ENUM('Laki-laki','Perempuan'),
    `tempat_lahir` VARCHAR(100),
    `tanggal_lahir` DATE,
    `alamat` TEXT,
    `no_wa` VARCHAR(20),
    `email_alternatif` VARCHAR(255),
    `jenjang` VARCHAR(50),
    `jabatan` VARCHAR(100),
    `sebagai` VARCHAR(100),
    `status_kepegawaian` ENUM('PTY','PEGAWAI TETAP','HONOR','PKL','LAINNYA'),
    `tmt` DATE,
    `foto_path` VARCHAR(500),

    `accessible_units` JSON DEFAULT NULL,
    `jabatan_tambahan` JSON DEFAULT NULL,

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
    `tenant_id` VARCHAR(50) NOT NULL,

    CONSTRAINT `fk_teachers_user` 
        FOREIGN KEY (`user_id`) 
        REFERENCES `users`(`id`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_teachers_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    INDEX `idx_teacher_tenant` (`tenant_id`),
    INDEX `idx_teacher_scan` (`scan_id`),
    INDEX `idx_teacher_nip` (`nip`),
    INDEX `idx_teacher_nik` (`nik`),
    INDEX `idx_teacher_nama` (`nama`),
    INDEX `idx_teacher_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 4. CLASSES TABLE (Kelas per Sekolah)
-- Created AFTER teachers — wali_kelas_id FK added later via ALTER TABLE
-- =============================================

CREATE TABLE `classes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `tenant_id` VARCHAR(50) NOT NULL,
    `kode_kelas` VARCHAR(50) NOT NULL,
    `nama_kelas` VARCHAR(100) NOT NULL,
    `jenjang` VARCHAR(50) NOT NULL,
    `kurikulum` VARCHAR(100) DEFAULT 'K13',
    `wali_kelas_id` INT NULL,
    `kapasitas_max` INT DEFAULT 40,
    `academic_year` VARCHAR(20) DEFAULT '2024/2025',
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY `unique_class_per_tenant` (`tenant_id`, `kode_kelas`, `academic_year`),

    CONSTRAINT `fk_classes_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE

    -- NOTE: wali_kelas_id FK added later via ALTER TABLE after teachers is created
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 5. ADD FOREIGN KEY for classes.wali_kelas_id → teachers.id
-- Must be added AFTER teachers table exists
-- =============================================

ALTER TABLE `classes`
ADD CONSTRAINT `fk_classes_wali_kelas` 
    FOREIGN KEY (`wali_kelas_id`) 
    REFERENCES `teachers`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE;

-- =============================================
-- 5. STUDENTS TABLE (Siswa Profile)
-- Depends on: users (user_id FK), classes (kelas_id FK), tenants (tenant_id FK)
-- NOTE: FK constraints added via ALTER TABLE after all tables exist
-- =============================================

CREATE TABLE `students` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNIQUE NOT NULL,
    `nisn` VARCHAR(20) UNIQUE,
    `scan_id` VARCHAR(50) UNIQUE,
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
    `tenant_id` VARCHAR(50) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX `idx_student_tenant` (`tenant_id`),
    INDEX `idx_student_scan` (`scan_id`),
    INDEX `idx_student_nisn` (`nisn`),
    INDEX `idx_student_kelas` (`kelas_id`),
    INDEX `idx_student_nama` (`nama_siswa`),
    INDEX `idx_student_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Add foreign keys after all tables exist
ALTER TABLE `students`
ADD CONSTRAINT `fk_students_user` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `users`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE,
ADD CONSTRAINT `fk_students_kelas` 
    FOREIGN KEY (`kelas_id`) 
    REFERENCES `classes`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE,
ADD CONSTRAINT `fk_students_tenant` 
    FOREIGN KEY (`tenant_id`) 
    REFERENCES `tenants`(`code`) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;

-- =============================================
-- 7. ATTENDANCE_DEVICES TABLE
-- Depends on: tenants (tenant_id FK), users (created_by FK)
-- =============================================

CREATE TABLE `attendance_devices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `device_id` VARCHAR(255) UNIQUE NOT NULL,
    `device_name` VARCHAR(255) NOT NULL,
    `device_location` VARCHAR(255) DEFAULT NULL,
    `phone_number` VARCHAR(20) DEFAULT NULL,
    `tenant_id` VARCHAR(50) NOT NULL,
    `created_by` INT NOT NULL,
    `status` ENUM('pending','active','inactive') DEFAULT 'pending',
    `last_used_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT `fk_devices_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_devices_created_by` 
        FOREIGN KEY (`created_by`) 
        REFERENCES `users`(`id`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    INDEX `idx_device_id` (`device_id`),
    INDEX `idx_device_tenant` (`tenant_id`),
    INDEX `idx_device_status` (`status`),
    INDEX `idx_device_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 8. ATTENDANCE_RULES TABLE
-- Depends on: tenants (tenant_id FK)
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

    CONSTRAINT `fk_attendance_rules_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    UNIQUE KEY `unique_rule_per_tenant` (`tenant_id`, `type`, `waktu_mulai`, `waktu_akhir`),
    INDEX `idx_attendance_rules_tenant` (`tenant_id`),
    INDEX `idx_attendance_rules_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 9. ATTENDANCE TABLE (Absensi Records)
-- Depends on: users (user_id FK), tenants (tenant_id FK), 
--             classes (kelas_id FK), attendance_devices (device_id FK)
-- =============================================

CREATE TABLE `attendance` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `scan_id` VARCHAR(50) NULL,
    `device_id` VARCHAR(255) NULL,
    `tenant_id` VARCHAR(50) NOT NULL,
    `kelas_id` INT NULL,
    `tanggal` DATE DEFAULT (CURDATE()),
    `jam` TIME DEFAULT (CURTIME()),
    `status` ENUM('Datang','Pulang') DEFAULT 'Datang',
    `keterangan` TEXT,
    `jenis_absen` ENUM('Absen','Izin','Sakit','Cuti') DEFAULT 'Absen',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT `fk_attendance_user` 
        FOREIGN KEY (`user_id`) 
        REFERENCES `users`(`id`) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_attendance_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_attendance_kelas` 
        FOREIGN KEY (`kelas_id`) 
        REFERENCES `classes`(`id`) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_attendance_device` 
        FOREIGN KEY (`device_id`) 
        REFERENCES `attendance_devices`(`device_id`) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    INDEX `idx_attendance_scan` (`scan_id`),
    INDEX `idx_attendance_user` (`user_id`),
    INDEX `idx_attendance_device` (`device_id`),
    INDEX `idx_attendance_tanggal` (`tanggal`),
    INDEX `idx_attendance_tenant` (`tenant_id`),
    INDEX `idx_attendance_kelas` (`kelas_id`),
    INDEX `idx_attendance_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 10. ATTENDANCE_REQUESTS TABLE (Pengajuan Izin/Sakit)
-- Depends on: users (user_id, approved_by FK), tenants (tenant_id FK)
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
    `approved_by` INT NULL,
    `approved_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT `fk_requests_user` 
        FOREIGN KEY (`user_id`) 
        REFERENCES `users`(`id`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_requests_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_requests_approved_by` 
        FOREIGN KEY (`approved_by`) 
        REFERENCES `users`(`id`) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    INDEX `idx_request_user` (`user_id`),
    INDEX `idx_request_tenant` (`tenant_id`),
    INDEX `idx_request_status` (`status`),
    INDEX `idx_request_dates` (`tanggal_mulai`, `tanggal_akhir`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 11. NEWS TABLE (Berita/Announcements)
-- Depends on: tenants (tenant_id FK), users (author_id FK)
-- =============================================

CREATE TABLE `news` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `tenant_id` VARCHAR(50) NULL,
    `author_id` INT NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `category` VARCHAR(100) DEFAULT 'Umum',
    `image_path` VARCHAR(500),
    `is_published` BOOLEAN DEFAULT FALSE,
    `published_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT `fk_news_tenant` 
        FOREIGN KEY (`tenant_id`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT `fk_news_author` 
        FOREIGN KEY (`author_id`) 
        REFERENCES `users`(`id`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    INDEX `idx_news_tenant` (`tenant_id`),
    INDEX `idx_news_author` (`author_id`),
    INDEX `idx_news_published` (`is_published`, `published_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 12. JABATAN_OPTIONS (Dropdown)
-- No dependencies
-- =============================================

CREATE TABLE `jabatan_options` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `jabatan` VARCHAR(100) NOT NULL,
    `deskripsi` TEXT,
    `is_active` BOOLEAN DEFAULT TRUE,
    `urutan` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY `unique_jabatan` (`jabatan`),
    INDEX `idx_jabatan_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 13. SEBAGAI_OPTIONS (Dropdown)
-- No dependencies
-- =============================================

CREATE TABLE `sebagai_options` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `sebagai` VARCHAR(100) NOT NULL,
    `deskripsi` TEXT,
    `is_active` BOOLEAN DEFAULT TRUE,
    `urutan` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY `unique_sebagai` (`sebagai`),
    INDEX `idx_sebagai_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 14. DEVICE_OTP_REQUESTS
-- Depends on: tenants (tenant_code FK)
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

    CONSTRAINT `fk_otp_tenant` 
        FOREIGN KEY (`tenant_code`) 
        REFERENCES `tenants`(`code`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    INDEX `idx_otp_tenant` (`tenant_code`),
    INDEX `idx_otp_used` (`used`),
    INDEX `idx_otp_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 15. JURNAL TABLE
-- Depends on: teachers (teacher_id FK)
-- =============================================

CREATE TABLE `jurnal` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `teacher_id` INT NULL,
    `date` DATE DEFAULT (CURDATE()),
    `materi` TEXT,
    `hadir` INT DEFAULT 0,
    `absen` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT `fk_jurnal_teacher` 
        FOREIGN KEY (`teacher_id`) 
        REFERENCES `teachers`(`id`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    INDEX `idx_jurnal_teacher` (`teacher_id`),
    INDEX `idx_jurnal_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 16. SYSTEM_SETTINGS TABLE
-- Depends on: users (updated_by FK) — optional
-- =============================================

CREATE TABLE `system_settings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) UNIQUE NOT NULL,
    `setting_value` TEXT,
    `description` TEXT,
    `updated_by` INT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT `fk_settings_updated_by` 
        FOREIGN KEY (`updated_by`) 
        REFERENCES `users`(`id`) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    INDEX `idx_settings_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============================================
-- 17. ADD FOREIGN KEY to tenants (principal_id -> users.id)
-- Must be added AFTER users table is populated with data
-- =============================================

-- NOTE: principal_id FK will be added after users are inserted
-- We'll add it at the end via ALTER TABLE

-- =============================================
-- SEED DATA: Tenants (26 Unit Sekolah + 1 Pusat)
-- Must be inserted BEFORE users (because users reference tenants)
-- =============================================

INSERT INTO `tenants` (`code`, `name`, `type`, `address`, `city`, `province`, `phone`) VALUES
('YPWILUTIM', 'Yayasan Pesantren Wahdah Islamiyah Luwu Timur', 'pusat', 'Jl. Raya Luwu Timur', 'Luwu Timur', 'Sulawesi Selatan', '081234567890'),
('TKITWI01', 'TKIT WAHDAH ISLAMIYAH 01 TOMONI', 'sekolah', 'Desa Mandiri, Kec. Tomoni', 'Luwu Timur', 'Sulawesi Selatan', '081111111101'),
('TKITWI02', 'TKIT WAHDAH ISLAMIYAH 02 MALILI', 'sekolah', 'Malili', 'Luwu Timur', 'Sulawesi Selatan', '081111111102'),
('TKITWI03', 'TKIT WAHDAH ISLAMIYAH 03 WASUPONDA', 'sekolah', 'Wasuponda', 'Luwu Timur', 'Sulawesi Selatan', '081111111103'),
('TKITWI04', 'TKIT WAHDAH ISLAMIYAH 04 KALAENA', 'sekolah', 'Kalaena', 'Luwu Timur', 'Sulawesi Selatan', '081111111104'),
('TKITWI05', 'TKIT WAHDAH ISLAMIYAH 05 BURAU', 'sekolah', 'Burau', 'Luwu Timur', 'Sulawesi Selatan', '081111111105'),
('TKITWI06', 'TKIT WAHDAH ISLAMIYAH 06 WOTU', 'sekolah', 'Wotu', 'Luwu Timur', 'Sulawesi Selatan', '081111111106'),
('TKITWI07', 'TKIT WAHDAH ISLAMIYAH 07 MANGKUTANA', 'sekolah', 'Mangkutana', 'Luwu Timur', 'Sulawesi Selatan', '081111111107'),
('TKITWI08', 'TKIT WAHDAH ISLAMIYAH 08 TOWUTI', 'sekolah', 'Towuti', 'Luwu Timur', 'Sulawesi Selatan', '081111111108'),
('TKITRABBANI', 'TKIT RABBANI SOROWAKO', 'sekolah', 'Sorowako', 'Luwu Timur', 'Sulawesi Selatan', '081111111109'),
('SDITIRA', 'SDIT INSAN RABBANI', 'sekolah', 'Insan Rabbani', 'Luwu Timur', 'Sulawesi Selatan', '081111111110'),
('SDITWI03', 'SDIT QURANI WAHDAH ISLAMIYAH 03 SOROWAKO', 'sekolah', 'Sorowako', 'Luwu Timur', 'Sulawesi Selatan', '081111111111'),
('SDITWI02', 'SDIT WAHDAH ISLAMIYAH 02 TOMONI', 'sekolah', 'Tomoni', 'Luwu Timur', 'Sulawesi Selatan', '081111111112'),
('SDITWI04', 'SDIT WAHDAH ISLAMIYAH 04 BURAU', 'sekolah', 'Burau', 'Luwu Timur', 'Sulawesi Selatan', '081111111113'),
('SDITWI05', 'SDIT WAHDAH ISLAMIYAH 05 KALAENA', 'sekolah', 'Kalaena', 'Luwu Timur', 'Sulawesi Selatan', '081111111114'),
('SDITWI06', 'SDIT WAHDAH ISLAMIYAH 06 WASUPONDA', 'sekolah', 'Wasuponda', 'Luwu Timur', 'Sulawesi Selatan', '081111111115'),
('SDITWI07', 'SDIT WAHDAH ISLAMIYAH 07 WOTU', 'sekolah', 'Wotu', 'Luwu Timur', 'Sulawesi Selatan', '081111111116'),
('SDITWI08', 'SDIT WAHDAH ISLAMIYAH 08 TOWUTI', 'sekolah', 'Towuti', 'Luwu Timur', 'Sulawesi Selatan', '081111111117'),
('SDITWI09', 'SDIT WAHDAH ISLAMIYAH 09 MANGKUTANA', 'sekolah', 'Mangkutana', 'Luwu Timur', 'Sulawesi Selatan', '081111111118'),
('SMPITWI01', 'SMPIT WAHDAH ISLAMIYAH 01 MALILI', 'sekolah', 'Malili', 'Luwu Timur', 'Sulawesi Selatan', '081111111119'),
('SMPITWI02', 'SMPIT WAHDAH ISLAMIYAH 02 KALAENA', 'sekolah', 'Kalaena', 'Luwu Timur', 'Sulawesi Selatan', '081111111120'),
('SMAITWI01', 'SMAIT WAHDAH ISLAMIYAH 01 TOMONI', 'sekolah', 'Tomoni', 'Luwu Timur', 'Sulawesi Selatan', '081111111121'),
('PONDOKWI', 'PONDOK PESANTREN INFORMATIKA DAN BAHASA WAHDAH ISLAMIYAH', 'sekolah', 'Luwu Timur', 'Luwu Timur', 'Sulawesi Selatan', '081111111122'),
('PPTQMALILI', 'PPTQ Malili', 'sekolah', 'Malili', 'Luwu Timur', 'Sulawesi Selatan', '081111111123'),
('PPTQSAF', 'PPTQ SALMAN ALFARISI PUTRA', 'sekolah', 'Sorowako', 'Luwu Timur', 'Sulawesi Selatan', '081111111124'),
('PPTQSOROWAKO', 'PPTQ Sorowako', 'sekolah', 'Sorowako', 'Luwu Timur', 'Sulawesi Selatan', '081111111125');

-- =============================================
-- SEED DATA: Jabatan Options
-- =============================================

INSERT INTO `jabatan_options` (`jabatan`, `deskripsi`, `urutan`) VALUES
('Guru Kelas', 'Guru yang mengajar di kelas', 1),
('Guru Mapel', 'Guru mata pelajaran', 2),
('Kepala Sekolah', 'Kepala Madrasah/Sekolah', 3),
('Wakil Kepala Sekolah', 'Wakil Kepala Madrasah/Sekolah', 4),
('Guru BK', 'Guru Bimbingan Konseling', 5),
('Guru Agama', 'Guru Pendidikan Agama', 6),
('Guru Olahraga', 'Guru Pendidikan Jasmani dan Kesenian', 7),
('Guru Bahasa', 'Guru Bahasa Indonesia/Asing', 8),
('Guru Matematika', 'Guru Matematika', 9),
('Guru IPA', 'Guru Ilmu Pengetahuan Alam', 10),
('Guru IPS', 'Guru Ilmu Pengetahuan Sosial', 11),
('Tata Usaha', 'Staf tata usaha', 12),
('Operator', 'Operator data', 13),
('Bendahara', 'Bendahara', 14);

-- =============================================
-- SEED DATA: Sebagai Options
-- =============================================

INSERT INTO `sebagai_options` (`sebagai`, `deskripsi`, `urutan`) VALUES
('Wali Kelas', 'Guru pembimbing kelas', 1),
('Koordinator Tahun', 'Koordinator untuk tingkat tahun', 2),
('Koordinator Mapel', 'Koordinator mata pelajaran', 3),
('Staff Tata Usaha', 'Staf tata usaha', 4),
('Anggota Komite', 'Anggota komite sekolah', 5),
('Panitia', 'Panitia kegiatan', 6);

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
-- SEED DATA: Attendance Rules (SYSTEM)
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
-- SAMPLE DATA: Quick Start Accounts
-- =============================================

INSERT INTO `users` (`email`, `password`, `role`, `tenant_id`, `status`) VALUES
('admin@ypwi.sch.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'admin', 'YPWILUTIM', 'Aktif'),
('bendahara@ypwi.sch.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'bendahara', 'YPWILUTIM', 'Aktif'),
('ketua@ypwi.sch.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'ketua', 'YPWILUTIM', 'Aktif'),
('mpk@ypwi.sch.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'guru', 'TKITWI01', 'Aktif'),
('siswa01@ypwi.sch.id', '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2', 'siswa', 'TKITWI01', 'Aktif');

-- =============================================
-- SAMPLE DATA: Teacher Profile (for mpk@ypwi.sch.id)
-- =============================================

INSERT INTO `teachers` (`user_id`, `nama`, `nip`, `nik`, `scan_id`, `jenis_kelamin`, `tempat_lahir`, `tanggal_lahir`, `alamat`, `no_wa`, `email_alternatif`, `jenjang`, `jabatan`, `sebagai`, `status_kepegawaian`, `tmt`, `foto_path`, `tenant_id`, `accessible_units`, `jabatan_tambahan`, `status_aktif`, `keterangan`) 
VALUES (
    (SELECT id FROM users WHERE email = 'mpk@ypwi.sch.id'),
    'M. Pakorn',
    '196309201978032001',
    '7324084107840052',
    '7324084107840052',
    'Laki-laki',
    'Luwu Timur',
    '1980-01-01',
    'Alamat Guru',
    '6281234567890',
    'mpk@ypwi.sch.id',
    '01 TKIT',
    'Guru Kelas',
    'Wali Kelas',
    'PTY',
    '2020-01-01',
    'uploads/MPK.jpg',
    'TKITWI01',
    NULL,
    NULL,
    'Aktif',
    'Guru contoh'
);

-- =============================================
-- SAMPLE DATA: Student Profile (for siswa01@ypwi.sch.id)
-- First create default classes for TKITWI01
-- =============================================

INSERT IGNORE INTO `classes` (`tenant_id`, `kode_kelas`, `nama_kelas`, `jenjang`, `is_active`) 
VALUES 
('TKITWI01', 'TK-A', 'Kelas A TK', 'TK', TRUE),
('TKITWI01', 'TK-B', 'Kelas B TK', 'TK', TRUE),
('TKITWI01', 'TK-C', 'Kelas C TK', 'TK', TRUE);

INSERT INTO `students` (`user_id`, `nama_siswa`, `nisn`, `scan_id`, `kelas_id`, `jenis_kelamin`, `tempat_lahir`, `tanggal_lahir`, `alamat`, `no_wa`, `nama_orang_tua`, `no_wa_orang_tua`, `tenant_id`, `foto_path`, `keterangan`) 
VALUES (
    (SELECT id FROM users WHERE email = 'siswa01@ypwi.sch.id'),
    'Siswa Contoh',
    '1234567890',
    '1234567890',
    (SELECT id FROM classes WHERE tenant_id = 'TKITWI01' AND kode_kelas = 'TK-A' LIMIT 1),
    'Laki-laki',
    'Luwu Timur',
    '2015-01-01',
    'Alamat Siswa',
    '6281234567891',
    'Orang Tua Siswa',
    '6281234567892',
    'TKITWI01',
    'uploads/SISWA01.jpg',
    'Siswa contoh'
);

-- =============================================
-- ADD FOREIGN KEY: classes.wali_kelas_id → teachers.id
-- Added AFTER teachers table is populated
-- =============================================

ALTER TABLE `classes`
ADD CONSTRAINT `fk_classes_wali_kelas` 
    FOREIGN KEY (`wali_kelas_id`) 
    REFERENCES `teachers`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE;

-- =============================================
-- ADD FOREIGN KEY: tenants.principal_id → users.id
-- Added AFTER users table is populated
-- =============================================

ALTER TABLE `tenants`
ADD CONSTRAINT `fk_tenants_principal` 
    FOREIGN KEY (`principal_id`) 
    REFERENCES `users`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE;

-- =============================================
-- HOW TO USE
-- =============================================

-- Run in phpMyAdmin SQL tab or MySQL CLI:
-- mysql -u root -p ypwi_db < complete-schema-v2.sql

-- Verify:
-- SHOW TABLES;
-- SELECT * FROM tenants LIMIT 5;
-- SELECT * FROM users;

-- Login credentials:
-- Email: admin@ypwi.sch.id
-- Password: password123
-- (Change password after first login!)

-- =============================================
-- IMPORTANT NOTES
-- =============================================

-- 1. All passwords use bcrypt hash of "password123"
--    CHANGE IMMEDIATELY AFTER FIRST LOGIN!

-- 2. Foreign key order is enforced:
--    tenants (1) → users (2) → teachers (3) → classes (4) → students (5) → others

-- 3. tenant_id in users can be NULL for central admin (YPWILUTIM).

-- 4. Classes must be created per tenant before adding students.

-- 5. principal_id FK added at the end (after users exist).

-- 6. Default academic year: 2024/2025

-- =============================================
-- GRANT PERMISSIONS (if needed)
-- =============================================

-- CREATE USER 'ypwi_user'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';
-- GRANT ALL PRIVILEGES ON ypwi_db.* TO 'ypwi_user'@'localhost';
-- FLUSH PRIVILEGES;

COMMIT;
