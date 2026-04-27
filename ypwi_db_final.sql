-- Final Database Setup for YPWI App
-- Create if not exists

CREATE DATABASE IF NOT EXISTS ypwi_db;
USE ypwi_db;

-- Tenants table
CREATE TABLE tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL
);

-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Admin Yayasan', 'Admin Sekolah', 'Bendahara Yayasan', 'Bendahara Sekolah', 'Guru', 'Siswa') NOT NULL,
    tenant_id VARCHAR(50),
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE SET NULL
);

-- Teachers table (gabung info dan gaji)
-- Table: teachers
-- Urutan field sesuai permintaan user
CREATE TABLE teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    niy VARCHAR(50),
    nik VARCHAR(20),
    scan_id VARCHAR(50),
    jenis_kelamin VARCHAR(20),
    tempat_lahir VARCHAR(100),
    tanggal_lahir DATE,
    alamat TEXT,
    no_wa VARCHAR(20),
    email VARCHAR(100),
    password VARCHAR(255),
    tenant_id VARCHAR(50),
    jenjang VARCHAR(50),
    jabatan VARCHAR(255),
    sebagai VARCHAR(50),
    status_kepegawaian VARCHAR(50),
    tmt DATE,
    status_aktif VARCHAR(20) DEFAULT 'Aktif',
    keterangan TEXT,
    link_foto VARCHAR(500),
    terima_notifikasi BOOLEAN DEFAULT TRUE,
    -- Additional fields for multi-unit support
    accessible_units JSON DEFAULT NULL,
    -- Salary fields
    gaji_pokok DECIMAL(15,2) DEFAULT 0,
    tunj_kinerja DECIMAL(15,2) DEFAULT 0,
    tunj_umum DECIMAL(15,2) DEFAULT 0,
    tunj_istri DECIMAL(15,2) DEFAULT 0,
    tunj_anak DECIMAL(15,2) DEFAULT 0,
    tunj_kepala_sekolah DECIMAL(15,2) DEFAULT 0,
    tunj_wali_kelas DECIMAL(15,2) DEFAULT 0,
    honor_bendahara DECIMAL(15,2) DEFAULT 0,
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE SET NULL
);

-- Students table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_siswa VARCHAR(255) NOT NULL,
    jenis_kelamin ENUM('Laki-laki', 'Perempuan'),
    tenant_id VARCHAR(50),
    password VARCHAR(255), -- For login
    jenjang VARCHAR(50),
    nama_sheet VARCHAR(255),
    nisn VARCHAR(20),
    scan_id VARCHAR(50),
    kelas VARCHAR(50),
    iuran_bulanan DECIMAL(10,2),
    nama_orang_tua VARCHAR(255),
    no_wa VARCHAR(20),
    keterangan TEXT
);

-- Attendance table
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(255),
    asal_sekolah VARCHAR(255),
    jabatan VARCHAR(100),
    tanggal DATE DEFAULT CURRENT_DATE,
    jam TIME DEFAULT CURRENT_TIME,
    status ENUM('Datang', 'Pulang') DEFAULT 'Datang',
    keterangan TEXT,
    sebagai VARCHAR(100),
    no_wa VARCHAR(20),
    jenis_absen VARCHAR(50) DEFAULT 'Absen'
);

-- Attendance Requests table (Izin/Sakit)
CREATE TABLE attendance_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guru_id INT NOT NULL,
    nama VARCHAR(255),
    tenant_id VARCHAR(50),
    alasan TEXT NOT NULL,
    jenis ENUM('Izin', 'Sakit') NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_akhir DATE NOT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guru_id) REFERENCES teachers(id) ON DELETE CASCADE
);

-- News table
CREATE TABLE news (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    content TEXT,
    category VARCHAR(100),
    author VARCHAR(100),
    tenant_id VARCHAR(50),
    image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE SET NULL
);

-- Sample news data
INSERT INTO news (title, content, category, author, tenant_id, image) VALUES
('Selamat Datang di Sistem YPWI Luwu Timur', 'Sistem manajemen sekolah YPWI telah resmi diluncurkan untuk memudahkan pengelolaan pendidikan di 26 unit sekolah.', 'berita', 'Admin YPWI', 'ypwilutim', 'https://tkwahdah.sch.id/wp-content/uploads/2025/11/8dd474be-9537-4c35-9793-ecebd0614245.jpg'),
('Program Hafalan Al-Qur\'an PPTQ Malili', 'PPTQ Malili membuka pendaftaran santri baru untuk program tahfidz Al-Qur\'an dengan metode modern.', 'berita', 'Admin PPTQ', 'pptqmalili', 'https://metromilenial.id/wp-content/uploads/2023/06/IMG-20230617-WA0034.jpg'),
('Wisuda Santri SMAIT YPWI Tomoni', 'SMAIT YPWI Tomoni menggelar wisuda angkatan ke-15 dengan prestasi gemilang di bidang akademik dan non-akademik.', 'berita', 'Admin SMAIT', 'smatomoni', 'https://i.ytimg.com/vi/6z6HE7k9FO4/maxresdefault.jpg'),
('Bakti Sosial Lazis Wahdah', 'Lazis Wahdah mendistribusikan bantuan kepada masyarakat terdampak bencana di Luwu Timur.', 'blog', 'Admin Lazis', 'ypwilutim', 'https://wahdah.or.id/wp-content/uploads/2020/04/Lazis-Wahdah-Luwu-Timur-Salkane-Sembako-ke-Warga-Terdampak-Corona.jpg');

-- Insert tenants (26 schools + YPWI Pusat)
INSERT INTO tenants (name, code) VALUES
('YPWI LUWU TIMUR (PUSAT)', 'ypwilutim'),
('TKIT WAHDAH ISLAMIYAH 01 TOMONI', 'tkwahdah01'),
('TKIT WAHDAH ISLAMIYAH 02 MALILI', 'tkmalili'),
('TKIT WAHDAH ISLAMIYAH 03 WASUPONDA', 'tkwasuponda'),
('TKIT WAHDAH ISLAMIYAH 04 KALAENA', 'tkkalaena'),
('TKIT WAHDAH ISLAMIYAH 05 BURAU', 'tkburau'),
('TKIT WAHDAH ISLAMIYAH 06 WOTU', 'tkwotuu'),
('TKIT WAHDAH ISLAMIYAH 07 MANGKUTANA', 'tkmangkutana'),
('TKIT WAHDAH ISLAMIYAH 08 TOWUTI', 'tktowuti'),
('TKIT RABBANI SOROWAKO', 'tksorowako'),
('SDIT INSAN RABBANI', 'sdinsanrabbani'),
('SDIT QURANI WAHDAH ISLAMIYAH 03 SOROWAKO', 'sdquranisorowako'),
('SDIT WAHDAH ISLAMIYAH 02 TOMONI', 'sdwahdah02tomoni'),
('SDIT WAHDAH ISLAMIYAH 04 BURAU', 'sdburau'),
('SDIT WAHDAH ISLAMIYAH 05 KALAENA', 'sdkalaena'),
('SDIT WAHDAH ISLAMIYAH 06 WASUPONDA', 'sdwasuponda'),
('SDIT WAHDAH ISLAMIYAH 07 WOTU', 'sdwotuu'),
('SDIT WAHDAH ISLAMIYAH 08 TOWUTI', 'sdtowuti'),
('SDIT WAHDAH ISLAMIYAH 09 MANGKUTANA', 'sdmangkutana'),
('SMPIT WAHDAH ISLAMIYAH 01 MALILI', 'smpmalili'),
('SMPIT WAHDAH ISLAMIYAH 02 KALAENA', 'smpkalaena'),
('SMAIT WAHDAH ISLAMIYAH 01 TOMONI', 'smatomoni'),
('PONDOK PESANTREN INFORMATIKA DAN BAHASA WAHDAH ISLAMIYAH', 'pondokinformatika'),
('PPTQ Malili', 'pptqmalili'),
('PPTQ SALMAN ALFARISI PUTRA', 'pptqsalman'),
('PPTQ Sorowako', 'pptqsorowako');

-- Insert sample users (hash password with bcrypt)
INSERT INTO users (username, password_hash, role, tenant_id) VALUES
('adminyayasan', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'Admin Yayasan', 'tkwahdah01'),
('adsekolah', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'Admin Sekolah', 'sdinsanrabbani'),
('bendyayasan', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'Bendahara Yayasan', 'smpmalili'),
('bendsekolah', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'Bendahara Sekolah', 'pptqmalili'),
('gurutest', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'Guru', 'tkmalili'),
('siswatest', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'Siswa', 'smatomoni');

-- Sample data (replace with full from CSV)
-- Urutan field: id, nama, niy, nik, scan_id, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_wa, email, password, tenant_id, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, link_foto, terima_notifikasi, accessible_units, gaji_pokok, tunj_kinerja, tunj_umum, tunj_istri, tunj_anak, tunj_kepala_sekolah, tunj_wali_kelas, honor_bendahara
INSERT INTO teachers (nama, niy, nik, scan_id, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_wa, email, password, tenant_id, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, link_foto, terima_notifikasi, accessible_units, gaji_pokok, tunj_kinerja, tunj_umum, tunj_istri, tunj_anak, tunj_kepala_sekolah, tunj_wali_kelas, honor_bendahara) VALUES
-- YPWI Pusat users (tenant = ypwilutim)
('Admin Pusat YPWI', 'ADMIN001', '1234567890', 'ADMIN001', 'Laki-laki', 'Luwu Timur', '1980-01-01', 'YPWI Pusat', '6281234567890', 'admin@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'ypwilutim', NULL, 'S1', 'Admin Yayasan', 'Admin', 'PNS', '2020-01-01', 'Aktif', 'Administrator Sistem Pusat', '', TRUE, 5000000, 1000000, 500000, 0, 0, 0, 0, 0),
('Bendahara Pusat YPWI', 'BEND001', '1234567891', 'BEND001', 'Perempuan', 'Luwu Timur', '1982-01-01', 'YPWI Pusat', '6281234567891', 'bendahara@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'ypwilutim', 'S1', 'Bendahara Yayasan', 'Bendahara', 'PNS', '2020-01-01', 'Aktif', 'Bendahara Yayasan Pusat', '', TRUE, 4500000, 900000, 450000, 0, 0, 0, 0, 0),
('Ketua YPWI', 'KETUA001', '1234567892', 'KETUA001', 'Laki-laki', 'Luwu Timur', '1965-01-01', 'YPWI Pusat', '6281234567892', 'ketua@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'ypwilutim', 'S3', 'Ketua', 'Ketua', 'PNS', '2010-01-01', 'Aktif', 'Ketua Yayasan YPWI', '', TRUE, 8000000, 2000000, 1000000, 0, 0, 0, 0, 0),
-- School level users (tenant = individual schools)
('Admin TK Wahdah', 'ADMINTK001', '1234567893', 'ADMINTK001', 'Laki-laki', 'Tomoni', '1985-01-01', 'TK Wahdah 01', '6281234567893', 'admin.tkwahdah@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', NULL, 'D3', 'Admin Sekolah', 'Admin', 'PNS', '2021-01-01', 'Aktif', 'Admin TK Wahdah 01', '', TRUE, 3500000, 700000, 350000, 0, 0, 0, 0, 0),
-- Multi-unit user (guru yang mengajar di 2 sekolah)
('Guru Multi Unit', 'MULTI001', '1234567899', 'MULTI001', 'Perempuan', 'Luwu Timur', '1990-01-01', 'Multi Unit Teacher', '6281234567899', 'guru.multi@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', '["tkwahdah01", "sdinsanrabbani", "smpmalili"]', 'S1', 'Mapel', 'Guru', 'PNS', '2022-01-01', 'Aktif', 'Guru yang mengajar di 3 sekolah berbeda', '', TRUE, 3000000, 600000, 300000, 0, 0, 0, 0, 0),
-- Multi-role user (wali kelas + mapel)
('Guru Multi Role', 'MULTIR001', '1234567898', 'MULTIR001', 'Laki-laki', 'Tomoni', '1988-01-01', 'TK Wahdah 01', '6281234567898', 'guru.multir@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', NULL, 'S1', 'Walikelas, Mapel', 'Guru', 'PNS', '2021-01-01', 'Aktif', 'Wali kelas sekaligus guru mapel', '', TRUE, 3200000, 640000, 320000, 0, 0, 0, 250000, 0),
-- Multi-unit + Multi-role user (guru honorer di 2 sekolah dengan jabatan berbeda)
('Guru Flex', 'FLEX001', '1234567897', 'FLEX001', 'Perempuan', 'Malili', '1992-01-01', 'Honorer Multi Unit', '6281234567897', 'guru.flex@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'smpmalili', '["smpmalili", "smatomoni"]', 'D3', 'Mengaji, Mapel', 'Guru', 'Honor', '2023-01-01', 'Aktif', 'Guru honorer di 2 SMP dengan 2 jabatan berbeda', '', TRUE, 2000000, 400000, 200000, 0, 0, 0, 0, 0),
('Bendahara TK Wahdah', 'BENDTK001', '1234567894', 'BENDTK001', 'Perempuan', 'Tomoni', '1987-01-01', 'TK Wahdah 01', '6281234567894', 'bendahara.tkwahdah@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', 'D3', 'Bendahara Sekolah', 'Bendahara', 'PNS', '2021-01-01', 'Aktif', 'Bendahara TK Wahdah 01', '', TRUE, 3200000, 650000, 320000, 0, 0, 0, 0, 0),
('KS TK Wahdah', 'KSTK001', '1234567895', 'KSTK001', 'Perempuan', 'Tomoni', '1978-01-01', 'TK Wahdah 01', '6281234567895', 'ks.tkwahdah@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', 'S1', 'Kepala Sekolah', 'Kepala Sekolah', 'PNS', '2018-01-01', 'Aktif', 'Kepala Sekolah TK Wahdah 01', '', TRUE, 4000000, 800000, 400000, 0, 0, 500000, 0, 0),
('Guru Mapel TK', 'GURUTK001', '1234567896', 'GURUTK001', 'Perempuan', 'Tomoni', '1990-01-01', 'TK Wahdah 01', '6281234567896', 'guru.mapel@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', 'S1', 'Mapel', 'Guru', 'PNS', '2022-01-01', 'Aktif', 'Guru Mapel TK Wahdah 01', '', TRUE, 2800000, 560000, 280000, 0, 0, 0, 0, 0),
('Guru Mengaji TK', 'GURUMENGAJI001', '1234567897', 'GURUMENGAJI001', 'Laki-laki', 'Tomoni', '1988-01-01', 'TK Wahdah 01', '6281234567897', 'guru.mengaji@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', 'S1', 'Mengaji', 'Guru', 'PNS', '2022-01-01', 'Aktif', 'Guru Mengaji TK Wahdah 01', '', TRUE, 2800000, 560000, 280000, 0, 0, 0, 0, 0),
('Wali Kelas TK A', 'WALIKA001', '1234567898', 'WALIKA001', 'Perempuan', 'Tomoni', '1985-01-01', 'TK Wahdah 01', '6281234567898', 'walikelas.a@ypwi.sch.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', 'S1', 'Walikelas', 'Guru', 'PNS', '2021-01-01', 'Aktif', 'Wali Kelas TK A Wahdah 01', '', TRUE, 3000000, 600000, 300000, 0, 0, 0, 250000, 0),
('Abu Bakar', '', '', '', '', '', NULL, '', '', '', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', '01 TKIT', '', '', '', NULL, 'Aktif', '', '', TRUE, 0, 0, 0, 0, 0, 0, 0, 0),
('Dra. Jasmiati', '', '', '', 'Perempuan', 'KALOSI', '1963-09-20', 'KOMPLEKS PONDOK SANTRI DARUSSALAM RANTE MARIO', '6282191739881', 'jasmiati09@admin.paud.belajar.id', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', 'tkwahdah01', '01 TKIT', 'Kepala Sekolah', 'Guru', 'PTY', '2013-07-07', 'Aktif', '', '', TRUE, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO students (nama_siswa, jenis_kelamin, tenant_id, password, jenjang, nama_sheet, nisn, scan_id, kelas, iuran_bulanan, nama_orang_tua, no_wa, keterangan) VALUES
('ABDULLAH AZZAM', 'Laki-laki', 'tkwahdah01', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', '01 TKIT', 'KELAS B', '3203243088', '3203243088', 'B3', 50000, 'RIANTI', '', ''),
('ABIDA KHAIRIAH K', 'Perempuan', 'tkwahdah01', '$2b$10$EGXynxuIn38fT7br35X7j.RRWJ4nKJGwNT6YDERafS5zSOx5.11vi', '01 TKIT', 'KELAS B', '3205994574', '3205994574', 'B3', 100000, 'RATNA', '', '');

-- Grades table
CREATE TABLE grades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    teacher_id INT,
    subject VARCHAR(100),
    grade_type ENUM('UTS', 'UAS', 'Tugas', 'UH', 'Raport') DEFAULT 'Raport',
    score DECIMAL(5,2),
    semester VARCHAR(20),
    academic_year VARCHAR(20),
    tenant_id VARCHAR(50),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE SET NULL
);

-- Documents table
CREATE TABLE documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT,
    filename VARCHAR(255),
    original_name VARCHAR(255),
    file_path VARCHAR(500),
    file_size INT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tenant_id VARCHAR(50),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE SET NULL
);

-- Sample attendance
INSERT INTO attendance (nama, asal_sekolah, jabatan, tanggal, jam, status, keterangan, sebagai, no_wa, jenis_absen) VALUES
('Akbar Irwansya', 'YPWI LUTIM', 'Admin', '2026-04-10', '10:18:04', 'Datang', 'Tahap 2', 'Guru', '6282396859771', 'Absen');