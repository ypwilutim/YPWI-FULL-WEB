-- Tabel untuk dropdown jabatan
CREATE TABLE jabatan_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_jabatan VARCHAR(255) NOT NULL,
    kategori VARCHAR(50) DEFAULT 'umum',
    urutan INT DEFAULT 0,
    aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel untuk dropdown sebagai (role/position type)
CREATE TABLE sebagai_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_sebagai VARCHAR(255) NOT NULL,
    deskripsi TEXT,
    urutan INT DEFAULT 0,
    aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data jabatan
INSERT INTO jabatan_options (nama_jabatan, kategori, urutan) VALUES
('Ketua', 'pimpinan', 1),
('Kepala Sekolah', 'pimpinan', 2),
('Pimpinan', 'pimpinan', 3),
('Walikelas', 'pengajar', 4),
('Mapel', 'pengajar', 5),
('Mengaji', 'pengajar', 6),
('TU', 'administrasi', 7),
('Admin', 'administrasi', 8),
('Operator', 'administrasi', 9),
('Bendahara', 'keuangan', 10),
('Keuangan', 'keuangan', 11),
('Kasir', 'keuangan', 12),
('Lainnya', 'umum', 99);

-- Insert data sebagai
INSERT INTO sebagai_options (nama_sebagai, deskripsi, urutan) VALUES
('Guru', 'Tenaga pengajar/pengajar', 1),
('Siswa', 'Peserta didik', 2),
('Karyawan', 'Tenaga kependidikan non-pengajar', 3),
('Staf', 'Staf administrasi', 4);

-- Update tabel teachers untuk menggunakan foreign key (optional)
-- ALTER TABLE teachers ADD COLUMN jabatan_id INT NULL;
-- ALTER TABLE teachers ADD COLUMN sebagai_id INT NULL;
-- ALTER TABLE teachers ADD CONSTRAINT fk_jabatan FOREIGN KEY (jabatan_id) REFERENCES jabatan_options(id);
-- ALTER TABLE teachers ADD CONSTRAINT fk_sebagai FOREIGN KEY (sebagai_id) REFERENCES sebagai_options(id);