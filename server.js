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
const rateLimit = require('express-rate-limit');
const util = require('util');

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

// Database configuration
const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ypwi_db',
    waitForConnections: true,
    connectionLimit: 10,
    multipleStatements: true, // Allow multiple statements for migration scripts
    queueLimit: 0
});

// Promisify db.query for async/await usage
const dbQuery = util.promisify(db.query).bind(db);

// Test connection and ensure database schema is up to date
db.getConnection((err, connection) => {
    if (err) {
        logger.error('DB connection failed:', err);
        if (NODE_ENV === 'development') {
            logger.warn('Make sure to run setup-dev-db.sql first for development setup');
        }
        process.exit(1);
    } else {
        logger.info('Connected to MySQL database successfully');

        // Ensure attendance_devices table has last_used_at column
        connection.query(`
            ALTER TABLE attendance_devices
            ADD COLUMN IF NOT EXISTS last_used_at TIMESTAMP NULL DEFAULT NULL
        `, (alterErr) => {
            if (alterErr) {
                logger.warn('Could not add last_used_at column to attendance_devices:', alterErr.message);
            } else {
                logger.info('Database schema updated: added last_used_at column to attendance_devices');
            }

            // Add missing indexes after schema check
            addMissingIndexes(connection);
        });
    }
});

// Function to add missing database indexes
function addMissingIndexes(connection) {
    const indexes = [
        { table: 'teachers', name: 'idx_teachers_tenant_id', sql: 'CREATE INDEX idx_teachers_tenant_id ON teachers(tenant_id)' },
        { table: 'teachers', name: 'idx_teachers_email', sql: 'CREATE INDEX idx_teachers_email ON teachers(email)' },
        { table: 'teachers', name: 'idx_teachers_niy', sql: 'CREATE INDEX idx_teachers_niy ON teachers(niy)' },
        { table: 'teachers', name: 'idx_teachers_scan_id', sql: 'CREATE INDEX idx_teachers_scan_id ON teachers(scan_id)' },
        { table: 'students', name: 'idx_students_tenant_id', sql: 'CREATE INDEX idx_students_tenant_id ON students(tenant_id)' },
        { table: 'students', name: 'idx_students_nisn', sql: 'CREATE INDEX idx_students_nisn ON students(nisn)' },
        { table: 'students', name: 'idx_students_scan_id', sql: 'CREATE INDEX idx_students_scan_id ON students(scan_id)' },
        { table: 'students', name: 'idx_students_email', sql: 'CREATE INDEX idx_students_email ON students(email)' },
        { table: 'attendance', name: 'idx_attendance_scan_tanggal', sql: 'CREATE INDEX idx_attendance_scan_tanggal ON attendance(scan_id, tanggal)' },
        { table: 'attendance', name: 'idx_attendance_device_id', sql: 'CREATE INDEX idx_attendance_device_id ON attendance(device_id)' },
        { table: 'attendance', name: 'idx_attendance_tanggal', sql: 'CREATE INDEX idx_attendance_tanggal ON attendance(tanggal)' },
        { table: 'attendance', name: 'idx_attendance_tenant', sql: 'CREATE INDEX idx_attendance_tenant ON attendance(asal_sekolah)' },
        { table: 'attendance_devices', name: 'idx_attendance_devices_device_id', sql: 'CREATE INDEX idx_attendance_devices_device_id ON attendance_devices(device_id)' },
        { table: 'attendance_devices', name: 'idx_attendance_devices_tenant_id', sql: 'CREATE INDEX idx_attendance_devices_tenant_id ON attendance_devices(tenant_id)' },
        { table: 'news', name: 'idx_news_tenant_id', sql: 'CREATE INDEX idx_news_tenant_id ON news(tenant_id)' },
        { table: 'attendance_rules', name: 'idx_attendance_rules_tenant', sql: 'CREATE INDEX idx_attendance_rules_tenant ON attendance_rules(tenant_id)' }
    ];

    let completed = 0;
    const total = indexes.length;
    if (total === 0) {
        logger.info('No indexes to create');
        connection.release();
        return;
    }

    indexes.forEach(index => {
        connection.query(index.sql, (err) => {
            if (err) {
                if (err.code === 'ER_DUP_KEYNAME' || err.errno === 1061) {
                    logger.debug(`Index ${index.name} already exists on ${index.table}`);
                } else {
                    logger.warn(`Failed to create index ${index.name} on ${index.table}: ${err.message}`);
                }
            } else {
                logger.info(`Created index ${index.name} on ${index.table}`);
            }
            completed++;
            if (completed === total) {
                logger.info('Database index migration completed');
                connection.release();
            }
        });
    });
}

// Middleware

// CORS configuration with whitelist
const allowedOrigins = process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000', 'http://localhost:3001', 'http://127.0.0.1:3000'];
const corsOptions = {
    origin: function (origin, callback) {
        // Allow requests with no origin (mobile apps, curl, etc.)
        if (!origin) return callback(null, true);
        if (allowedOrigins.indexOf(origin) !== -1) {
            return callback(null, true);
        }
        callback(new Error('Not allowed by CORS'));
    },
    credentials: true,
    optionsSuccessStatus: 200
};
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting for login endpoint
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 attempts per window
    message: 'Terlalu banyak percobaan login. Coba lagi dalam 15 menit.',
    standardHeaders: true,
    legacyHeaders: false,
    statusCode: 429
});
app.use('/api/login', loginLimiter);

// Static files - only public assets, not dashboard files
app.use(express.static('public'));
app.use('/assets', express.static('assets'));

// Public pages that don't require authentication
app.get('/login.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'login.html'));
});
app.get('/complete-profile.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'complete-profile.html'));
});
app.get('/manifest.json', (req, res) => {
    res.sendFile(path.join(__dirname, 'manifest.json'));
});
app.get('/sw.js', (req, res) => {
    res.sendFile(path.join(__dirname, 'sw.js'));
});
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Dashboard routes - HTML files are public, but API calls require authentication
app.use('/guru', express.static('guru'));
app.use('/siswa', express.static('siswa'));
app.use('/student', express.static('siswa')); // Alias for /siswa
app.use('/admin', express.static('admin'));
app.use('/bendahara', express.static('bendahara'));
app.use('/ketua', express.static('ketua'));
app.use('/yayasan', express.static('yayasan'));
app.use('/berita', express.static('berita'));
app.use('/absensi', express.static('absensi'));

// Absensi route handler - redirect unknown absensi paths to main page
app.get('/absensi/:id', (req, res) => {
    const id = req.params.id;
    // If it's a number or unknown path, redirect to main absensi page
    if (!isNaN(id) || id === '1' || id === '2' || id === '3') {
        console.log(`Redirecting absensi/${id} to absensi.html`);
        res.redirect('/absensi/absensi.html');
    } else {
        // Check if it's a valid file
        const fs = require('fs');
        const path = require('path');
        const filePath = path.join(__dirname, 'absensi', id);

        fs.access(filePath, fs.constants.F_OK, (err) => {
            if (err) {
                // File doesn't exist, redirect to main page
                res.redirect('/absensi/absensi.html');
            } else {
                // File exists, serve it
                res.sendFile(filePath);
            }
        });
    }
});
// Static files with proper MIME types
app.use('/uploads', express.static('uploads', {
    setHeaders: (res, path) => {
        console.log('Serving static file:', path);
        if (path.endsWith('.png')) {
            console.log('Setting Content-Type: image/png for PNG file');
            res.setHeader('Content-Type', 'image/png');
            res.setHeader('Cache-Control', 'no-cache'); // Disable caching for debugging
        } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
            res.setHeader('Content-Type', 'image/jpeg');
        } else if (path.endsWith('.gif')) {
            res.setHeader('Content-Type', 'image/gif');
        }
    }
}));

// File upload configuration with validation
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = process.env.UPLOAD_PATH || 'uploads';
        // Ensure directory exists
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + file.originalname.replace(/\s+/g, '_');
        cb(null, uniqueName);
    }
});

const upload = multer({
    storage,
    limits: {
        fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024 // 10MB default
    },
    fileFilter: (req, file, cb) => {
        // Accept images only
        if (!file.mimetype.startsWith('image/')) {
            return cb(new Error('Only image files are allowed'), false);
        }
        cb(null, true);
    }
});

// Routes

// Root path - serve index.html
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Favicon handler
app.get('/favicon.ico', (req, res) => {
    res.status(204).end(); // No Content
});

// Test DB connection
app.get('/api/test-db', (req, res) => {
    db.query('SELECT COUNT(*) as count FROM teachers', (err, result) => {
        if (err) return res.status(500).json({ error: 'DB connection failed', details: err.message });
        res.json({ message: 'DB connected', teachers_count: result[0].count });
    });
});

// Get all teachers
app.get('/api/all-teachers', authenticateToken, authorizeAPI, (req, res) => {
    const { tenant, limit } = req.query;
    let query = 'SELECT id, nama, niy, nik, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_wa, email, tenant_id, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, link_foto FROM teachers WHERE 1=1';
    const params = [];

    if (tenant) {
        query += ' AND tenant_id = ?';
        params.push(tenant);
    }

    query += ' ORDER BY nama ASC';
    if (limit) {
        query += ' LIMIT ?';
        params.push(parseInt(limit));
    }

    db.query(query, params, (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Login endpoint - Single-table authentication via users
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    // Input validation
    if (!username || !password) {
        return res.status(400).json({ error: 'Email dan password wajib diisi' });
    }
    if (typeof username !== 'string' || typeof password !== 'string') {
        return res.status(400).json({ error: 'Format input tidak valid' });
    }
    if (username.trim().length === 0 || password.trim().length === 0) {
        return res.status(400).json({ error: 'Username dan password tidak boleh kosong' });
    }

    try {
        // 1. Cari user di tabel users (central auth)
        const userResults = await dbQuery('SELECT * FROM users WHERE email = ? AND status = ?', [username, 'Aktif']);
        
        if (userResults.length === 0) {
            return res.status(401).json({ error: 'Email atau password salah' });
        }
        
        const user = userResults[0];
        
        // 2. Verify password
        let match = false;
        if (user.password && user.password.startsWith('$2b$')) {
            match = await bcrypt.compare(password, user.password);
        } else if (user.password) {
            // Legacy plain text (temporary for migration)
            match = (password === user.password);
        }
        
        if (!match) {
            return res.status(401).json({ error: 'Email atau password salah' });
        }
        
        // 3. Load profile data berdasarkan role
        let profile = {};
        let profileId = null;
        
        if (user.role === 'guru') {
            const teacherResults = await dbQuery('SELECT * FROM teachers WHERE user_id = ?', [user.id]);
            if (teacherResults.length > 0) {
                profile = teacherResults[0];
                profileId = teacherResults[0].id;
            }
        } else if (user.role === 'siswa') {
            const studentResults = await dbQuery(`
                SELECT s.*, c.nama_kelas, c.kode_kelas, c.jenjang 
                FROM students s 
                LEFT JOIN classes c ON s.kelas_id = c.id 
                WHERE s.user_id = ?
            `, [user.id]);
            if (studentResults.length > 0) {
                profile = studentResults[0];
                profileId = studentResults[0].id;
            }
        }
        // Admin/Bendahara/Ketua tidak punya profile tambahan
        
        // 4. Update last_login
        await dbQuery('UPDATE users SET last_login_at = NOW() WHERE id = ?', [user.id]);
        
        // 5. Determine route based on role & tenant
        let route;
        let displayRole;
        const userTenant = user.tenant_id;
        const userRole = user.role; // 'admin','bendahara','ketua','guru','siswa'

        if (userRole === 'siswa') {
            route = '/siswa';
            displayRole = 'Siswa';
        } else if (userTenant === 'YPWILUTIM') {
            // Central unit (Yayasan)
            if (userRole === 'admin') {
                route = '/admin/pusat';
                displayRole = 'Admin';
            } else if (userRole === 'bendahara') {
                route = '/bendahara/pusat';
                displayRole = 'Bendahara';
            } else if (userRole === 'ketua') {
                route = '/ketua/pusat';
                displayRole = 'Ketua';
            } else {
                route = '/yayasan';
                displayRole = 'Staf Yayasan';
            }
        } else {
            // School unit (Sekolah)
            if (userRole === 'admin') {
                route = '/admin/sekolah';
                displayRole = 'Admin';
            } else if (userRole === 'bendahara') {
                route = '/bendahara/sekolah';
                displayRole = 'Bendahara';
            } else if (userRole === 'ketua') {
                route = '/ketua/sekolah';
                displayRole = 'Ketua';
            } else {
                route = '/guru';
                displayRole = 'Guru';
            }
        }
        
        // 6. For guru, check profile completeness
        if (user.role === 'guru') {
            const requiredFields = ['nama', 'niy', 'nik', 'jenis_kelamin', 'tempat_lahir', 'tanggal_lahir', 'alamat', 'no_wa', 'email', 'jenjang', 'jabatan', 'sebagai', 'status_kepegawaian', 'tmt', 'status_aktif', 'keterangan'];
            const isComplete = requiredFields.every(field => {
                const value = profile[field];
                return value !== null && value !== undefined && value.toString().trim() !== '';
            });
            
            // link_foto di-check terpisah (optional if already exists)
            const hasPhoto = profile.link_foto && profile.link_foto.trim() !== '';
            const allRequiredExceptPhoto = requiredFields.every(field => {
                if (field === 'link_foto') return true; // skip in loop
                const value = profile[field];
                return value !== null && value !== undefined && value.toString().trim() !== '';
            });
            const isCompleteNoPhoto = allRequiredExceptPhoto && hasPhoto;
            
            if (!isCompleteNoPhoto) {
                return res.json({
                    incomplete: true,
                    teacherId: profile.id,
                    data: {
                        nama: profile.nama || '',
                        niy: profile.niy || '',
                        nik: profile.nik || '',
                        jenis_kelamin: profile.jenis_kelamin || '',
                        tempat_lahir: profile.tempat_lahir || '',
                        tanggal_lahir: profile.tanggal_lahir ? profile.tanggal_lahir.toISOString().split('T')[0] : '',
                        alamat: profile.alamat || '',
                        no_wa: profile.no_wa || '',
                        email: profile.email || '',
                        jenjang: profile.jenjang || '',
                        jabatan: profile.jabatan || '',
                        sebagai: profile.sebagai || '',
                        status_kepegawaian: profile.status_kepegawaian || '',
                        tmt: profile.tmt ? profile.tmt.toISOString().split('T')[0] : '',
                        status_aktif: profile.status_aktif || '',
                        keterangan: profile.keterangan || ''
                    }
                });
            }
        }
        
        // 7. Generate JWT token
        const token = jwt.sign({
            id: user.id,
            role: user.role,
            tenant: user.tenant_id,
            profile_id: profileId
        }, process.env.JWT_SECRET || 'fallback_secret_change_this');
        
        // 8. Build response user object
        const responseUser = {
            id: user.id,
            email: user.email,
            role: user.role,
            tenant_id: user.tenant_id,
            nama: profile.nama || profile.nama_siswa || user.email.split('@')[0],
            ...(user.role === 'guru' && {
                jabatan: profile.jabatan || '',
                sebagai: profile.sebagai || '',
                jenjang: profile.jenjang || '',
                scan_id: profile.scan_id || '',
                no_wa: profile.no_wa || '',
                nip: profile.nip || '',
                nik: profile.nik || ''
            }),
            ...(user.role === 'siswa' && {
                nisn: profile.nisn || '',
                scan_id: profile.scan_id || '',
                kelas_id: profile.kelas_id || null,
                nama_kelas: profile.nama_kelas || '',
                kode_kelas: profile.kode_kelas || '',
                jenjang_kelas: profile.jenjang || '',
                no_wa: profile.no_wa || ''
            })
        };
        
        res.json({
            success: true,
            token,
            role: displayRole,
            route,
            tenant: user.tenant_id,
            user: responseUser
        });
        
    } catch (error) {
        logger.error('Login error:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get teacher data
app.get('/api/teacher-data/:id', (req, res) => {
    const teacherId = req.params.id;
    db.query('SELECT * FROM teachers WHERE id = ?', [teacherId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Teacher not found' });
        res.json(results[0]);
    });
});

// Get students (public for absensi system)
app.get('/api/students', (req, res) => {
    db.query('SELECT id, nama_siswa, nis, kelas, jurusan, tenant_id FROM students ORDER BY nama_siswa', (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Get teachers (public for absensi system)
app.get('/api/teachers', (req, res) => {
    db.query('SELECT id, nama, niy, jabatan, tenant_id FROM teachers ORDER BY nama', (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Get specific tenant by ID
app.get('/api/tenants/:id', (req, res) => {
    const tenantId = req.params.id;
    db.query('SELECT * FROM tenants WHERE code = ? OR id = ?', [tenantId, tenantId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Tenant not found' });
        res.json(results[0]);
    });
});

// Device verification for absensi system
app.post('/api/verify-device', (req, res) => {
    console.log('🔍 [SERVER] ===== DEVICE VERIFICATION REQUEST =====');
    console.log('🔍 [SERVER] Timestamp:', new Date().toISOString());
    console.log('🔍 [SERVER] Raw request body:', req.rawBody || 'N/A');
    console.log('🔍 [SERVER] Parsed request body:', JSON.stringify(req.body, null, 2));
    console.log('🔍 [SERVER] Content-Type:', req.headers['content-type']);
    console.log('🔍 [SERVER] User IP:', req.ip);
    console.log('🔍 [SERVER] User Agent:', req.headers['user-agent']);

    const { device_id } = req.body;

    if (!device_id) {
        console.log('❌ [SERVER] No device_id provided in request body');
        console.log('🔍 [SERVER] Available body keys:', Object.keys(req.body || {}));
        return res.status(400).json({ error: 'Device ID is required' });
    }

    // Validate device_id format (UUID or alphanumeric)
    if (typeof device_id !== 'string' || device_id.trim().length === 0) {
        return res.status(400).json({ error: 'Device ID tidak valid' });
    }

    console.log('✅ [SERVER] Processing device ID:', device_id);
    console.log('🔍 [SERVER] ===== STARTING DATABASE CHECK =====');

    // Check if device exists and is active
    console.log('🔍 [SERVER] Checking device in database...');
    const deviceQuery = 'SELECT * FROM attendance_devices WHERE device_id = ? AND status = "active"';

    db.query(deviceQuery, [device_id], (err, deviceResults) => {
        if (err) {
            console.error('💥 [SERVER] Device verification database error:', err);
            return res.status(500).json({ error: 'Database error' });
        }

        console.log('📊 [SERVER] Device query result:', deviceResults.length, 'devices found');

        if (deviceResults.length === 0) {
            console.log('❌ [SERVER] Device not found or inactive');
            return res.json({
                verified: false,
                message: 'Device tidak ditemukan atau tidak aktif'
            });
        }

        const device = deviceResults[0];
        console.log('✅ [SERVER] Device found:', device.device_name, '(', device.device_id, ')');

        // Check if device is currently in use (last used within 5 minutes)
        console.log('🔍 [SERVER] Checking device last usage...');
        const deviceCheckQuery = 'SELECT last_used_at FROM attendance_devices WHERE device_id = ?';

        db.query(deviceCheckQuery, [device_id], (deviceErr, deviceData) => {
            if (deviceErr) {
                console.error('💥 [SERVER] Device check error:', deviceErr);
                return res.status(500).json({ error: 'Database error' });
            }

            if (deviceData.length > 0 && deviceData[0].last_used_at) {
                const lastUsed = new Date(deviceData[0].last_used_at);
                const now = new Date();
                const minutesSinceLastUse = (now - lastUsed) / (1000 * 60);

                console.log('📊 [SERVER] Last used:', lastUsed.toISOString(), '- Minutes since:', minutesSinceLastUse);

                // If device was used within the last 5 minutes, consider it in use
                if (minutesSinceLastUse < 5) {
                    console.log('⚠️ [SERVER] Device is currently in use (used', minutesSinceLastUse.toFixed(1), 'minutes ago)');
                    return res.json({
                        verified: false,
                        in_use: true,
                        last_used: lastUsed.toISOString(),
                        minutes_ago: Math.floor(minutesSinceLastUse),
                        message: `Device sedang digunakan (digunakan ${Math.floor(minutesSinceLastUse)} menit yang lalu). Harap tunggu beberapa menit atau gunakan device lain.`
                    });
                }
            }

                // Device is available, update last_used_at timestamp
                console.log('✅ [SERVER] Device is available, updating last_used_at...');
                const updateQuery = 'UPDATE attendance_devices SET last_used_at = NOW() WHERE device_id = ?';

                db.query(updateQuery, [device_id], (updateErr, updateResult) => {
                    if (updateErr) {
                        console.error('💥 [SERVER] Failed to update device last_used_at:', updateErr);
                        // Continue anyway since this is not critical
                    }

                    console.log('✅ [SERVER] Device last_used_at updated successfully');

                    console.log('✅ [SERVER] Device verification successful - sending response');
                    const responseData = {
                        verified: true,
                        device: {
                            id: device.id,
                            device_id: device.device_id,
                            device_name: device.device_name,
                            tenant_id: device.tenant_id,
                            location: device.device_location
                        },
                        message: 'Device berhasil diverifikasi'
                    };
                    console.log('📤 [SERVER] Response data:', JSON.stringify(responseData, null, 2));
                    res.json(responseData);
                });
            });
        });
    });
});

// Standalone attendance API for absensi system
app.get('/api/standalone-attendance', (req, res) => {
    // Return empty array for now - absensi system can populate this
    res.json([]);
});

app.post('/api/standalone-attendance', (req, res) => {
    const { scan_id, tenant_code, device_id, fingerprint, snapshot } = req.body;

    if (!scan_id || !tenant_code) {
        return res.status(400).json({ error: 'scan_id and tenant_code are required' });
    }

    // First, try to find user by scan_id (could be NISN for students or NIY for teachers)
    const findUserQuery = `
        SELECT 'student' as type, id, nama_siswa as nama, nisn as identifier, kelas, NULL as jurusan, no_wa, tenant_id
        FROM students WHERE nisn = ? AND tenant_id = ?
        UNION
        SELECT 'teacher' as type, id, nama, niy as identifier, jabatan, jenjang, no_wa, tenant_id
        FROM teachers WHERE niy = ? AND tenant_id = ?
    `;

    db.query(findUserQuery, [scan_id, tenant_code, scan_id, tenant_code], (err, userResults) => {
        if (err) {
            console.error('User lookup error:', err);
            return res.status(500).json({ error: 'Database error' });
        }

        if (userResults.length === 0) {
            return res.json({
                success: false,
                error: 'User not found',
                message: 'Scan ID tidak ditemukan dalam database'
            });
        }

        const user = userResults[0];

        // Check if user already has attendance today
        const today = new Date().toISOString().split('T')[0];
        const checkAttendanceQuery = `
            SELECT * FROM attendance
            WHERE scan_id = ? AND tanggal = ? AND device_id = ?
            ORDER BY jam DESC LIMIT 1
        `;

        db.query(checkAttendanceQuery, [scan_id, today, device_id], (checkErr, attendanceResults) => {
            if (checkErr) {
                console.error('Attendance check error:', checkErr);
                return res.status(500).json({ error: 'Database error' });
            }

            let status = 'Datang'; // Default
            let keterangan = 'Normal';

            if (attendanceResults.length > 0) {
                // User already has attendance today, check if it's return
                const lastAttendance = attendanceResults[0];
                if (lastAttendance.status === 'Datang') {
                    status = 'Pulang';
                    keterangan = 'Pulang';
                } else {
                    status = 'Datang';
                    keterangan = 'Kembali';
                }
            }

            // Insert attendance record
            const now = new Date();
            const tanggal = now.toISOString().split('T')[0];
            const jam = now.toTimeString().split(' ')[0];

            const insertQuery = `
                INSERT INTO attendance (nama, asal_sekolah, jabatan, tanggal, jam, status, keterangan, sebagai, no_wa, jenis_absen, device_id, scan_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'QR', ?, ?)
            `;

            const params = [
                user.nama,
                tenant_code,
                user.type === 'student' ? `${user.kelas} ${user.jurusan}` : user.jabatan,
                tanggal,
                jam,
                status,
                keterangan,
                user.type === 'student' ? 'Siswa' : 'Guru',
                user.no_wa,
                device_id,
                scan_id
            ];

            db.query(insertQuery, params, (insertErr, result) => {
                if (insertErr) {
                    console.error('Attendance insert error:', insertErr);
                    return res.status(500).json({ error: 'Database error', details: insertErr.message });
                }

                // Update device last_used_at timestamp after successful attendance
                const updateDeviceQuery = 'UPDATE attendance_devices SET last_used_at = NOW() WHERE device_id = ?';
                db.query(updateDeviceQuery, [device_id], (updateErr) => {
                    if (updateErr) {
                        console.warn('Failed to update device last_used_at:', updateErr);
                        // Don't fail the attendance because of this
                    } else {
                        console.log('✅ Device last_used_at updated after attendance');
                    }
                });

                res.json({
                    success: true,
                    id: result.insertId,
                    user: user.nama,
                    role: user.type,
                    status: status,
                    keterangan: keterangan,
                    whatsapp_sent: false // Could implement WhatsApp notification here
                });
            });
        });
    });
});

// Get student profile
app.get('/api/student-profile', authenticateToken, authorizeAPI, (req, res) => {
    db.query('SELECT * FROM students WHERE user_id = ?', [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Student not found' });
        res.json(results[0]);
    });
});

// Get tenants (fallback if tenants table doesn't exist)
app.get('/api/tenants', (req, res) => {
    // Try tenants table first
    const query = req.query.code ? 'SELECT * FROM tenants WHERE code = ?' : 'SELECT * FROM tenants ORDER BY name';
    const params = req.query.code ? [req.query.code] : [];

    db.query(query, params, (err, results) => {
        if (err) {
            // Fallback: get unique tenant_ids from teachers table
            const fallbackQuery = 'SELECT DISTINCT tenant_id as code, tenant_id as name FROM teachers WHERE tenant_id IS NOT NULL ORDER BY tenant_id';
            db.query(fallbackQuery, (fallbackErr, fallbackResults) => {
                if (fallbackErr) return res.status(500).json({ error: 'Database error' });
                res.json(fallbackResults);
            });
        } else {
            res.json(results);
        }
    });
});

// Get jabatan options
app.get('/api/jabatan-options', authenticateToken, authorizeAPI, (req, res) => {
    db.query('SELECT * FROM jabatan_options WHERE aktif = TRUE ORDER BY urutan, nama_jabatan', (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Attendance rules APIs
app.get('/api/attendance-rules', authenticateToken, authorizeAPI, (req, res) => {
    const { tenant_id, type } = req.query;
    let query = 'SELECT * FROM attendance_rules WHERE 1=1';
    const params = [];

    if (tenant_id) {
        query += ' AND tenant_id = ?';
        params.push(tenant_id);
    }
    if (type) {
        query += ' AND type = ?';
        params.push(type);
    }

    query += ' ORDER BY tenant_id, type, waktu_mulai';

    db.query(query, params, (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

app.post('/api/attendance-rules', authenticateToken, authorizeAPI, (req, res) => {
    const { tenant_id, type, waktu_mulai, waktu_akhir, keterangan } = req.body;

    const query = 'INSERT INTO attendance_rules (tenant_id, type, waktu_mulai, waktu_akhir, keterangan) VALUES (?, ?, ?, ?, ?)';
    db.query(query, [tenant_id, type, waktu_mulai, waktu_akhir, keterangan], (err, result) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json({ success: true, id: result.insertId });
    });
});

app.delete('/api/attendance-rules/:id', authenticateToken, authorizeAPI, (req, res) => {
    const id = req.params.id;
    db.query('DELETE FROM attendance_rules WHERE id = ?', [id], (err, result) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json({ success: true });
    });
});

// Get sebagai options
app.get('/api/sebagai-options', authenticateToken, authorizeAPI, (req, res) => {
    db.query('SELECT * FROM sebagai_options WHERE aktif = TRUE ORDER BY urutan, nama_sebagai', (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Additional API routes for dashboard functionality
app.get('/api/dashboard-data', authenticateToken, (req, res) => {
    // Placeholder for dashboard data
    res.json({ teachers: 0, students: 0, attendance: 0 });
});

app.get('/api/students-attendance', authenticateToken, authorizeAPI, (req, res) => {
    // Placeholder for students attendance data
    res.json([]);
});

app.get('/api/students-by-class', authenticateToken, authorizeAPI, (req, res) => {
    // Placeholder for students by class
    res.json([]);
});

app.post('/api/save-jurnal', authenticateToken, authorizeAPI, (req, res) => {
    // Placeholder for saving journal
    res.json({ success: true });
});

app.post('/api/send-whacenter', authenticateToken, authorizeAPI, (req, res) => {
    // Placeholder for whacenter
    res.json({ success: true });
});

app.post('/api/attendance-request', authenticateToken, authorizeAPI, (req, res) => {
    // Placeholder for attendance request
    res.json({ success: true });
});

app.get('/api/attendance-requests', authenticateToken, authorizeAPI, (req, res) => {
    // Placeholder for attendance requests
    res.json([]);
});

app.get('/api/attendance-recent', authenticateToken, (req, res) => {
    // Placeholder for recent attendance
    res.json([]);
});

app.post('/api/activity-log', authenticateToken, (req, res) => {
    // Placeholder for activity log
    res.json({ success: true });
});

// Complete profile
app.post('/complete-profile', upload.single('foto'), async (req, res) => {
    console.log('Complete profile request for teacherId:', req.body.teacherId);

    const { teacherId, nama, niy, nik, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_wa, email, jenjang, jabatan, sebagai, status_kepegawaian, tmt, status_aktif, keterangan, terima_notifikasi, tenant_id, scan_id, jabatan_tambahan, accessible_units } = req.body;

    // Validate
    if (!teacherId || teacherId === 'undefined') {
        return res.status(400).json({ success: false, message: 'ID Guru tidak valid' });
    }

    const teacherIdNum = parseInt(teacherId);
    if (isNaN(teacherIdNum)) {
        return res.status(400).json({ success: false, message: 'ID Guru harus berupa angka' });
    }

    // Handle file upload - only process if new file is uploaded
    let link_foto = null;

    // First, get existing photo
    let existingPhoto = null;
    try {
        const existingData = await new Promise((resolve, reject) => {
            db.query('SELECT link_foto FROM teachers WHERE id = ?', [teacherIdNum], (err, rows) => {
                if (err) reject(err);
                else resolve(rows[0]);
            });
        });
        existingPhoto = existingData ? existingData.link_foto : null;
    } catch (err) {
        console.log('Error checking existing photo:', err);
    }

    if (req.file) {
        // New file uploaded - process it
        const ext = path.extname(req.file.originalname);
        const cleanNama = nama.replace(/[^a-zA-Z0-9\s]/g, '').replace(/\s+/g, '_').toUpperCase();
        const newFileName = `FOTO_${cleanNama}${ext}`;

        try {
            fs.renameSync(req.file.path, path.join('uploads', newFileName));
            link_foto = 'uploads/' + newFileName;
            console.log('New photo uploaded:', link_foto);
        } catch (err) {
            return res.status(500).json({ success: false, message: 'Error saving file' });
        }
    } else {
        // No new file uploaded - keep existing photo
        link_foto = existingPhoto;
        console.log('Keeping existing photo:', link_foto);
    }

    // Generate scan_id from NIY or NIK if not provided
    let final_scan_id = scan_id || '';
    if (!final_scan_id) {
        if (niy && niy.length >= 6) {
            final_scan_id = niy;
        } else if (nik) {
            final_scan_id = nik;
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
        nama = ?, niy = ?, nik = ?, scan_id = ?, jenis_kelamin = ?, tempat_lahir = ?, tanggal_lahir = ?,
        alamat = ?, no_wa = ?, email = ?, tenant_id = ?, jenjang = ?, jabatan = ?, sebagai = ?,
        status_kepegawaian = ?, tmt = ?, status_aktif = ?, keterangan = ?, link_foto = ?,
        terima_notifikasi = ?, jabatan_tambahan = ?, accessible_units = ?
        WHERE id = ?
    `;

    const params = [
        nama, niy, nik, final_scan_id, jenis_kelamin, tempat_lahir, tanggal_lahir,
        alamat, normalized_no_wa, email, tenant_id, jenjang, jabatan, sebagai,
        status_kepegawaian, tmt, status_aktif, keterangan, link_foto,
        terima_notifikasi === '1' ? 1 : 0, jabatan_tambahan, accessible_units, teacherIdNum
    ];

    db.query(updateQuery, params, (err, result) => {
        if (err) {
            console.log('Update error:', err);
            return res.status(500).json({ success: false, message: 'Database error: ' + err.message });
        }

            // Check completion - get both old and new data
            db.query('SELECT * FROM teachers WHERE id = ?', [teacherIdNum], (checkErr, rows) => {
                if (checkErr) {
                    return res.status(500).json({ success: false, message: 'Database check error' });
                }

                const teacher = rows[0];

                // Check if TMT makes NIY optional or required
                const tmtDate = new Date(teacher.tmt);
                const now = new Date();
                const diffYears = (now - tmtDate) / (1000 * 60 * 60 * 24 * 365);
                const niyRequired = diffYears >= 2;

                // Base required fields
                let requiredFields = ['nama', 'nik', 'jenis_kelamin', 'tempat_lahir', 'tanggal_lahir', 'alamat', 'no_wa', 'jenjang', 'jabatan', 'sebagai', 'status_kepegawaian', 'tmt', 'status_aktif', 'keterangan'];

                // Add NIY to required fields if TMT >= 2 years
                if (niyRequired) {
                    requiredFields.push('niy');
                }

                // Special handling for link_foto: if photo already exists, don't require it
                const hasExistingPhoto = teacher.link_foto && teacher.link_foto.trim() !== '';
                if (!hasExistingPhoto) {
                    requiredFields.push('link_foto');
                }

                console.log('Required fields for validation:', requiredFields);
                console.log('Has existing photo:', hasExistingPhoto);
                console.log('Teacher data:', JSON.stringify(teacher, null, 2));

                const missingFields = [];
                const isComplete = requiredFields.every(field => {
                    const value = teacher[field];
                    const isValid = value !== null && value !== undefined && value.toString().trim() !== '';
                    console.log(`Field ${field}: "${value}" (type: ${typeof value}) -> ${isValid ? 'VALID' : 'INVALID'}`);

                    if (!isValid) {
                        missingFields.push(field);
                    }

                    return isValid;
                });

                console.log('Validation result - isComplete:', isComplete);
                if (!isComplete) {
                    console.log('MISSING FIELDS:', missingFields);
                    console.log('This will cause "Data belum lengkap" error');
                }

            if (!isComplete) {
                return res.json({ success: false, message: 'Data belum lengkap. Isi semua field yang diperlukan.' });
            }

            // Generate JWT token using user_id (not teacher.id)
            const token = jwt.sign({ 
                id: teacher.user_id, 
                role: 'Guru', 
                tenant: teacher.tenant_id,
                profile_id: teacher.id 
            }, process.env.JWT_SECRET || 'fallback_secret_change_this');
            res.json({ success: true, token });
        });
    });
});

// WhatsApp send endpoint
app.post('/api/whatsapp-send', authenticateToken, authorizeAPI, (req, res) => {
    const { number, message } = req.body;

    if (!number || !message) {
        return res.status(400).json({ error: 'Number and message required' });
    }

    // Mock response for development
    logger.info(`📱 [MOCK] Would send WhatsApp to ${number}: ${message.substring(0, 50)}...`);
    res.json({
        status: 'success',
        code: '200',
        message: 'Message sent successfully (mock mode)'
    });
});

// Auth middleware
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            error: 'Access token required',
            message: 'Please log in to access this resource'
        });
    }

    jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret_change_this', (err, user) => {
        if (err) {
            return res.status(403).json({
                error: 'Invalid token',
                message: 'Your session has expired. Please log in again.'
            });
        }
        req.user = user;
        next();
    });
}

// Authorization middleware - check if user has access to specific paths
function authorizeAccess(req, res, next) {
    const user = req.user;
    const requestedPath = req.path;

    // Allow access to common assets and public paths without authentication
    if (requestedPath.startsWith('/assets/') ||
        requestedPath.startsWith('/uploads/') ||
        requestedPath === '/favicon.ico' ||
        requestedPath === '/' ||
        requestedPath === '/login.html' ||
        requestedPath === '/complete-profile.html' ||
        requestedPath === '/index.html' ||
        requestedPath.startsWith('/css/') ||
        requestedPath.startsWith('/js/') ||
        requestedPath.startsWith('/images/') ||
        requestedPath.startsWith('/public/')) {
        return next();
    }

    // Get user info
    const userRole = user.role;
    const userTenant = user.tenant;

    // Determine permissions based on role and tenant
    let allowedPaths = [];

    // Base permissions by role
    switch(userRole) {
        case 'Admin':
            allowedPaths = userTenant === 'YPWILUTIM'
                ? ['/admin/pusat', '/yayasan', '/berita']  // Central admin
                : ['/admin/sekolah', '/berita'];           // School admin
            break;
        case 'Bendahara':
            allowedPaths = userTenant === 'YPWILUTIM'
                ? ['/bendahara/pusat', '/yayasan', '/berita']  // Central finance
                : ['/bendahara/sekolah', '/berita'];           // School finance
            break;
        case 'Ketua':
            allowedPaths = userTenant === 'YPWILUTIM'
                ? ['/ketua/pusat', '/yayasan', '/berita']  // Central leader
                : ['/ketua/sekolah', '/berita'];           // School leader
            break;
        case 'Guru':
            allowedPaths = ['/guru', '/berita'];
            break;
        case 'Siswa':
            allowedPaths = ['/siswa', '/berita'];
            break;
        case 'Staf Yayasan':
            allowedPaths = ['/yayasan', '/berita'];
            break;
        default:
            // Fallback roles (case-insensitive partial match)
            const matchingRole = ['Admin', 'Bendahara', 'Ketua', 'Guru', 'Siswa', 'Staf Yayasan'].find(role =>
                role.toLowerCase().includes(userRole.toLowerCase()) ||
                userRole.toLowerCase().includes(role.toLowerCase())
            );

            if (matchingRole) {
                // Recursively call this function with the matched role
                user.role = matchingRole;
                return authorizeAccess(req, res, next);
            } else {
                return res.status(403).json({
                    error: 'Role not recognized',
                    message: `Your role '${userRole}' is not configured for access.`
                });
            }
    }

    // Check if any of the allowed paths match the requested path
    const hasAccess = allowedPaths.some(allowedPath => {
        // Normalize paths for comparison
        const normalizedRequested = requestedPath.toLowerCase();
        const normalizedAllowed = allowedPath.toLowerCase();

        // Check various matching conditions
        return normalizedRequested.startsWith(normalizedAllowed) ||
               normalizedRequested === normalizedAllowed ||
               (normalizedRequested + '/').startsWith(normalizedAllowed + '/');
    });

    if (!hasAccess) {
        return res.status(403).json({
            error: 'Access denied',
            message: `You don't have permission to access this resource. Your role: ${userRole}`
        });
    }

    next();
}

// API authorization middleware - check if user has permission for API access
function authorizeAPI(req, res, next) {
    const user = req.user;
    const requestedPath = req.path;
    const userRole = user.role;
    const userTenant = user.tenant;

    // Define which roles can access which APIs (support both old and new role names)
    const adminRoles = ['Admin', 'Admin Pusat', 'Admin Sekolah'];
    const bendaharaRoles = ['Bendahara', 'Bendahara Pusat', 'Bendahara Sekolah'];
    const ketuaRoles = ['Ketua', 'Ketua Pusat', 'Kepala Sekolah'];
    const allStaffRoles = ['Admin', 'Admin Pusat', 'Admin Sekolah', 'Bendahara', 'Bendahara Pusat', 'Bendahara Sekolah', 'Ketua', 'Ketua Pusat', 'Kepala Sekolah', 'Staf Yayasan', 'Guru'];

    // Define API permissions
    const apiPermissions = {
        '/api/admin-stats': adminRoles,
        '/api/tenants': adminRoles,
        '/api/attendance-rules': adminRoles,
        '/api/all-teachers': adminRoles,
        '/api/students': adminRoles,
        '/api/teacher-profile': allStaffRoles,
        '/api/teacher-data': allStaffRoles, // For complete-profile page
        '/api/student-profile': ['Siswa'],
        '/api/news': ['*'], // Allow all authenticated users
        '/api/blog': ['*'], // Allow all authenticated users
        '/api/whatsapp-send': allStaffRoles,
        '/api/attendance-request': allStaffRoles,
        '/api/attendance-requests': allStaffRoles
    };

    // TEMP: Allow all access to teacher-data API for debugging
    if (requestedPath.startsWith('/api/teacher-data/')) {
        console.log(`TEMP: Allowing access to ${requestedPath}`);
        return next();
    }

    console.log(`API authorization check: ${userRole} accessing ${requestedPath}`);

    // Check if this API requires specific permissions
    // Handle parameterized routes by checking prefixes
    let requiredRoles = apiPermissions[requestedPath];
    console.log(`Direct match for ${requestedPath}: ${requiredRoles ? 'found' : 'not found'}`);

    if (!requiredRoles) {
        // Check for parameterized routes (e.g., /api/teacher-data/769 should match /api/teacher-data)
        for (const [apiPath, roles] of Object.entries(apiPermissions)) {
            if (requestedPath.startsWith(apiPath + '/') || requestedPath === apiPath) {
                requiredRoles = roles;
                console.log(`Parameterized match: ${requestedPath} matches ${apiPath}`);
                break;
            }
        }
    }

    if (!requiredRoles) {
        // If not explicitly defined, allow access (for development)
        console.log(`API access allowed (no specific permissions defined): ${requestedPath}`);
        return next();
    }

    console.log(`Required roles for ${requestedPath}: [${requiredRoles.join(', ')}]`);
    console.log(`User role: ${userRole}`);

    // Check if user has permission
    const hasPermission = requiredRoles.includes('*') || requiredRoles.includes(userRole);

    console.log(`Permission check result: ${hasPermission}`);

    if (!hasPermission) {
        console.log(`API access denied: User role '${userRole}' (tenant: ${userTenant}) tried to access '${requestedPath}'`);
        return res.status(403).json({
            error: 'Access denied',
            message: `You don't have permission to access this API. Your role: ${userRole}`
        });
    }

    console.log(`API access granted: ${userRole} can access ${requestedPath}`);
    next();
}

// Get teacher profile (for logged-in teacher)
app.get('/api/teacher-profile', authenticateToken, authorizeAPI, (req, res) => {
    db.query('SELECT * FROM teachers WHERE user_id = ?', [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Teacher not found' });
        res.json(results[0]);
    });
});

// Admin devices management
app.get('/api/admin-devices', authenticateToken, authorizeAPI, (req, res) => {
    const userTenant = req.user.tenant;
    const userRole = req.user.role;

    // Build query based on user permissions
    let query = `
        SELECT ad.*, t.name as tenant_name,
               COALESCE(teachers.nama, users.email) as created_by_name
        FROM attendance_devices ad
        LEFT JOIN tenants t ON ad.tenant_id = t.code
        LEFT JOIN teachers ON ad.created_by = teachers.id
        LEFT JOIN users ON ad.created_by = users.id
        WHERE 1=1
    `;
    const params = [];

    // Central admin can see all devices, school admin only their tenant's devices
    if (userTenant !== 'YPWILUTIM') {
        query += ' AND ad.tenant_id = ?';
        params.push(userTenant);
    }

    query += ' ORDER BY ad.created_at DESC';

    db.query(query, params, (err, results) => {
        if (err) {
            console.error('Database error in /api/admin-devices:', err);
            return res.status(500).json({ error: 'Database error', details: err.message });
        }
        console.log(`Found ${results.length} devices for user ${req.user.role} (${req.user.tenant})`);
        res.json(results);
    });
});

app.post('/api/admin-devices', authenticateToken, authorizeAPI, (req, res) => {
    const { device_id, device_name, device_location, phone_number, tenant_id } = req.body;
    const userId = req.user.id;
    const userTenant = req.user.tenant;

    // Validate required fields
    if (!device_id || !device_name || !tenant_id) {
        return res.status(400).json({ error: 'device_id, device_name, and tenant_id are required' });
    }

    // Check if device_id already exists (enforce uniqueness)
    db.query('SELECT id FROM attendance_devices WHERE device_id = ?', [device_id], (err, existing) => {
        if (err) {
            console.error('Database error checking device uniqueness:', err);
            return res.status(500).json({ error: 'Database error' });
        }

        if (existing.length > 0) {
            return res.status(409).json({ error: 'Device ID sudah digunakan. Setiap device harus memiliki ID yang unik.' });
        }

        // For non-central admin, ensure they can only create devices for their tenant
        if (userTenant !== 'YPWILUTIM' && tenant_id !== userTenant) {
            return res.status(403).json({ error: 'Anda hanya dapat membuat device untuk tenant Anda sendiri' });
        }

        // Insert new device
        const insertQuery = `
            INSERT INTO attendance_devices (device_id, device_name, device_location, phone_number, tenant_id, created_by, status, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW(), NOW())
        `;
        const params = [device_id, device_name, device_location || null, phone_number || null, tenant_id, userId];

        db.query(insertQuery, params, (insertErr, result) => {
            if (insertErr) {
                console.error('Database error creating device:', insertErr);
                return res.status(500).json({ error: 'Database error', details: insertErr.message });
            }

            console.log(`Device created successfully: ${device_name} (${device_id})`);
            res.json({
                success: true,
                id: result.insertId,
                message: 'Device berhasil didaftarkan dan menunggu approval'
            });
        });
    });
});

app.put('/api/admin-devices/:id/status', authenticateToken, authorizeAPI, (req, res) => {
    const deviceId = req.params.id;
    const { status } = req.body;
    const userTenant = req.user.tenant;

    if (!['active', 'inactive', 'pending'].includes(status)) {
        return res.status(400).json({ error: 'Invalid status' });
    }

    // Check if device belongs to user's tenant (if not central admin)
    let query = 'UPDATE attendance_devices SET status = ?, updated_at = NOW() WHERE id = ?';
    const params = [status, deviceId];

    if (userTenant !== 'YPWILUTIM') {
        query += ' AND tenant_id = ?';
        params.push(userTenant);
    }

    db.query(query, params, (err, result) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Device not found or access denied' });
        }
        res.json({ success: true, message: 'Device status updated' });
    });
});

app.delete('/api/admin-devices/:id', authenticateToken, authorizeAPI, (req, res) => {
    const deviceId = req.params.id;
    const userTenant = req.user.tenant;

    // Check if device belongs to user's tenant (if not central admin)
    let query = 'DELETE FROM attendance_devices WHERE id = ?';
    const params = [deviceId];

    if (userTenant !== 'YPWILUTIM') {
        query += ' AND tenant_id = ?';
        params.push(userTenant);
    }

    db.query(query, params, (err, result) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Device not found or access denied' });
        }
        res.json({ success: true, message: 'Device deleted' });
    });
});

// Get admin stats
app.get('/api/admin-stats', authenticateToken, authorizeAPI, (req, res) => {
    const user = req.user;

    // Count tenants
    db.query('SELECT COUNT(*) as count FROM tenants', (err, tenantResults) => {
        if (err) {
            // Fallback: count distinct tenants from teachers table
            db.query('SELECT COUNT(DISTINCT tenant_id) as count FROM teachers WHERE tenant_id IS NOT NULL', (fallbackErr, fallbackResults) => {
                if (fallbackErr) return res.status(500).json({ error: 'Database error' });
                const tenantCount = fallbackResults[0].count;

                // Get teacher count
                db.query('SELECT COUNT(*) as count FROM teachers', (teacherErr, teacherResults) => {
                    if (teacherErr) return res.status(500).json({ error: 'Database error' });
                    const teacherCount = teacherResults[0].count;

                    // Get student count
                    db.query('SELECT COUNT(*) as count FROM students', (studentErr, studentResults) => {
                        const studentCount = studentErr ? 0 : studentResults[0].count;

                        res.json({
                            tenants: tenantCount,
                            teachers: teacherCount,
                            students: studentCount,
                            attendance: 0 // Placeholder
                        });
                    });
                });
            });
        } else {
            const tenantCount = tenantResults[0].count;

            // Get teacher count
            db.query('SELECT COUNT(*) as count FROM teachers', (teacherErr, teacherResults) => {
                if (teacherErr) return res.status(500).json({ error: 'Database error' });
                const teacherCount = teacherResults[0].count;

                // Get student count
                db.query('SELECT COUNT(*) as count FROM students', (studentErr, studentResults) => {
                    const studentCount = studentErr ? 0 : studentResults[0].count;

                    res.json({
                        tenants: tenantCount,
                        teachers: teacherCount,
                        students: studentCount,
                        attendance: 0 // Placeholder
                    });
                });
            });
        }
    });
});

// News API
app.get('/api/news', authenticateToken, (req, res) => {
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

    query += ' ORDER BY id DESC';
    if (limit) query += ' LIMIT ' + parseInt(limit);

    db.query(query, params, (err, results) => {
        if (err) {
            console.log('News API error:', err.message);
            return res.json([]);
        }
        res.json(results);
    });
});

// Blog API (fallback to news table if blog doesn't exist)
app.get('/api/blog', authenticateToken, (req, res) => {
    const { limit, category, tenant } = req.query;
    let query = 'SELECT * FROM blog WHERE 1=1';
    const params = [];

    if (category) {
        query += ' AND category = ?';
        params.push(category);
    }
    if (tenant) {
        query += ' AND (tenant_id = ? OR tenant_id IS NULL)';
        params.push(tenant);
    }

    query += ' ORDER BY id DESC';
    if (limit) query += ' LIMIT ' + parseInt(limit);

    db.query(query, params, (err, results) => {
        if (err) {
            // Fallback: get blog posts from news table where category = 'blog'
            let fallbackQuery = 'SELECT id, title, content, category, author as teacher_name, tenant_id, image, created_at FROM news WHERE category = "blog"';
            const fallbackParams = [];

            if (category && category !== 'blog') {
                fallbackQuery += ' AND category = ?';
                fallbackParams.push(category);
            }
            if (tenant) {
                fallbackQuery += ' AND (tenant_id = ? OR tenant_id IS NULL)';
                fallbackParams.push(tenant);
            }

            fallbackQuery += ' ORDER BY id DESC';
            if (limit) fallbackQuery += ' LIMIT ' + parseInt(limit);

            db.query(fallbackQuery, fallbackParams, (fallbackErr, fallbackResults) => {
                if (fallbackErr) {
                    console.log('Blog API fallback error:', fallbackErr.message);
                    return res.json([]);
                }
                res.json(fallbackResults);
            });
        } else {
            res.json(results);
        }
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    logger.error('Error:', err);
    if (err instanceof multer.MulterError) {
        return res.status(400).json({ error: err.message });
    }
    if (err.message === 'Not allowed by CORS') {
        return res.status(403).json({ error: 'Origin not allowed by CORS' });
    }
    res.status(500).json({ error: 'Internal server error' });
});

// 404 handler for undefined routes
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
app.listen(PORT, () => {
    logger.info(`🚀 Server running on port ${PORT} in ${NODE_ENV} mode`);
    logger.info(`📱 WhatsApp API Device ID: mock_device_id`);
    logger.info(`🌐 API URL: https://app.whacenter.id/apisend`);
    logger.warn(`⚠️  WhatsApp Device ID is set to mock mode for development`);
    logger.info(`💡 To enable WhatsApp notifications:`);
    logger.info(`   1. Login to https://app.whacenter.com/`);
    logger.info(`   2. Go to Device menu > Add Device Multidevice`);
    logger.info(`   3. Scan QR code with your WhatsApp`);
    logger.info(`   4. Copy Device ID to .env file`);
    logger.info(`🔧 Alternative: Use Fonnte API if Whacenter unavailable`);
    logger.info(`📋 Available endpoints:`);
    logger.info(`   - GET  / (Root page - index.html)`);
    logger.info(`   - GET  /api/test-db (Database connection test)`);
    logger.info(`   - POST /api/login (Authentication)`);
    logger.info(`   - GET  /api/news (News articles)`);
    logger.info(`   - GET  /api/blog (Blog posts)`);
    logger.info(`Connected to MySQL database successfully`);
});