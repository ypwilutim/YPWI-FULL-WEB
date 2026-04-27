-- Setup Database untuk Development
-- Jalankan script ini di MySQL sebagai root user

-- Buat database jika belum ada
CREATE DATABASE IF NOT EXISTS ypwi_db;

-- Buat user khusus untuk development
CREATE USER IF NOT EXISTS 'ypwi_dev'@'localhost' IDENTIFIED BY 'ypwi_dev_password';

-- Berikan privileges untuk development
GRANT ALL PRIVILEGES ON ypwi_db.* TO 'ypwi_dev'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;

-- Gunakan database
USE ypwi_db;