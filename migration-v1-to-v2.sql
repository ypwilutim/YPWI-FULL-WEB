-- =============================================
-- YPWI Database Migration: v1 → v2
-- Purpose: Migrate from dual-table (teachers/students) auth to single-table (users) auth
-- WARNING: Backup database before running!
-- =============================================

-- --------------------------------------------------------
-- 0. Ensure new tables and columns exist
-- --------------------------------------------------------

-- Drop existing 'users' table (old schema) if exists to avoid conflict
DROP TABLE IF EXISTS users;

-- Users table (central authentication)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin','bendahara','ketua','guru','siswa') NOT NULL,
    tenant_id VARCHAR(50) DEFAULT NULL,
    status ENUM('Aktif','Tidak Aktif') DEFAULT 'Aktif',
    last_login_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_tenant_role (tenant_id, role),
    INDEX idx_status (status),
    CONSTRAINT fk_users_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(code) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Classes table (student grouping per school)
CREATE TABLE IF NOT EXISTS classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(50) NOT NULL,
    kode_kelas VARCHAR(50) NOT NULL,
    nama_kelas VARCHAR(100) NOT NULL,
    jenjang VARCHAR(50) NOT NULL,
    kurikulum VARCHAR(100) DEFAULT 'K13',
    wali_kelas_id INT NULL,
    kapasitas_max INT DEFAULT 40,
    academic_year VARCHAR(20) DEFAULT '2024/2025',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_class_per_tenant (tenant_id, kode_kelas, academic_year),
    INDEX idx_class_tenant (tenant_id),
    INDEX idx_class_jenjang (jenjang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Add user_id column to teachers (if not exists)
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS user_id INT UNIQUE NULL AFTER id;
-- Add index for user_id
CREATE INDEX IF NOT EXISTS idx_teachers_user_id ON teachers(user_id);

-- Add user_id and kelas_id columns to students (if not exists)
ALTER TABLE students ADD COLUMN IF NOT EXISTS user_id INT UNIQUE NULL AFTER id;
ALTER TABLE students ADD COLUMN IF NOT EXISTS kelas_id INT NULL AFTER user_id;
CREATE INDEX IF NOT EXISTS idx_students_user_id ON students(user_id);
CREATE INDEX IF NOT EXISTS idx_students_kelas_id ON students(kelas_id);

-- --------------------------------------------------------
-- 1. Migrate Teachers → Users (with role mapping based on jabatan)
-- =============================================================
INSERT INTO users (email, password, role, tenant_id, status, created_at)
SELECT 
    email,
    password,
    CASE 
        -- Ketua / Kepala (priority)
        WHEN LOWER(COALESCE(jabatan, '')) LIKE '%kepala sekolah%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%kepala%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%ketua%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%pimpinan%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%principal%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%direktur%' 
          THEN 'ketua'
        -- Admin / Operator
        WHEN LOWER(COALESCE(jabatan, '')) LIKE '%admin%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%operator%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%administrator%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%tata usaha%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%staff administrasi%' 
          THEN 'admin'
        -- Bendahara / Keuangan
        WHEN LOWER(COALESCE(jabatan, '')) LIKE '%bendahara%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%keuangan%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%finance%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%kasir%' 
          OR LOWER(COALESCE(jabatan, '')) LIKE '%treasurer%' 
          THEN 'bendahara'
        -- Default: Guru
        ELSE 'guru'
    END AS role,
    tenant_id,
    COALESCE(status_aktif, 'Aktif') as status,
    NOW() as created_at
FROM teachers
WHERE email IS NOT NULL 
    AND email != ''
    AND email NOT IN (SELECT email FROM users) -- avoid duplicates
;

-- Step 3: Migrate Students → Users
-- ===================================
INSERT INTO users (email, password, role, tenant_id, status, created_at)
SELECT 
    email,
    password,
    'siswa' as role,
    tenant_id,
    'Aktif' as status,
    created_at
FROM students
WHERE email IS NOT NULL 
    AND email != '' 
    AND email NOT IN (SELECT email FROM users WHERE role = 'siswa')
ON DUPLICATE KEY UPDATE 
    password = VALUES(password),
    role = VALUES(role),
    tenant_id = VALUES(tenant_id),
    status = VALUES(status);

-- Step 4: Create user_id links (Teachers)
-- =========================================
UPDATE teachers t
JOIN users u ON u.email = t.email
SET t.user_id = u.id
WHERE t.user_id IS NULL;

-- Step 5: Create user_id links (Students)
-- =========================================
UPDATE students s
JOIN users u ON u.email = s.email
SET s.user_id = u.id
WHERE s.user_id IS NULL;

-- Step 6: Handle students without email (create fake accounts)
-- =============================================================
-- For students without email, create user with nisn as username
INSERT INTO users (email, password, role, tenant_id, status)
SELECT 
    CONCAT('siswa_', nisn, '@temp.local') as email,
    '$2b$10$LH9FWRjWJrfGdbrC7/XCyuSddmcytB3PYvmHZA7IJRljnngRkzAJ2' as password, -- default hash for "student123"
    'siswa',
    tenant_id,
    'Aktif'
FROM students
WHERE (email IS NULL OR email = '') 
    AND nisn IS NOT NULL 
    AND nisn != ''
    AND user_id IS NULL
ON DUPLICATE KEY UPDATE id=id;

-- Link them back
UPDATE students s
JOIN users u ON u.email = CONCAT('siswa_', s.nisn, '@temp.local')
SET s.user_id = u.id
WHERE s.user_id IS NULL 
    AND (s.email IS NULL OR s.email = '');

-- Step 7: Create default classes for each tenant (if classes table empty)
-- ========================================================================
-- This will create default class "Kelas A" for each tenant that has teachers/students
INSERT INTO classes (tenant_id, kode_kelas, nama_kelas, jenjang, is_active)
SELECT DISTINCT 
    t.tenant_id,
    'KELAS-A' as kode_kelas,
    'Kelas A' as nama_kelas,
    'UMUM' as jenjang,
    TRUE as is_active
FROM teachers t
WHERE t.tenant_id IS NOT NULL
    AND t.tenant_id NOT IN (SELECT tenant_id FROM classes WHERE kode_kelas = 'KELAS-A')
UNION
SELECT DISTINCT 
    s.tenant_id,
    'KELAS-A',
    'Kelas A',
    'UMUM',
    TRUE
FROM students s
WHERE s.tenant_id IS NOT NULL
    AND s.tenant_id NOT IN (SELECT tenant_id FROM classes WHERE kode_kelas = 'KELAS-A');

-- Step 8: Link students to default classes (if kelas_id is NULL)
-- ================================================================
UPDATE students s
JOIN classes c ON s.tenant_id = c.tenant_id AND c.kode_kelas = 'KELAS-A'
SET s.kelas_id = c.id
WHERE s.kelas_id IS NULL;

-- Step 9: Set tenant_id di users (from teachers/students)
-- =======================================================
-- Already set in Step 2 & 3

-- Step 10: Update last_login_at for migrated users (optional)
-- ============================================================
UPDATE users 
SET last_login_at = NOW() 
WHERE last_login_at IS NULL;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Check migration results
SELECT 
    'Users Total' as Metric, 
    COUNT(*) as Count 
FROM users
UNION ALL
SELECT 
    'Guru' as Metric, 
    COUNT(*) as Count 
FROM users WHERE role = 'guru'
UNION ALL
SELECT 
    'Siswa' as Metric, 
    COUNT(*) as Count 
FROM users WHERE role = 'siswa'
UNION ALL
SELECT 
    'Teachers with user_id' as Metric,
    COUNT(*) as Count
FROM teachers WHERE user_id IS NOT NULL
UNION ALL
SELECT 
    'Students with user_id' as Metric,
    COUNT(*) as Count
FROM students WHERE user_id IS NOT NULL
UNION ALL
SELECT 
    'Students with kelas_id' as Metric,
    COUNT(*) as Count
FROM students WHERE kelas_id IS NOT NULL
UNION ALL
SELECT 
    'Total Classes' as Metric,
    COUNT(*) as Count
FROM classes;

-- =============================================
-- FOREIGN KEY CONSTRAINTS
-- =============================================
-- Add foreign keys after data is consistent

ALTER TABLE teachers
ADD CONSTRAINT fk_teachers_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE students
ADD CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_students_kelas FOREIGN KEY (kelas_id) REFERENCES classes(id) ON DELETE SET NULL;

-- =============================================
-- CLEANUP LEGACY DATA (optional, after verification)
-- =============================================
-- Uncomment after confirming migration success:
-- ALTER TABLE teachers DROP COLUMN IF EXISTS email; -- if you want to remove old email
-- ALTER TABLE students DROP COLUMN IF EXISTS email;

-- =============================================
-- TROUBLESHOOTING
-- =============================================
-- If duplicate email errors occur, run:
-- SELECT email, COUNT(*) as cnt FROM teachers GROUP BY email HAVING cnt > 1;
-- SELECT email, COUNT(*) as cnt FROM students GROUP BY email HAVING cnt > 1;
-- Then fix duplicates manually before migration.

-- If students without class remain:
-- SELECT COUNT(*) FROM students WHERE kelas_id IS NULL;
-- Then create more classes or assign default:
