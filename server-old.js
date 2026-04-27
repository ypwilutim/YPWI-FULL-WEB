// Load environment variables
require('dotenv').config();

const express = require('express');
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const cors = require('cors');
const winston = require('winston');

// Configure logging
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'ypwi-web-app' },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    new winston.transports.File({
      filename: process.env.LOG_FILE || 'logs/app.log',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    })
  ]
});

// Create logs directory if it doesn't exist
const logsDir = path.dirname(process.env.LOG_FILE || 'logs/app.log');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

const app = express();

// Environment configuration
const PORT = process.env.PORT || 3001;
const NODE_ENV = process.env.NODE_ENV || 'development';

// WhatsApp configuration
const WHACENTER_DEVICE_ID = process.env.WHATSAPP_DEVICE_ID || 'mock_device_id';
const WHATSAPP_API_URL = process.env.WHATSAPP_API_URL || 'https://api.whacenter.com/send';

// Middleware
app.use(cors());
app.use((req, res, next) => {
    res.setHeader('Content-Security-Policy', "default-src * 'unsafe-inline' 'unsafe-eval' data: blob:; script-src * 'unsafe-inline' 'unsafe-eval' data: blob:; style-src * 'unsafe-inline' data:; img-src * data: blob:; font-src * data:; connect-src * ws: wss:;");
    res.removeHeader('X-Content-Type-Options');
    res.removeHeader('X-Frame-Options');
    next();
});
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(express.static(__dirname));
app.use('/absensi', express.static(path.join(__dirname, 'absensi')));

// Ignore Chrome DevTools requests to reduce log noise
app.get('/.well-known/appspecific/com.chrome.devtools.json', (req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// API routes - must come BEFORE static file fallback
app.get('/api/all-teachers', (req, res) => {
    logger.debug('[API] /api/all-teachers called');
    db.query('SELECT id, nama, niy, nik, scan_id, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_wa, email, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, link_foto, tenant_id FROM teachers', (err, results) => {
        if (err) {
            logger.error('[API] all-teachers error:', err);
            return res.status(500).json({ error: 'Database error' });
        }
        logger.debug('[API] all-teachers result count:', results.length);
        res.json(results);
    });
});

// Get teacher by ID (for complete-profile)
app.get('/api/teacher-data/:id', (req, res) => {
    console.log('[API] /api/teacher-data called for id:', req.params.id);
    db.query('SELECT * FROM teachers WHERE id = ?', [req.params.id], (err, results) => {
        if (err) {
            console.error('[API] teacher-data error:', err);
            return res.status(500).json({ error: 'DB error' });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Guru tidak ditemukan' });
        }
        res.json(results[0]);
    });
});

// Search users (for admin)
app.get('/api/search-users', authenticateToken, (req, res) => {
    const { query, tenant_id, role } = req.query;

    let sql = `
        SELECT
            'teacher' as type,
            id,
            nama as username,
            email,
            tenant_id,
            jabatan,
            sebagai,
            status_aktif,
            NULL as role
        FROM teachers
        WHERE 1=1
    `;

    const params = [];

    if (query) {
        sql += ` AND (LOWER(nama) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) OR LOWER(niy) LIKE LOWER(?))`;
        params.push(`%${query}%`, `%${query}%`, `%${query}%`);
    }

    if (tenant_id) {
        sql += ` AND tenant_id = ?`;
        params.push(tenant_id);
    }

    sql += `
        UNION ALL
        SELECT
            'user' as type,
            id,
            username,
            '' as email,
            tenant_id,
            '' as jabatan,
            '' as sebagai,
            'Aktif' as status_aktif,
            role
        FROM users
        WHERE 1=1
    `;

    if (query) {
        sql += ` AND LOWER(username) LIKE LOWER(?)`;
        params.push(`%${query}%`);
    }

    if (tenant_id) {
        sql += ` AND tenant_id = ?`;
        params.push(tenant_id);
    }

    if (role) {
        sql += ` AND role = ?`;
        params.push(role);
    }

    sql += ` ORDER BY username LIMIT 50`;

    db.query(sql, params, (err, results) => {
        if (err) {
            console.error('[API] search-users error:', err);
            return res.status(500).json({ error: 'DB error' });
        }
        res.json(results);
    });
});

// Debug route - update password for testing
app.post('/api/update-password', async (req, res) => {
    const { email, newPassword } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        db.query('UPDATE teachers SET password = ? WHERE LOWER(email) = LOWER(?)', [hashedPassword, email], (err, result) => {
            if (err) {
                console.error('Update password error:', err);
                return res.status(500).json({ error: 'DB error' });
            }
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: 'User not found' });
            }
            res.json({ success: true, message: 'Password updated successfully' });
        });
    } catch (error) {
        console.error('Hash password error:', error);
        res.status(500).json({ error: 'Hash error' });
    }
});

app.get('/api/tenants', (req, res) => {
    console.log('[API] /api/tenants called');
    const { code } = req.query;
    let query = 'SELECT * FROM tenants';
    let params = [];
    if (code) {
        query += ' WHERE code = ?';
        params = [code];
    }
    db.query(query, params, (err, results) => {
        if (err) {
            console.log('[API] tenants fallback:', err.message);
            return res.json([
                { id: 1, name: 'YPWI LUWU TIMUR (PUSAT)', code: 'ypwilutim' },
                { id: 2, name: 'TKIT WAHDAH ISLAMIYAH 01 TOMONI', code: 'tkwahdah01' },
                { id: 3, name: 'SDIT WAHDAH ISLAMIYAH 02 TOMONI', code: 'sdwahdah02tomoni' }
            ]);
        }
        res.json(results);
    });
});

// News API endpoints
app.get('/api/news', (req, res) => {
    const { limit, category, tenant } = req.query;
    let query = 'SELECT * FROM news WHERE 1=1';
    const params = [];
    
    if (category) {
        query += ' AND category = ?';
        params.push(category);
    }
    if (tenant) {
        query += ' AND (tenant_id = ? OR tenant_id IS NULL)';
        params.push(tenant);
    }
    
    // Try to order by created_at, fallback to id if column doesn't exist
    query += ' ORDER BY CASE WHEN created_at IS NOT NULL THEN created_at ELSE id END DESC';
    if (limit) query += ' LIMIT ' + parseInt(limit);
    
    db.query(query, params, (err, results) => {
        if (err) {
            console.log('News API error:', err.message);
            return res.json([]);
        }
        res.json(results);
    });
});

app.get('/api/blog', (req, res) => {
    db.query('SELECT * FROM news WHERE category = "blog" ORDER BY created_at DESC LIMIT 10', (err, results) => {
        if (err) return res.json([]);
        res.json(results);
    });
});

app.post('/api/news', (req, res) => {
    const { title, content, category, author, tenant_id, image } = req.body;
    db.query('INSERT INTO news (title, content, category, author, tenant_id, image, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())',
        [title, content, category || 'berita', author, tenant_id, image], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, id: result.insertId });
    });
});

// Root and specific HTML routes
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/progress.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'progress.html'));
});

// After all routes, use static files for any remaining paths
// Remove catch-all to let express.static handle it

// Database configuration
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ypwi_db',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    timezone: '+07:00'
};

const db = mysql.createPool(dbConfig);

logger.info('MySQL pool created with config:', {
    host: dbConfig.host,
    database: dbConfig.database,
    user: dbConfig.user,
    connectionLimit: dbConfig.connectionLimit
});

// Test connection
db.getConnection((err, connection) => {
    if (err) {
        logger.error('DB connection failed:', err);
        if (NODE_ENV === 'development') {
            logger.warn('Make sure to run setup-dev-db.sql first for development setup');
        }
        process.exit(1);
    } else {
        logger.info('Connected to MySQL database successfully');
        connection.release();

        // Schema will be updated manually if needed
        logger.info('Database connection established');
    }
});

// Buat direktori yang diperlukan
const uploadDir = 'uploads';
const docDir = path.join(uploadDir, 'documents');

if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}
if (!fs.existsSync(docDir)) {
    fs.mkdirSync(docDir, { recursive: true });
}

// Multer storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// Middleware to verify JWT
function authenticateToken(req, res, next) {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'No token' });
    jwt.verify(token, 'secret_key', (err, user) => {
        if (err) return res.status(403).json({ error: 'Invalid token' });
        req.user = user;
        next();
    });
}





// Handle connection loss
db.on('error', (err) => {
    console.error('DB connection error:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST') {
        console.log('MySQL pool akan otomatis membuat koneksi baru...');
    }
});

// Routes
app.post('/api/login', async (req, res) => {
    const { username, password, tenant } = req.body;
    console.log('Login attempt:', { username, tenant });

    // If no tenant provided, try to find user in all tenants
    const searchTenant = tenant || 'ypwi_lutim'; // Default to YPWI LUTIM

    // First: Check if user exists in users table across any tenant
    // Or check teachers table - find by username across all tenants
    
    const searchQuery = `
        SELECT * FROM teachers WHERE 
        (LOWER(email) = LOWER(?) OR LOWER(nama) = LOWER(?) OR LOWER(niy) = LOWER(?))
    `;
    
    db.query(searchQuery, [username, username, username], async (err, results) => {
        if (err) {
            console.log('DB error:', err);
            return res.status(500).json({ error: 'DB error' });
        }
        
        // Check if teacher found
        if (results.length > 0) {
            // Found teacher - verify password
            const teacher = results[0];
            console.log('Found teacher:', teacher.nama, 'tenant:', teacher.tenant_id);
            
            // Check if password matches (could be bcrypt or plain)
            let match = false;
            try {
                match = await bcrypt.compare(password, teacher.password);
            } catch(e) {
                // If not bcrypt, try plain comparison
                match = (password === teacher.password);
            }
            
            if (!match) {
                console.log('Password mismatch for teacher:', username);
                return res.status(401).json({ error: 'Username atau password salah' });
            }
            
            // Profile complete check
            const requiredFields = ['nama', 'niy', 'nik', 'jenis_kelamin', 'tempat_lahir', 'tanggal_lahir', 'alamat', 'no_wa', 'email', 'jenjang', 'jabatan', 'sebagai', 'status_kepegawaian', 'tmt', 'status_aktif', 'keterangan', 'link_foto'];
            const isComplete = requiredFields.every(field => {
                const value = teacher[field];
                return value !== null && value !== undefined && value.toString().trim() !== '';
            });
            
            if (!isComplete) {
                console.log('Profile incomplete for teacher:', teacher.nama);
                return res.json({
                    incomplete: true,
                    teacherId: teacher.id,
                    data: {
                        nama: teacher.nama,
                        niy: teacher.niy,
                        nik: teacher.nik,
                        jenis_kelamin: teacher.jenis_kelamin,
                        tempat_lahir: teacher.tempat_lahir,
                        tanggal_lahir: teacher.tanggal_lahir ? teacher.tanggal_lahir.toISOString().split('T')[0] : '',
                        alamat: teacher.alamat,
                        no_wa: teacher.no_wa,
                        email: teacher.email,
                        jenjang: teacher.jenjang,
                        jabatan: teacher.jabatan,
                        sebagai: teacher.sebagai,
                        status_kepegawaian: teacher.status_kepegawaian,
                        tmt: teacher.tmt ? teacher.tmt.toISOString().split('T')[0] : '',
                        status_aktif: teacher.status_aktif,
                        keterangan: teacher.keterangan,
                        link_foto: teacher.link_foto
                    }
                });
            }
            
            // Profile complete - determine role based on JABATAN field (main logic)
            let dynamicRole = 'Guru';
            const jabatanRaw = teacher.jabatan || '';
            // Extract primary jabatan (before first comma) for role determination
            const jabatanPrimary = jabatanRaw.split(',')[0].trim().toLowerCase();
            const tenantId = teacher.tenant_id;

            // Define administrative positions (pusat level)
            const adminPositions = ['admin', 'tu', 'operator', 'staf', 'administrator'];
            const financePositions = ['bendahara', 'keuangan', 'kasir'];
            const leaderPositions = ['pimpinan', 'kepala sekolah', 'kepala', 'ketua', 'direktur', 'ketua yayasan'];

            // Check if primary jabatan is administrative/leadership
            const isAdminPosition = adminPositions.some(pos => jabatanPrimary.includes(pos));
            const isFinancePosition = financePositions.some(pos => jabatanPrimary.includes(pos));
            const isLeaderPosition = leaderPositions.some(pos => jabatanPrimary.includes(pos));

            // Academic positions (default to Guru)
            const academicPositions = ['walikelas', 'mapel', 'mengaji', 'guru', 'pengajar', 'ustad', 'ustadzah'];

            // Debug logging
            console.log('Role determination debug:');
            console.log('- Jabatan raw:', teacher.jabatan);
            console.log('- Jabatan primary:', jabatanPrimary);
            console.log('- isAdminPosition:', isAdminPosition, '(adminPositions:', adminPositions, ')');
            console.log('- isFinancePosition:', isFinancePosition, '(financePositions:', financePositions, ')');
            console.log('- isLeaderPosition:', isLeaderPosition, '(leaderPositions:', leaderPositions, ')');

            if (isLeaderPosition) {
                // All leaders go to Kepala Sekolah dashboard
                // But Ketua with YPWILUTIM tenant gets special view
                dynamicRole = (jabatanPrimary === 'ketua' && tenantId.toLowerCase() === 'ypwilutim') ? 'KetuaYayasan' : 'KepalaSekolah';
            }
            else if (isFinancePosition) {
                // Bendahara positions
                dynamicRole = (tenantId.toLowerCase() === 'ypwilutim') ? 'BendaharaYayasan' : 'BendaharaSekolah';
            }
            else if (isAdminPosition) {
                // Administrative positions
                dynamicRole = (tenantId.toLowerCase() === 'ypwilutim') ? 'AdminYayasan' : 'AdminSekolah';
            }
            else {
                // Default: academic positions or empty = Guru
                dynamicRole = 'Guru';
            }
            
            // Determine accessible units based on role
            let accessibleUnits = [tenantId]; // Always include primary unit

            // Ketua Yayasan and Admin Yayasan can access all units
            if (dynamicRole === 'KetuaYayasan' || dynamicRole === 'AdminYayasan' || dynamicRole === 'PimpinanYayasan') {
                // Get all tenant codes for full access
                const allTenants = await new Promise((resolve, reject) => {
                    db.query('SELECT code FROM tenants', (err, results) => {
                        if (err) reject(err);
                        else resolve(results.map(t => t.code));
                    });
                });
                accessibleUnits = allTenants;
            }
            // Kepala Sekolah can access their unit + related units if any
            else if (dynamicRole === 'KepalaSekolah' && teacher.accessible_units) {
                try {
                    const additionalUnits = JSON.parse(teacher.accessible_units);
                    accessibleUnits = [tenantId, ...additionalUnits];
                } catch (e) {
                    // Invalid JSON, use only primary unit
                }
            }

            console.log('Teacher login - Nama:', teacher.nama, 'Tenant:', tenantId, 'Jabatan:', teacher.jabatan, 'Role:', dynamicRole, 'Accessible Units:', accessibleUnits.length);

            const token = jwt.sign({
                id: teacher.id,
                role: dynamicRole,
                tenant: tenantId,
                accessible_units: accessibleUnits,
                sebagai: teacher.sebagai,
                jabatan: teacher.jabatan
            }, 'secret_key');
            return res.json({
                token,
                role: dynamicRole,
                sebagai: teacher.sebagai,
                jabatan: teacher.jabatan,
                tenant: tenantId,
                accessible_units: accessibleUnits
            });
        }
        
        // Not in teachers - check users table
        const userQuery = tenant ? 
            'SELECT * FROM users WHERE LOWER(username) = LOWER(?) AND tenant_id = ?' :
            'SELECT * FROM users WHERE LOWER(username) = LOWER(?)';
        
        const userParams = tenant ? [username, tenant] : [username];
        
        db.query(userQuery, userParams, async (err, results) => {
            if (err) return res.status(500).json({ error: 'DB error' });
            
            if (results.length > 0) {
                const user = results[0];
                console.log('Found user:', user.username, 'role:', user.role);
                const match = await bcrypt.compare(password, user.password_hash);
                if (!match) {
                    return res.status(401).json({ error: 'Username atau password salah' });
                }
                
                const token = jwt.sign({ id: user.id, role: user.role, tenant: user.tenant_id }, 'secret_key');
                return res.json({ token, role: user.role, tenant: user.tenant_id });
            }
            
            // Not found in users either - try students
            db.query('SELECT * FROM students WHERE LOWER(nama_siswa) = LOWER(?)', [username], async (err, results) => {
                if (err) return res.status(500).json({ error: 'DB error' });
                if (results.length === 0) {
                    return res.status(401).json({ error: 'Username atau password salah' });
                }
                
                const user = results[0];
                let match = false;
                try {
                    match = await bcrypt.compare(password, user.password);
                } catch(e) {
                    match = (password === user.password);
                }
                
                if (!match) {
                    return res.status(401).json({ error: 'Username atau password salah' });
                }
                
                const token = jwt.sign({ id: user.id, role: 'Siswa', tenant: user.tenant_id }, 'secret_key');
                res.json({ token, role: 'Siswa', tenant: user.tenant_id });
            });
        });
    });
});

// Complete profile route - simplified
app.post('/complete-profile', upload.single('foto'), (req, res) => {
    console.log('Complete profile request for teacherId:', req.body.teacherId);

    const { teacherId, nama, niy, nik, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_wa, email, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, terima_notifikasi } = req.body;

    // Validate
    if (!teacherId || teacherId === 'undefined') {
        return res.status(400).json({ success: false, message: 'ID Guru tidak valid' });
    }

    const teacherIdNum = parseInt(teacherId);
    if (isNaN(teacherIdNum)) {
        return res.status(400).json({ success: false, message: 'ID Guru harus berupa angka' });
    }

    // Handle file upload
    let link_foto = null;
    if (req.file) {
        const ext = path.extname(req.file.originalname);
        const cleanNama = nama.replace(/[^a-zA-Z0-9\s]/g, '').replace(/\s+/g, '_').toUpperCase();
        const newFileName = `FOTO_${cleanNama}${ext}`;

        try {
            fs.renameSync(req.file.path, path.join('uploads', newFileName));
            link_foto = newFileName;
        } catch (err) {
            return res.status(500).json({ success: false, message: 'Error saving file' });
        }
    }

    // Normalize phone
    let normalized_no_wa = no_wa;
    if (no_wa && no_wa.startsWith('08')) {
        normalized_no_wa = '62' + no_wa.slice(1);
    }

    // Update query
    const updateQuery = `
        UPDATE teachers SET
        nama = ?, niy = ?, nik = ?, jenis_kelamin = ?, tempat_lahir = ?, tanggal_lahir = ?,
        alamat = ?, no_wa = ?, email = ?, jenjang = ?, jabatan = ?, sebagai = ?,
        status_kepegawaian = ?, tmt = ?, status_aktif = ?, keterangan = ?, link_foto = ?,
        terima_notifikasi = ?
        WHERE id = ?
    `;

    const params = [
        nama, niy, nik, jenis_kelamin, tempat_lahir, tanggal_lahir,
        alamat, normalized_no_wa, email, jenjang, jabatan, sebagai,
        status_kepegawaian, tmt, status_aktif, keterangan, link_foto,
        terima_notifikasi === '1' ? 1 : 0, teacherIdNum
    ];

    db.query(updateQuery, params, (err, result) => {
        if (err) {
            console.log('Update error:', err);
            return res.status(500).json({ success: false, message: 'Database error: ' + err.message });
        }

        // Check completion
        db.query('SELECT * FROM teachers WHERE id = ?', [teacherIdNum], (checkErr, rows) => {
            if (checkErr) {
                return res.status(500).json({ success: false, message: 'Database check error' });
            }

            const teacher = rows[0];
            const requiredFields = ['nama', 'niy', 'nik', 'jenis_kelamin', 'tempat_lahir', 'tanggal_lahir', 'alamat', 'no_wa', 'email', 'jenjang', 'jabatan', 'sebagai', 'status_kepegawaian', 'tmt', 'status_aktif', 'keterangan', 'link_foto'];

            const isComplete = requiredFields.every(field => {
                const value = teacher[field];
                return value !== null && value !== undefined && value.toString().trim() !== '';
            });

            if (!isComplete) {
                return res.json({ success: false, message: 'Data belum lengkap. Isi semua field yang diperlukan.' });
            }

            const token = jwt.sign({ id: teacherIdNum, role: 'Guru', tenant: teacher.tenant_id }, 'secret_key');
            res.json({ success: true, token });
        });
    });
});

app.get('/api/test-db', (req, res) => {
                const hasAccessibleUnits = columnNames.includes('accessible_units');
                const hasJabatanTambahan = columnNames.includes('jabatan_tambahan');

                // Build dynamic SET clause
                let setClause = `nama = ?, niy = ?, nik = ?, jenis_kelamin = ?, tempat_lahir = ?, tanggal_lahir = ?,
                                alamat = ?, no_wa = ?, email = ?, jenjang = ?, jabatan = ?, sebagai = ?,
                                status_kepegawaian = ?, tmt = ?, status_aktif = ?, keterangan = ?, link_foto = ?,
                                terima_notifikasi = ?`;
                const params = [nama, niy, nik, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, normalized_no_wa, email, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, link_foto, terima_notifikasi === '1' || terima_notifikasi === true ? 1 : 0];

                if (hasAccessibleUnits) {
                    setClause += ', accessible_units = ?';
                    params.push(accessible_units || null);
                }

                if (hasJabatanTambahan) {
                    setClause += ', jabatan_tambahan = ?';
                    params.push(jabatan_tambahan || null);
                }

                params.push(teacherIdNum); // WHERE clause parameter

                const updateQuery = `UPDATE teachers SET ${setClause} WHERE id = ?`;

                console.log('Updating teacher:', teacherId, 'with link_foto:', link_foto);
                console.log('Update query:', updateQuery);
                console.log('Update params:', params);

                db.query(updateQuery, params, (err, result) => {
                if (err) {
                    console.log('Update error:', err);
                    return res.status(500).json({ success: false, message: 'Database error: ' + err.message });
                }
                // Check if now complete
                const checkQuery = 'SELECT * FROM teachers WHERE id = ?';
                db.query(checkQuery, [teacherIdNum], (err, rows) => {
                    if (err) return res.status(500).json({ success: false, message: 'Database error: ' + err.message });
                    const teacher = rows[0];
                    console.log('Checking completeness for teacher', teacherId, teacher);
                    const requiredFields = ['nama', 'niy', 'nik', 'jenis_kelamin', 'tempat_lahir', 'tanggal_lahir', 'alamat', 'no_wa', 'email', 'jenjang', 'jabatan', 'sebagai', 'status_kepegawaian', 'tmt', 'status_aktif', 'keterangan', 'link_foto'];
                    const isComplete = requiredFields.every(field => {
                        const value = teacher[field];
                        const isValid = value !== null && value !== undefined && value.toString().trim() !== '';
                        if (!isValid) console.log('Field empty:', field, value);
                        return isValid;
                    });
                    if (!isComplete) {
                        return res.json({ success: false, message: 'Data belum lengkap. Isi semua field yang diperlukan sebelum melanjutkan.' });
                    }
                    const token = jwt.sign({ id: teacherIdNum, role: 'Guru', tenant: teacher.tenant_id }, 'secret_key');
                    res.json({ success: true, token });
                });
            });
        });
});

app.get('/api/test-db', (req, res) => {
    db.query('SELECT COUNT(*) as count FROM tenants', (err, result) => {
        if (err) return res.status(500).json({ error: 'DB connection failed', details: err.message });
        res.json({ message: 'DB connected', tenants_count: result[0].count });
    });
});

// WhatsApp API endpoint for frontend
app.post('/api/whatsapp-send', (req, res) => {
    const { number, message } = req.body;

    if (!number || !message) {
        return res.status(400).json({ error: 'Number and message required' });
    }

    // Use mock response for development
    if (NODE_ENV === 'development' || WHACENTER_DEVICE_ID === 'mock_device_id') {
        logger.info(`📱 [MOCK] Would send WhatsApp to ${number}: ${message.substring(0, 50)}...`);
        return res.json({
            status: 'success',
            code: '200',
            message: 'Message sent successfully (mock mode)',
            mock: true
        });
    }

    // Real WhatsApp API call
    const recipientParams = new URLSearchParams();
    recipientParams.append('device_id', WHACENTER_DEVICE_ID);
    recipientParams.append('number', number);
    recipientParams.append('message', message);

    fetch(WHATSAPP_API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: recipientParams,
        signal: AbortSignal.timeout(10000)
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === true) {
            logger.info(`📱 WhatsApp sent successfully to ${number}`);
            res.json({ status: 'success', code: '200', message: 'Message sent successfully' });
        } else {
            logger.warn(`📱 WhatsApp failed to ${number}:`, data.message);
            res.status(500).json({ error: 'Failed to send message', details: data.message });
        }
    })
    .catch(err => {
        logger.error(`📱 WhatsApp error to ${number}:`, err.message);
        res.status(500).json({ error: 'WhatsApp service error', details: err.message });
    });
});

app.get('/api/dashboard', authenticateToken, (req, res) => {
    // Placeholder for dashboard data per tenant
    res.json({ message: 'Dashboard data for tenant: ' + req.user.tenant });
});

app.get('/api/students', authenticateToken, (req, res) => {
    db.query('SELECT * FROM students WHERE tenant_id = ?', [req.user.tenant], (err, results) => {
        if (err) return res.status(500).json({ error: 'DB error' });
        res.json(results);
    });
});

app.get('/api/teacher-profile', authenticateToken, (req, res) => {
    const teacherId = req.user.id;
    db.query('SELECT id, nama, niy, nik, email, no_wa, jenjang, jabatan, sebagai, tenant_id, link_foto, points FROM teachers WHERE id = ?', [teacherId], (err, results) => {
        if (err) return res.status(500).json({ error: 'DB error' });
        if (results.length === 0) return res.status(404).json({ error: 'Teacher not found' });
        res.json(results[0]);
    });
});

app.get('/api/all-teachers', (req, res) => {
    console.log('API called: /api/all-teachers');
    db.query('SELECT id, nama, niy, nik, scan_id, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_wa, email, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, link_foto, tenant_id FROM teachers', (err, results) => {
        if (err) {
            console.error('all-teachers error:', err);
            return res.status(500).json({ error: 'DB error' });
        }
        console.log('all-teachers result count:', results.length);
        res.json(results);
    });
});

app.get('/api/tenants', (req, res) => {
    console.log('Fetching tenants...');
    const { code } = req.query;
    
    let query = 'SELECT * FROM tenants';
    let params = [];
    
    if (code) {
        query += ' WHERE code = ?';
        params = [code];
    }
    
    db.query(query, params, (err, results) => {
        if (err) {
            console.log('DB error in tenants:', err);
            return res.json([
                { id: 1, name: 'TKIT WAHDAH ISLAMIYAH 01 TOMONI', code: 'tkwahdah01' },
                { id: 2, name: 'SDIT WAHDAH ISLAMIYAH 02 TOMONI', code: 'sdwahdah02tomoni' }
            ]);
        }
        console.log('Tenants fetched:', results.length);
        res.json(results);
    });
});

app.get('/api/tenants/:id', (req, res) => {
    const tenantId = req.params.id;
    console.log('Fetching tenant by ID:', tenantId);
    
    // Try multiple approaches to find the tenant
    const isNumeric = /^\d+$/.test(tenantId);
    
    // First try: exact match on code (case-insensitive)
    db.query('SELECT * FROM tenants WHERE LOWER(code) = LOWER(?)', [tenantId], (err, results) => {
        if (err) {
            console.log('DB error in tenant:', err);
            return res.json({ id: tenantId, name: 'Unit: ' + tenantId });
        }
        
        if (results.length > 0) {
            console.log('Found tenant by code:', results[0].name);
            return res.json(results[0]);
        }
        
        // Second try: search by name containing the ID
        db.query('SELECT * FROM tenants WHERE name LIKE ?', ['%' + tenantId + '%'], (err, results) => {
            if (err) {
                return res.json({ id: tenantId, name: 'Unit: ' + tenantId });
            }
            
            if (results.length > 0) {
                console.log('Found tenant by name:', results[0].name);
                return res.json(results[0]);
            }
            
            // Not found - return fallback
            console.log('Tenant not found for ID:', tenantId);
            return res.json({ id: tenantId, name: 'Unit: ' + tenantId });
        });
    });
});

app.get('/api/attendance-rules', authenticateToken, (req, res) => {
    const { tenant_id, type } = req.query;
    
    let query = 'SELECT * FROM attendance_rules WHERE 1=1';
    let params = [];
    
    if (req.user.role !== 'Admin Yayasan') {
        query += ' AND (tenant_id = ? OR tenant_id = "SYSTEM")';
        params.push(req.user.tenant);
    } else if (tenant_id) {
        query += ' AND (tenant_id = ? OR tenant_id = "SYSTEM")';
        params.push(tenant_id);
    }
    
    if (type) {
        query += ' AND type = ?';
        params.push(type);
    }
    
    query += ' ORDER BY FIELD(tenant_id, "SYSTEM"), type, waktu_mulai';
    
    db.query(query, params, (err, results) => {
        if (err) {
            console.log('Error fetching attendance rules:', err);
            return res.status(500).json({ error: 'Database error' });
        }
        res.json(results);
    });
});

app.post('/api/attendance-rules', authenticateToken, (req, res) => {
    const { tenant_id, type, waktu_mulai, waktu_akhir, keterangan } = req.body;
    
    if (!tenant_id || !type || !waktu_mulai || !waktu_akhir || !keterangan) {
        return res.status(400).json({ error: 'All fields required' });
    }
    
    if (req.user.role !== 'Admin Yayasan' && tenant_id !== req.user.tenant && tenant_id !== 'SYSTEM') {
        return res.status(403).json({ error: 'Unauthorized' });
    }
    
    db.query('INSERT INTO attendance_rules (tenant_id, type, waktu_mulai, waktu_akhir, keterangan) VALUES (?, ?, ?, ?, ?)',
        [tenant_id, type, waktu_mulai, waktu_akhir, keterangan], (err, result) => {
            if (err) {
                console.log('Error adding rule:', err);
                return res.status(500).json({ error: 'Database error' });
            }
            res.json({ success: true, id: result.insertId });
        });
});

app.delete('/api/attendance-rules/:id', authenticateToken, (req, res) => {
    if (req.user.role !== 'Admin Yayasan') {
        return res.status(403).json({ error: 'Unauthorized' });
    }
    
    db.query('DELETE FROM attendance_rules WHERE id = ?', [req.params.id], (err, result) => {
        if (err) {
            console.log('Error deleting rule:', err);
            return res.status(500).json({ error: 'Database error' });
        }
        res.json({ success: true });
    });
});

// Laporan Absensi - Rekap per bulan
app.get('/api/attendance-report', authenticateToken, (req, res) => {
    const { bulan, tahun, tenant_id } = req.query;
    
    const startDate = `${tahun}-${bulan}-01`;
    const endDate = `${tahun}-${bulan}-31`;
    
    let query = `
        SELECT 
            DATE(tanggal) as tanggal,
            COUNT(*) as total,
            SUM(CASE WHEN status = 'Datang' THEN 1 ELSE 0 END) as datang,
            SUM(CASE WHEN status = 'Pulang' THEN 1 ELSE 0 END) as pulang
        FROM attendance 
        WHERE tanggal BETWEEN ? AND ?
    `;
    const params = [startDate, endDate];
    
    if (req.user.role !== 'Admin Yayasan' && req.user.role !== 'Pimpinan') {
        query += ' AND asal_sekolah = ?';
        params.push(req.user.tenant);
    } else if (tenant_id && tenant_id !== 'all') {
        query += ' AND asal_sekolah = ?';
        params.push(tenant_id);
    }
    
    query += ' GROUP BY DATE(tanggal) ORDER BY tanggal';
    
    db.query(query, params, (err, results) => {
        if (err) return res.json([]);
        res.json(results);
    });
});

// Laporan Absensi per Guru/Siswa
app.get('/api/attendance-detail', authenticateToken, (req, res) => {
    const { bulan, tahun, unit, type } = req.query;
    
    const startDate = `${tahun}-${bulan}-01`;
    const endDate = `${tahun}-${bulan}-31`;
    
    let query = `
        SELECT nama, asal_sekolah, jabatan, tanggal, jam, status, keterangan, jenis_absen
        FROM attendance 
        WHERE tanggal BETWEEN ? AND ?
    `;
    const params = [startDate, endDate];
    
    if (unit && unit !== 'all') {
        query += ' AND asal_sekolah = ?';
        params.push(unit);
    }
    
    if (type === 'guru') {
        query += ' AND (jabatan IS NOT NULL AND jabatan != "")';
    } else if (type === 'siswa') {
        query += ' AND (jabatan IS NULL OR jabatan = "")';
    }
    
    query += ' ORDER BY tanggal DESC, jam DESC';
    
    db.query(query, params, (err, results) => {
        if (err) return res.json([]);
        res.json(results);
    });
});

// Ranking Absensi (Si Gesit & Si Santuy)
app.get('/api/attendance-ranking', authenticateToken, (req, res) => {
    const { bulan, tahun, tenant_id } = req.query;
    
    const startDate = `${tahun}-${bulan}-01`;
    const endDate = `${tahun}-${bulan}-31`;
    
    let query = `
        SELECT 
            nama,
            asal_sekolah,
            COUNT(*) as total_hadir,
            SUM(CASE WHEN TIME(jam) <= '07:00:00' THEN 1 ELSE 0 END) as tepat_waktu,
            SUM(CASE WHEN TIME(jam) > '07:00:00' THEN 1 ELSE 0 END) as terlambat
        FROM attendance 
        WHERE tanggal BETWEEN ? AND ? AND status = 'Datang'
    `;
    const params = [startDate, endDate];
    
    if (req.user.role !== 'Admin Yayasan' && req.user.role !== 'Pimpinan') {
        query += ' AND asal_sekolah = ?';
        params.push(req.user.tenant);
    } else if (tenant_id && tenant_id !== 'all') {
        query += ' AND asal_sekolah = ?';
        params.push(tenant_id);
    }
    
    query += ' GROUP BY nama, asal_sekolah ORDER BY tepat_waktu DESC LIMIT 20';
    
    db.query(query, params, (err, results) => {
        if (err) return res.json([]);
        res.json(results);
    });
});

// Manual Input Absensi (Admin)
app.post('/api/attendance-manual', authenticateToken, (req, res) => {
    const { nama, asal_sekolah, tanggal, jam, status, keterangan } = req.body;
    
    db.query(`
        INSERT INTO attendance (nama, asal_sekolah, tanggal, jam, status, keterangan, jenis_absen)
        VALUES (?, ?, ?, ?, ?, ?, 'manual')
    `, [nama, asal_sekolah, tanggal, jam || '08:00:00', status || 'Datang', keterangan || 'Manual Input'], 
    (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, id: result.insertId });
    });
});

// Verify device for registration
app.post('/api/verify-device', (req, res) => {
    const { device_id, device_name, device_location, tenant_id } = req.body;
    
    if (!device_id) {
        return res.status(400).json({ error: 'device_id required' });
    }
    
    db.query('SELECT * FROM attendance_devices WHERE device_id = ?', [device_id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        
        if (results.length > 0) {
            const device = results[0];
            if (device_name || device_location) {
                db.query('UPDATE attendance_devices SET device_name = COALESCE(?, device_name), device_location = COALESCE(?, device_location), tenant_id = COALESCE(?, tenant_id), status = "active" WHERE device_id = ?',
                    [device_name, device_location, tenant_id, device_id], (err2) => {
                    if (err2) return res.status(500).json({ error: 'Update error' });
                    res.json({ verified: true, status: 'active', device: { name: device_name || device.device_name, location: device_location || device.device_location, tenant_id: tenant_id || device.tenant_id } });
                });
            } else {
                res.json({ verified: device.status === 'active', status: device.status, device: { name: device.device_name, location: device.device_location, tenant_id: device.tenant_id }, message: device.status === 'active' ? 'Device verified' : 'Device is ' + device.status });
            }
        } else {
            db.query('INSERT INTO attendance_devices (device_id, device_name, device_location, tenant_id, status) VALUES (?, ?, ?, ?, ?)',
                [device_id, device_name || 'Unknown', device_location || 'Unknown', tenant_id || 'YPWILUTIM', 'active'], (err2) => {
                if (err2) return res.status(500).json({ error: 'Insert error' });
                res.json({ verified: true, status: 'active', message: 'Device registered successfully' });
            });
        }
    });
});

// CRUD Teachers - Add
app.post('/api/teachers', authenticateToken, (req, res) => {
    const { nama, niy, nik, tenant_id, jabatan, sebagai, no_wa, email, alamat } = req.body;
    
    if (!nama || !tenant_id) {
        return res.status(400).json({ error: 'Nama dan Unit wajib diisi' });
    }
    
    db.query(`
        INSERT INTO teachers (nama, niy, nik, tenant_id, jabatan, sebagai, no_wa, email, alamat, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `, [nama, niy, nik, tenant_id, jabatan, sebagai || 'Guru', no_wa, email, alamat], (err, result) => {
        if (err) {
            console.log('Error insert teacher:', err);
            return res.status(500).json({ error: err.message });
        }
        res.json({ success: true, id: result.insertId });
    });
});

// CRUD Teachers - Update
app.put('/api/teachers/:id', authenticateToken, (req, res) => {
    const { nama, niy, nik, tenant_id, jabatan, sebagai, no_wa, email, alamat } = req.body;
    
    db.query(`
        UPDATE teachers SET nama = ?, niy = ?, nik = ?, tenant_id = ?, jabatan = ?, sebagai = ?, no_wa = ?, email = ?, alamat = ?
        WHERE id = ?
    `, [nama, niy, nik, tenant_id, jabatan, sebagai, no_wa, email, alamat, req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

// CRUD Teachers - Delete
app.delete('/api/teachers/:id', authenticateToken, (req, res) => {
    db.query('DELETE FROM teachers WHERE id = ?', [req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

// Attendance Request (Izin/Sakit) - Submit
app.post('/api/attendance-request', authenticateToken, (req, res) => {
    const { alasan, tanggal_mulai, tanggal_akhir, jenis, keterangan } = req.body;
    const guruId = req.user.id;
    const tenantId = req.user.tenant;
    
    if (!alasan || !tanggal_mulai || !tanggal_akhir || !jenis) {
        return res.status(400).json({ error: 'Data tidak lengkap' });
    }
    
    db.query('SELECT nama FROM teachers WHERE id = ?', [guruId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ error: 'Guru tidak ditemukan' });
        
        const namaGuru = results[0].nama;
        
        db.query(`
            INSERT INTO attendance_requests (guru_id, nama, tenant_id, alasan, jenis, tanggal_mulai, tanggal_akhir, status, catatan)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?)
        `, [guruId, namaGuru, tenantId, alasan, jenis, tanggal_mulai, tanggal_akhir, keterangan || ''], 
        (err2, result) => {
            if (err2) return res.status(500).json({ error: err2.message });
            res.json({ success: true, id: result.insertId });
        });
    });
});

// Attendance Request - Get list (for guru)
app.get('/api/attendance-requests', authenticateToken, (req, res) => {
    const guruId = req.user.id;
    
    db.query(`
        SELECT * FROM attendance_requests 
        WHERE guru_id = ? 
        ORDER BY created_at DESC
    `, [guruId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Attendance Request - Get all (for admin/pimpinan)
app.get('/api/all-attendance-requests', authenticateToken, (req, res) => {
    const { status, tenant_id } = req.query;
    let query = 'SELECT * FROM attendance_requests WHERE 1=1';
    const params = [];
    
    if (status) {
        query += ' AND status = ?';
        params.push(status);
    }
    if (tenant_id) {
        query += ' AND tenant_id = ?';
        params.push(tenant_id);
    }
    
    query += ' ORDER BY created_at DESC';
    
    db.query(query, params, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Attendance Request - Approve/Reject (for admin/pimpinan)
app.put('/api/attendance-request/:id', authenticateToken, (req, res) => {
    const { status, catatan } = req.body;
    
    if (!status || !['approved', 'rejected'].includes(status)) {
        return res.status(400).json({ error: 'Status tidak valid' });
    }
    
    db.query(`
        UPDATE attendance_requests SET status = ?, catatan = ? WHERE id = ?
    `, [status, catatan || '', req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

// Helper function to get attendance rules and determine keterangannya
function getAttendanceKeterangan(tenantId, type, jam) {
    return new Promise((resolve, reject) => {
        db.query('SELECT waktu_mulai, waktu_akhir, keterangan FROM attendance_rules WHERE (tenant_id = ? OR tenant_id = "SYSTEM") AND type = ? ORDER BY FIELD(tenant_id, ?, "SYSTEM"), waktu_mulai', 
            [tenantId, type, tenantId], (err, rules) => {
            if (err) return reject(err);
            if (rules.length === 0) return resolve('Normal');
            
            for (let rule of rules) {
                if (rule.waktu_mulai <= jam && jam <= rule.waktu_akhir) {
                    return resolve(rule.keterangan);
                }
            }
            resolve('Normal');
        });
    });
}

// Standalone Attendance API - for QR Scanner (no authentication required)
app.post('/api/standalone-attendance', (req, res) => {
    const { scan_id, tenant_code, device_id } = req.body;
    
    if (!scan_id || !tenant_code || !device_id) {
        return res.status(400).json({ error: 'scan_id, tenant_code, and device_id required' });
    }
    
    const currentDate = new Date().toISOString().split('T')[0];
    const currentTime = new Date().toTimeString().split(' ')[0];
    
    console.log('Standalone attendance scan:', { scan_id, tenant_code, device_id, date: currentDate, time: currentTime });
    
    // First verify device
    db.query('SELECT * FROM attendance_devices WHERE device_id = ? AND status = "active" AND tenant_id = ?', [device_id, tenant_code], (err, deviceResults) => {
        if (err) {
            console.log('Error verifying device:', err);
            return res.status(500).json({ error: 'Database error: ' + err.message });
        }
        
        if (deviceResults.length === 0) {
            return res.status(403).json({
                success: false,
                error: 'Device tidak terdaftar atau tidak aktif untuk unit sekolah ini'
            });
        }
        
        // Check if scan_id is student
        db.query('SELECT id, nama_siswa AS name, jenjang AS jabatan, nama_orang_tua AS sebagai, no_wa, tenant_id AS home_tenant FROM students WHERE scan_id = ?', [scan_id], async (err, results) => {
            if (err) {
                console.log('DB error checking student:', err);
                return res.status(500).json({ error: 'Database error checking student: ' + err.message });
            }
            
            if (results.length > 0) {
                const user = results[0];
                console.log('Found student:', user.name, 'Home tenant:', user.home_tenant, 'Current tenant:', tenant_code);
                
                // Check existing attendance for this user today at current tenant
                db.query('SELECT id, status FROM attendance WHERE scan_id = ? AND tanggal = ? AND asal_sekolah = ?', [scan_id, currentDate, tenant_code], async (err, existing) => {
                    if (err) {
                        console.log('Error checking existing attendance:', err);
                        return res.status(500).json({ error: 'Database error checking attendance' });
                    }
                    
                    const hasDatang = existing.some(e => e.status === 'Datang' && e.tanggal === currentDate);
                    const hasPulang = existing.some(e => e.status === 'Pulang' && e.tanggal === currentDate);
                    
                    let newStatus, keterangannya;
                    
                    // Check if already has Datang status - check 5 minute cooldown
                    if (hasDatang) {
                        const lastDatang = existing.find(e => e.status === 'Datang');
                        const lastTime = new Date(lastDatang.jam);
                        const now = new Date();
                        const diffMinutes = (now - lastTime) / 1000 / 60;
                        
                        if (!hasPulang && diffMinutes < 5) {
                            return res.status(400).json({ 
                                success: false, 
                                error: 'Anda sudah Datang. Tunggu 5 menit untuk absen Pulang.' 
                            });
                        }
                    }
                    
                    // For students, always use normal logic (no Dinas Luar for different tenant)
                    if (hasDatang && hasPulang) {
                        return res.status(400).json({ 
                            success: false, 
                            error: 'Anda sudah absen lengkap hari ini (Datang & Pulang). Absen hanya bisa esok hari lagi.' 
                        });
                    }
                    newStatus = hasDatang ? 'Pulang' : 'Datang';
                    keterangannya = await getAttendanceKeterangan(tenant_code, newStatus, currentTime);
                    
                    db.query('INSERT INTO attendance (nama, asal_sekolah, jabatan, status, keterangan, sebagai, no_wa, jenis_absen, tanggal, jam, scan_id, device_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [user.name, tenant_code, user.jabatan, newStatus, keterangannya, user.sebagai, user.no_wa, 'Absen', currentDate, currentTime, scan_id, device_id], async (err, result) => {
                        if (err) {
                            console.log('Error inserting student attendance:', err);
                            return res.status(500).json({ error: 'Database error inserting attendance: ' + err.message });
                        }
                        console.log('Student attendance recorded:', user.name, 'Status:', newStatus, 'Keterangan:', keterangannya);
                        
                        // Send WhatsApp notification
                        const whatsapp_sent = await sendAttendanceWhatsApp(user.name, 'siswa', newStatus, keterangannya, tenant_code, user.no_wa);
                        
                        res.json({
                            success: true,
                            message: 'Absensi berhasil dicatat',
                            user: user.name,
                            role: 'siswa',
                            status: newStatus,
                            keterangan: keterangannya,
                            time: currentTime,
                            whatsapp_sent
                        });
                    });
                });
            } else {
                // Check if teacher scan_id
                db.query('SELECT id, nama AS name, jabatan, sebagai, no_wa, tenant_id AS home_tenant, COALESCE(terima_notifikasi, TRUE) as terima_notifikasi FROM teachers WHERE scan_id = ?', [scan_id], async (err, results) => {
                    if (err) {
                        console.log('DB error checking teacher:', err);
                        return res.status(500).json({ error: 'Database error' });
                    }
                    
                    if (results.length === 0) {
                        console.log('User not found for scan_id:', scan_id, 'tenant:', tenant_code);
                        return res.status(404).json({
                            success: false,
                            error: 'ID tidak ditemukan. Pastikan ID dan sekolah sudah benar.'
                        });
                    }
                    
                    const user = results[0];
                    const isDifferentTenant = user.home_tenant && user.home_tenant !== tenant_code;
                    
                    // Check existing attendance for this teacher today at current tenant
                    db.query('SELECT id, status FROM attendance WHERE scan_id = ? AND tanggal = ? AND asal_sekolah = ?', [scan_id, currentDate, tenant_code], async (err, existing) => {
                        if (err) {
                            console.log('Error checking existing attendance:', err);
                            return res.status(500).json({ error: 'Database error checking attendance' });
                        }
                        
                        const hasDatang = existing.some(e => e.status === 'Datang' && e.tanggal === currentDate);
                        const hasPulang = existing.some(e => e.status === 'Pulang' && e.tanggal === currentDate);
                        
                        let newStatus, keterangannya;
                        
                        if (isDifferentTenant) {
                            // Different tenant: check 5 minute cooldown
                            if (hasDatang) {
                                const lastDatang = existing.find(e => e.status === 'Datang');
                                const lastTime = new Date(lastDatang.jam);
                                const now = new Date();
                                const diffMinutes = (now - lastTime) / 1000 / 60;
                                
                                if (!hasPulang && diffMinutes < 5) {
                                    return res.status(400).json({ 
                                        success: false, 
                                        error: 'Anda sudah Datang (Dinas Luar). Tunggu 5 menit untuk absen Pulang.' 
                                    });
                                }
                            }
                            
                            // Different tenant: always Datang first, then Pulang
                            newStatus = (hasDatang && !hasPulang) ? 'Pulang' : 'Datang';
                            keterangannya = 'Dinas Luar';
                        } else {
                            // Same tenant: check 5 minute cooldown
                            if (hasDatang) {
                                const lastDatang = existing.find(e => e.status === 'Datang');
                                const lastTime = new Date(lastDatang.jam);
                                const now = new Date();
                                const diffMinutes = (now - lastTime) / 1000 / 60;
                                
                                if (!hasPulang && diffMinutes < 5) {
                                    return res.status(400).json({ 
                                        success: false, 
                                        error: 'Anda sudah Datang. Tunggu 5 menit untuk absen Pulang.' 
                                    });
                                }
                            }
                            
                            // Same tenant: use normal logic
                            if (hasDatang && hasPulang) {
                                return res.status(400).json({ 
                                    success: false, 
                                    error: 'Anda sudah absen lengkap hari ini (Datang & Pulang). Absen hanya bisa esok hari lagi.' 
                                });
                            }
                            newStatus = hasDatang ? 'Pulang' : 'Datang';
                            keterangannya = await getAttendanceKeterangan(tenant_code, newStatus, currentTime);
                        }
                        
                        db.query('INSERT INTO attendance (nama, asal_sekolah, jabatan, status, keterangan, sebagai, no_wa, jenis_absen, tanggal, jam, scan_id, device_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                            [user.name, tenant_code, user.jabatan, newStatus, keterangannya, user.sebagai, user.no_wa, 'Absen', currentDate, currentTime, scan_id, device_id], async (err, result) => {
                            if (err) {
                                console.log('Error inserting teacher attendance:', err);
                                return res.status(500).json({ error: 'Database error: ' + err.message });
                            }
                            console.log('Teacher attendance recorded:', user.name, 'Status:', newStatus, 'Keterangan:', keterangannya);
                            
                            // Send WhatsApp notification
                            const whatsapp_sent = await sendAttendanceWhatsApp(user.name, 'guru', newStatus, keterangannya, tenant_code, user.no_wa);
                            
                            res.json({
                                success: true,
                                message: 'Absensi berhasil dicatat',
                                user: user.name,
                                role: 'guru',
                                status: newStatus,
                                keterangan: keterangannya,
                                time: currentTime,
                                whatsapp_sent
                            });
                        });
                    });
                });
            }
        });
    });
});

// Send WhatsApp to multiple recipients
async function sendToRecipients(recipients, message, params, device_id) {
    const results = [];

    // Mock mode for development
    if (device_id === 'mock_device_id' || NODE_ENV === 'development') {
        logger.info('📱 [MOCK] Sending WhatsApp messages to:', recipients.length, 'recipients');
        logger.debug('📱 [MOCK] Message:', message.substring(0, 100) + '...');

        for (const recipient of recipients) {
            logger.info(`📱 [MOCK] Would send to ${recipient.number} (${recipient.type}): ✓ Success`);
            results.push({ number: recipient.number, success: true, mock: true });
        }

        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, 500));
        return results;
    }

    // Real WhatsApp API calls
    for (const recipient of recipients) {
        try {
            const recipientParams = new URLSearchParams();
            recipientParams.append('device_id', device_id);
            recipientParams.append('number', recipient.number);
            recipientParams.append('message', message);

            logger.debug(`📱 Sending WhatsApp to ${recipient.number} (${recipient.type})`);

            const response = await fetch(WHATSAPP_API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: recipientParams,
                signal: AbortSignal.timeout(10000)
            });

            const data = await response.json();

            if (data.status === true) {
                logger.info(`📱 WhatsApp sent successfully to ${recipient.number}`);
                results.push({ number: recipient.number, success: true });
            } else {
                logger.warn(`📱 WhatsApp failed to ${recipient.number}:`, data.message || 'Unknown error');
                results.push({ number: recipient.number, success: false, error: data.message });
            }
        } catch (err) {
            logger.error(`📱 Failed to send WhatsApp to ${recipient.number}:`, err.message);
            results.push({ number: recipient.number, success: false, error: err.message });
        }
    }
    return results;
}

// Helper function to send WhatsApp notification for attendance
function sendAttendanceWhatsApp(user, role, status, keterangannya, tenant_code, no_wa_user) {
    return new Promise(async (resolve, reject) => {
        const roleLabel = role === 'siswa' ? 'Siswa' : 'Guru';
        const waktu = new Date().toLocaleString('id-ID');
        
        const message = `📋 *LAPORAN ABSENSI YPWI*

Assalamualaikum wr. wb.

${roleLabel}: *${user}*
Status: *${status}*
Keterangan: *${keterangannya}*
Sekolah: ${tenant_code}
Waktu: ${waktu}

#YPWI-Absensi`;

        const device_id = WHACENTER_DEVICE_ID;
        const params = new URLSearchParams();
        params.append('device_id', device_id);
        
        const recipients = [];
        
        // 1. User who scanned - ALWAYS send
        if (no_wa_user) {
            recipients.push({ number: no_wa_user, type: roleLabel });
        }
        
        // 2. Find leaders based on various title patterns - OPT-IN only
        const leaderPatterns = [
            'Kepala', 'Pimpinan', 'Ketua', 'Directeur', 'Dir',
            'Sekretaris', 'Bendahara', 'Koordinator', 'Supervisor',
            'Manajer', 'Head', 'Lead', 'Penanggung', 'Pembimbing'
        ];
        
        const patternConditions = leaderPatterns.map(p => `jabatan LIKE '%${p}%'`).join(' OR ');
        const sebagaiConditions = `sebagai = 'Pimpin' OR sebagai = 'Pimpinan' OR sebagai = 'Pusat'`;
        
        db.query(`
            SELECT nama, no_wa, jabatan, terima_notifikasi 
            FROM teachers 
            WHERE tenant_id = ? 
            AND ((${patternConditions}) OR (${sebagaiConditions}))
            AND no_wa IS NOT NULL 
            AND no_wa != ''
            AND (terima_notifikasi = 1 OR terima_notifikasi = TRUE)
        `, [tenant_code], (err, leaders) => {
            if (!err && leaders && leaders.length > 0) {
                leaders.forEach(leader => {
                    recipients.push({ 
                        number: leader.no_wa, 
                        type: leader.jabatan || 'Pimpinan' 
                    });
                });
            }
            
            sendToRecipients(recipients, message, params, device_id).then(result => {
                resolve(result);
            });
        });
    });
}

// Get all devices (admin)
app.get('/api/admin-devices', authenticateToken, (req, res) => {
    if (req.user.role !== 'Admin Yayasan') {
        return res.status(403).json({ error: 'Access denied' });
    }
    db.query('SELECT * FROM attendance_devices ORDER BY created_at DESC', (err, results) => {
        if (err) return res.status(500).json({ error: 'DB error' });
        res.json(results);
    });
});

// Get device by ID
app.get('/api/admin-devices/:id', authenticateToken, (req, res) => {
    if (req.user.role !== 'Admin Yayasan') {
        return res.status(403).json({ error: 'Access denied' });
    }
    db.query('SELECT * FROM attendance_devices WHERE id = ?', [req.params.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'DB error' });
        if (results.length === 0) return res.status(404).json({ error: 'Device not found' });
        res.json(results[0]);
    });
});

// Update device status
app.put('/api/admin-devices/:id/status', authenticateToken, (req, res) => {
    if (req.user.role !== 'Admin Yayasan') {
        return res.status(403).json({ error: 'Access denied' });
    }
    const { status } = req.body;
    db.query('UPDATE attendance_devices SET status = ? WHERE id = ?', [status, req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: 'DB error' });
        res.json({ success: true });
    });
});

// Delete device
app.delete('/api/admin-devices/:id', authenticateToken, (req, res) => {
    if (req.user.role !== 'Admin Yayasan') {
        return res.status(403).json({ error: 'Access denied' });
    }
    db.query('DELETE FROM attendance_devices WHERE id = ?', [req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: 'DB error' });
        res.json({ success: true });
    });
});

// Register new device
app.post('/api/admin-devices', authenticateToken, (req, res) => {
    if (req.user.role !== 'Admin Yayasan') {
        return res.status(403).json({ error: 'Access denied' });
    }
    const { device_id, device_name, device_location, tenant_id } = req.body;
    db.query(
        'INSERT INTO attendance_devices (device_id, device_name, device_location, tenant_id, status) VALUES (?, ?, ?, ?, ?)',
        [device_id, device_name, device_location, tenant_id, 'active'],
        (err, result) => {
            if (err) return res.status(500).json({ error: 'DB error' });
            res.json({ success: true, id: result.insertId });
        }
    );
});

// Test WhatsApp API endpoint (original working version)
app.post('/api/test-whatsapp', (req, res) => {
    const { number, message } = req.body;

    if (!number || !message) {
        return res.status(400).json({ error: 'Number and message required' });
    }

    console.log(`🧪 Testing WhatsApp to ${number}`);
    console.log(`📨 Test message: ${message}`);

    // Format x-www-form-urlencoded untuk Whacenter
    const params = new URLSearchParams();
    params.append('device_id', 'dfd86b0797efbb1d79be53e26caf6fdb');
    params.append('number', number);
    params.append('message', message);

    fetch('https://app.whacenter.id/api/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params,
        signal: AbortSignal.timeout(15000)
    })
    .then(response => response.json())
    .then(data => {
        console.log('📡 WhatsApp API response:', data);
        res.json({
            success: true,
            status: data.status || 'unknown',
            message: 'WhatsApp API test completed',
            response: data
        });
    })
    .catch(err => {
        console.error('❌ WhatsApp test error:', err.message);
        res.status(500).json({
            success: false,
            error: err.name === 'TimeoutError' ? 'TIMEOUT' : err.message,
            message: 'WhatsApp API test failed'
        });
    });
});

// Send WhatsApp endpoint (for progress.html reminders)
app.post('/api/send-whatsapp', (req, res) => {
    const { number, message } = req.body;
    
    if (!number || !message) {
        return res.status(400).json({ error: 'Number and message required' });
    }
    
    const params = new URLSearchParams();
    params.append('device_id', 'dfd86b0797efbb1d79be53e26caf6fdb');
    params.append('number', number);
    params.append('message', message);
    
    fetch('https://app.whacenter.id/api/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params,
        signal: AbortSignal.timeout(15000)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success || data.status === true) {
            res.json({ success: true, message: 'WhatsApp sent successfully' });
        } else {
            res.json({ success: false, error: data.message || 'Failed to send' });
        }
    })
    .catch(err => {
        res.json({ success: false, error: err.message });
    });
});

// Debug WhatsApp dengan logging super detail
app.post('/api/debug-whatsapp-full', (req, res) => {
    const { device_id = 'dfd86b0797efbb1d79be53e26caf6fdb', number, message } = req.body;

    console.log('\n🔍 ===== WHATSAPP DEBUG START =====');
    console.log('📱 Request Details:');
    console.log('   Timestamp:', new Date().toISOString());
    console.log('   Device ID:', device_id);
    console.log('   Number:', number);
    console.log('   Message Length:', message.length);
    console.log('   Message Preview:', message.substring(0, 50) + (message.length > 50 ? '...' : ''));

    // Prepare URL-encoded data
    const params = new URLSearchParams();
    params.append('device_id', device_id);
    params.append('number', number);
    params.append('message', message);

    console.log('\n📤 URL-Encoded Payload:');
    console.log('   Raw params:', params.toString());

    console.log('\n🌐 HTTP Request Details:');
    console.log('   URL: https://app.whacenter.id/api/send');
    console.log('   Method: POST');
    console.log('   Content-Type: application/x-www-form-urlencoded');
    console.log('   Content-Length:', params.toString().length);

    fetch('https://app.whacenter.id/api/send', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'YPWI-System/1.0'
        },
        body: params,
        signal: AbortSignal.timeout(30000)
    })
    .then(response => {
        console.log('\n📡 HTTP Response Details:');
        console.log('   Status Code:', response.status);
        console.log('   Status Text:', response.statusText);
        console.log('   Headers:', Object.fromEntries(response.headers.entries()));

        // Try to get response as text first
        return response.text().then(text => {
            console.log('\n📄 Raw Response Text:');
            console.log('   Length:', text.length);
            console.log('   Preview:', text.substring(0, 200) + (text.length > 200 ? '...' : ''));

            // Try to parse as JSON
            try {
                const data = JSON.parse(text);
                console.log('\n📋 Parsed JSON Response:');
                console.log('   Full Data:', JSON.stringify(data, null, 2));

                return {
                    response,
                    data,
                    isJson: true
                };
            } catch (jsonError) {
                console.log('\n⚠️ Response is not valid JSON');
                console.log('   JSON Parse Error:', jsonError.message);

                return {
                    response,
                    data: { raw_text: text },
                    isJson: false
                };
            }
        });
    })
    .then(({ response, data, isJson }) => {
        console.log('\n🎯 Final Analysis:');

        let success = false;
        let analysis = 'Unknown response format';

        if (isJson) {
            if (data.status === true || data.status === 'success') {
                success = true;
                analysis = 'SUCCESS: WhatsApp sent successfully';
            } else if (data.message && data.message.includes('device not connected')) {
                analysis = 'FAILED: Device ID not found in Whacenter';
            } else {
                analysis = `FAILED: ${data.message || 'Unknown error'}`;
            }
        } else {
            analysis = 'FAILED: Invalid response format from server';
        }

        console.log('   Success:', success);
        console.log('   Analysis:', analysis);

        console.log('\n🔍 ===== WHATSAPP DEBUG END =====\n');

        res.json({
            success,
            analysis,
            debug_info: {
                request: {
                    device_id,
                    number,
                    message_length: message.length,
                    timestamp: new Date().toISOString()
                },
                response: {
                    status: response.status,
                    is_json: isJson,
                    data: data
                }
            }
        });
    })
    .catch(err => {
        console.error('\n❌ Network/Fetch Error:');
        console.error('   Error Type:', err.name);
        console.error('   Error Message:', err.message);
        console.log('\n🔍 ===== WHATSAPP DEBUG END =====\n');

        res.status(500).json({
            success: false,
            analysis: `NETWORK ERROR: ${err.name} - ${err.message}`,
            debug_info: {
                request: {
                    device_id,
                    number,
                    message_length: message.length,
                    timestamp: new Date().toISOString()
                },
                error: {
                    name: err.name,
                    message: err.message
                }
            }
        });
    });
});

// Alternative WhatsApp provider function
async function tryAlternativeProvider(phone_number, message, otp) {
    // Example with Fonnte API (uncomment and configure if needed)
    /*
    try {
        const response = await fetch('https://api.fonnte.com/send', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                target: phone_number,
                message: message,
                token: process.env.FONNTE_TOKEN || 'YOUR_FONNTE_TOKEN'
            }),
            signal: AbortSignal.timeout(10000)
        });

        const data = await response.json();
        console.log('📱 Fonnte API response:', data);

        if (data.status === true || data.code === 200) {
            console.log('✅ Alternative WhatsApp OTP sent successfully');
            return true;
        }
    } catch (err) {
        console.error('❌ Alternative WhatsApp API error:', err.message);
    }
    */

    console.log('💡 No alternative provider configured');
    return false;
}

// Error handling middleware
app.use((err, req, res, next) => {
    logger.error('Unhandled error:', err);
    res.status(500).json({
        error: NODE_ENV === 'development' ? err.message : 'Internal server error',
        ...(NODE_ENV === 'development' && { stack: err.stack })
    });
});

// 404 handler
app.use((req, res) => {
    logger.warn(`404 - Route not found: ${req.method} ${req.path}`);
    res.status(404).json({ error: 'Route not found' });
});

// Start server
app.listen(PORT, () => {
    logger.info(`🚀 Server running on port ${PORT} in ${NODE_ENV} mode`);
    logger.info(`📱 WhatsApp API Device ID: ${WHACENTER_DEVICE_ID}`);
    logger.info(`🌐 API URL: ${WHATSAPP_API_URL}`);

    if (WHACENTER_DEVICE_ID === 'mock_device_id') {
        logger.warn('⚠️  WhatsApp Device ID is set to mock mode for development');
        logger.info('💡 To enable WhatsApp notifications:');
        logger.info('   1. Login to https://app.whacenter.com/');
        logger.info('   2. Go to Device menu > Add Device Multidevice');
        logger.info('   3. Scan QR code with your WhatsApp');
        logger.info('   4. Copy Device ID to .env file');
    }

    logger.info('🔧 Alternative: Use Fonnte API if Whacenter unavailable');
    logger.info('📋 Available endpoints:');
    logger.info('   - GET  /api/test-db (Database connection test)');
    logger.info('   - POST /api/login (Authentication)');
    logger.info('   - GET  /api/news (News articles)');
    logger.info('   - GET  /api/blog (Blog posts)');
});