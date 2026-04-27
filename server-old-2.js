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

// Database configuration
const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ypwi_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
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

        // Fix existing photo paths in database
        db.query(`
            UPDATE teachers
            SET link_foto = CONCAT('uploads/', link_foto)
            WHERE link_foto IS NOT NULL
            AND link_foto NOT LIKE 'uploads/%'
        `, (fixErr) => {
            if (fixErr) {
                logger.warn('Could not fix existing photo paths:', fixErr.message);
            } else {
                logger.info('✅ Fixed existing photo paths in database');
            }
        });

        connection.release();
    }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files
app.use(express.static('public'));
app.use('/assets', express.static('assets'));
app.use('/guru', express.static('guru'));
app.use('/siswa', express.static('siswa'));
app.use('/admin', express.static('admin'));
app.use('/bendahara', express.static('bendahara'));
app.use('/uploads', express.static('uploads'));

// File upload configuration
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + file.originalname;
        cb(null, uniqueName);
    }
});
const upload = multer({ storage });

// Routes

// Root path - serve index.html
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Test DB connection
app.get('/api/test-db', (req, res) => {
    db.query('SELECT COUNT(*) as count FROM tenants', (err, result) => {
        if (err) return res.status(500).json({ error: 'DB connection failed', details: err.message });
        res.json({ message: 'DB connected', tenants_count: result[0].count });
    });
});

// Login
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        const query = 'SELECT * FROM teachers WHERE email = ?';
        db.query(query, [username], async (err, results) => {
            if (err) return res.status(500).json({ error: 'Database error' });

            if (results.length === 0) {
                return res.status(401).json({ error: 'Email atau password salah' });
            }

            const user = results[0];
            let match = (password === user.password);

            try {
                match = await bcrypt.compare(password, user.password);
            } catch(e) {
                match = (password === user.password);
            }

            if (!match) {
                return res.status(401).json({ error: 'Email atau password salah' });
            }

            // Check if profile is complete
            const requiredFields = ['nama', 'niy', 'nik', 'jenis_kelamin', 'tempat_lahir', 'tanggal_lahir', 'alamat', 'no_wa', 'email', 'jenjang', 'jabatan', 'sebagai', 'status_kepegawaian', 'tmt', 'status_aktif', 'keterangan', 'link_foto'];
            const isComplete = requiredFields.every(field => {
                const value = user[field];
                return value !== null && value !== undefined && value.toString().trim() !== '';
            });

            if (!isComplete) {
                return res.json({
                    incomplete: true,
                    teacherId: user.id,
                    data: {
                        nama: user.nama,
                        niy: user.niy,
                        nik: user.nik,
                        jenis_kelamin: user.jenis_kelamin,
                        tempat_lahir: user.tempat_lahir,
                        tanggal_lahir: user.tanggal_lahir ? user.tanggal_lahir.toISOString().split('T')[0] : '',
                        alamat: user.alamat,
                        no_wa: user.no_wa,
                        email: user.email,
                        jenjang: user.jenjang,
                        jabatan: user.jabatan,
                        sebagai: user.sebagai,
                        status_kepegawaian: user.status_kepegawaian,
                        tmt: user.tmt ? user.tmt.toISOString().split('T')[0] : '',
                        status_aktif: user.status_aktif,
                        keterangan: user.keterangan
                    }
                });
            }

            const token = jwt.sign({ id: user.id, role: 'Guru', tenant: user.tenant_id }, 'secret_key');
            res.json({ success: true, token, role: 'Guru', tenant: user.tenant_id });
        });
    } catch (error) {
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

// Get tenants
app.get('/api/tenants', (req, res) => {
    const query = req.query.code ? 'SELECT * FROM tenants WHERE code = ?' : 'SELECT * FROM tenants ORDER BY name';
    const params = req.query.code ? [req.query.code] : [];
    db.query(query, params, (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Get jabatan options
app.get('/api/jabatan-options', (req, res) => {
    db.query('SELECT * FROM jabatan_options WHERE aktif = TRUE ORDER BY urutan, nama_jabatan', (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Get sebagai options
app.get('/api/sebagai-options', (req, res) => {
    db.query('SELECT * FROM sebagai_options WHERE aktif = TRUE ORDER BY urutan, nama_sebagai', (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
});

// Complete profile
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
            link_foto = 'uploads/' + newFileName; // Simpan path lengkap
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

// WhatsApp send endpoint
app.post('/api/whatsapp-send', (req, res) => {
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

    if (!token) return res.status(401).json({ error: 'Access token required' });

    jwt.verify(token, 'secret_key', (err, user) => {
        if (err) return res.status(403).json({ error: 'Invalid token' });
        req.user = user;
        next();
    });
}

// Get teacher profile
app.get('/api/teacher-profile', authenticateToken, (req, res) => {
    db.query('SELECT * FROM teachers WHERE id = ?', [req.user.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (results.length === 0) return res.status(404).json({ error: 'Teacher not found' });
        res.json(results[0]);
    });
});

// News API
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

// Blog API
app.get('/api/blog', (req, res) => {
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
            console.log('Blog API error:', err.message);
            return res.json([]);
        }
        res.json(results);
    });
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
    logger.info(`   - GET  /api/test-db (Database connection test)`);
    logger.info(`   - POST /api/login (Authentication)`);
    logger.info(`   - GET  /api/news (News articles)`);
    logger.info(`   - GET  /api/blog (Blog posts)`);
    logger.info(`Connected to MySQL database successfully`);
});