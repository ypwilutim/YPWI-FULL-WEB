# YPWI Luwu Timur Web Application

Sistem manajemen sekolah berbasis web untuk Yayasan Pesantren Wahdah Islamiyah (YPWI) Luwu Timur dengan dukungan multi-tenant untuk 26 unit sekolah.

## 📋 Deskripsi Proyek

Aplikasi web ini menyediakan platform terintegrasi untuk mengelola:
- ✅ **26 Unit Sekolah** (TKIT, SDIT, SMPIT, SMAIT, PPTQ, Pondok Informatika)
- ✅ **Sistem Absensi** dengan QR Code scanner
- ✅ **Manajemen Guru & Siswa** dengan multi-role support
- ✅ **Content Management** (Berita, Blog, Galeri)
- ✅ **WhatsApp Notifications** (Mock mode untuk development)
- ✅ **File Upload & Document Management**
- ✅ **Real-time Dashboard & Reporting**

## 🚀 Quick Start (Development)

### 1. Prerequisites

- **Node.js** >= 14.0.0
- **MySQL** >= 8.0 (atau MariaDB >= 10.4)
- **Git** untuk version control

### 2. Setup Environment

```bash
# Clone repository
git clone <repository-url>
cd ypwi-web-app

# Install dependencies
npm install

# Setup database
# Jalankan script berikut di MySQL sebagai root user:
mysql -u root -p < ypwi_db_final.sql

# Atau setup manual dengan user khusus:
mysql -u root -p < setup-dev-db.sql
mysql -u root -p ypwi_db < ypwi_db.sql

# Copy environment variables
cp .env.example .env
# Edit .env sesuai konfigurasi lokal
```

### 3. Environment Configuration

Buat file `.env` di root directory:

```env
# Server Configuration
NODE_ENV=development
PORT=3001

# Database Configuration
DB_HOST=localhost
DB_USER=root  # atau ypwi_dev jika menggunakan setup-dev-db.sql
DB_PASSWORD=your_mysql_password
DB_NAME=ypwi_db

# JWT Secret (ubah untuk production)
JWT_SECRET=your_super_secret_jwt_key_here

# WhatsApp API (Mock untuk development)
WHATSAPP_DEVICE_ID=mock_device_id

# Logging Configuration
LOG_LEVEL=debug
LOG_FILE=logs/app.log
```

### 4. Run Application

```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start

# Check health
curl http://localhost:3001/api/test-db
```

Server akan berjalan di `http://localhost:3001`

## 🎯 Fitur Utama

### 👥 User Management
- **Multi-tenant Support**: 26 unit sekolah dengan isolasi data
- **Role-based Access Control**:
  - Admin Yayasan (Super Admin)
  - Admin Sekolah
  - Bendahara Yayasan/Sekolah
  - Guru (dengan multi-unit & multi-role support)
  - Siswa
- **Profile Management**: Lengkapi data guru dengan validasi

### 📊 Sistem Absensi
- **QR Code Scanner** untuk absensi cepat
- **Multi-device Support** dengan OTP verification
- **Rules Engine** untuk aturan absensi (tepat waktu, terlambat, lembur)
- **Real-time Tracking** & reporting
- **WhatsApp Notifications** untuk konfirmasi absensi

### 📰 Content Management
- **News System** dengan kategori & tenant filtering
- **Blog Guru** untuk sharing pengetahuan
- **Gallery** dengan unit-based organization
- **File Upload** dengan secure storage

### 💰 Financial Management
- **Salary Calculation** dengan berbagai tunjangan
- **Billing System** untuk siswa
- **Multi-unit Support** untuk guru yang mengajar di beberapa sekolah

### 📱 Integrations
- **WhatsApp API** (Whacenter/Fonnte) untuk notifications
- **JWT Authentication** dengan secure token management
- **Winston Logging** untuk monitoring & debugging
- **Multer** untuk file uploads

## 🔧 Development Tools

### Logging
- Menggunakan Winston untuk structured logging
- Log level dapat dikonfigurasi via `.env`
- File logs tersimpan di `logs/app.log`

### Database
- User khusus untuk development: `ypwi_dev`
- Sample data sudah tersedia
- Schema lengkap untuk semua fitur

### Mock Services
- WhatsApp API menggunakan mock mode di development
- Tidak memerlukan device ID asli untuk testing

## 🔗 API Endpoints

### 🔐 Authentication
```
POST /api/login            # Login dengan email/password
GET  /api/teacher-profile  # Get profile guru (authenticated)
```

### 👥 User Management
```
GET  /api/teachers         # List semua guru (dengan filter tenant)
GET  /api/teacher-data/:id # Detail data guru
POST /complete-profile     # Lengkapi profile guru baru
GET  /api/students         # List siswa (filtered by tenant)
GET  /api/tenants          # List semua tenant/unit sekolah
```

### 📊 Attendance System
```
GET  /api/test-db          # Test koneksi database
POST /api/whatsapp-send    # Kirim WhatsApp notification
GET  /api/attendance-devices # List device absensi
POST /api/attendance       # Input absensi manual
```

### 📰 Content Management
```
GET  /api/news             # Berita dengan filter (limit, category, tenant)
GET  /api/blog             # Blog posts dengan filter
```

### ⚙️ Utility Endpoints
```
GET  /api/jabatan-options  # Options jabatan guru
GET  /api/sebagai-options  # Options sebagai guru
```

### 📁 Static Files
```
/admin/*                   # Admin dashboards
/guru/*                    # Teacher interfaces
/siswa/*                   # Student interfaces
/assets/*                  # Static assets (images, CSS, JS)
```

## 🏗️ Arsitektur & Struktur Proyek

### Backend (Node.js/Express)
```
├── server.js              # Main application server
├── package.json           # Dependencies & npm scripts
├── .env                   # Environment configuration
├── logs/app.log          # Application logs (auto-generated)
├── uploads/              # File uploads directory
├── ypwi_db_final.sql     # Complete database schema
├── ypwi_db.sql          # Sample data dump
└── setup-dev-db.sql     # Development database setup
```

### Frontend (Static HTML/CSS/JS)
```
├── index.html            # Landing page & dashboard
├── login.html           # Authentication page
├── complete-profile.html # Profile completion form (moved from guru/ for public access)
├── assets/              # Static assets
│   ├── images/         # Logo, gallery, icons
│   └── css/            # Additional stylesheets
├── admin/              # Admin panel pages
├── guru/               # Teacher dashboard pages
├── siswa/              # Student portal pages
├── absensi/            # Attendance system pages
└── berita/             # News & blog pages
```

### Database Schema
```
📊 Core Tables:
├── tenants              # Unit sekolah (26 tenants)
├── users               # System users dengan roles
├── teachers            # Data guru lengkap
├── students            # Data siswa
├── attendance          # Records absensi
├── attendance_devices  # Device scanner management
├── news               # Berita & pengumuman
├── grades             # Nilai siswa
└── documents          # File uploads

🔧 System Tables:
├── attendance_rules    # Aturan absensi
├── attendance_requests # Permintaan izin/sakit
├── device_otp_requests # OTP untuk device pairing
└── jabatan_options     # Master data jabatan
```

## 🔒 Security Notes

- Password menggunakan bcrypt hashing
- JWT tokens untuk authentication
- CSP headers untuk security
- Input validation di semua endpoints
- Mock WhatsApp untuk development safety

## 🗄️ Database Schema

### Multi-tenant Architecture
Aplikasi menggunakan **multi-tenant database** dengan 27 unit:

#### Pusat Management
- **YPWI Pusat** (`ypwilutim`) - Super admin & oversight

#### Unit Sekolah (26 Units)
**TKIT Wahdah Islamiyah:**
- `tkwahdah01` - TKIT Wahdah 01 Tomoni
- `tkmalili` - TKIT Wahdah 02 Malili
- `tkwasuponda` - TKIT Wahdah 03 Wasuponda
- `tkkalaena` - TKIT Wahdah 04 Kalaena
- `tkburau` - TKIT Wahdah 05 Burau
- `tkwotuu` - TKIT Wahdah 06 Wotu
- `tkmangkutana` - TKIT Wahdah 07 Mangkutana
- `tktowuti` - TKIT Wahdah 08 Towuti

**SDIT Wahdah Islamiyah:**
- `sdinsanrabbani` - SDIT Insan Rabbani
- `sdquranisorowako` - SDIT Qurani Sorowako
- `sdwahdah02tomoni` - SDIT Wahdah 02 Tomoni
- `sdburau` - SDIT Wahdah 04 Burau
- `sdkalaena` - SDIT Wahdah 05 Kalaena
- `sdwasuponda` - SDIT Wahdah 06 Wasuponda
- `sdwotuu` - SDIT Wahdah 07 Wotu
- `sdtowuti` - SDIT Wahdah 08 Towuti
- `sdmangkutana` - SDIT Wahdah 09 Mangkutana

**SMPIT Wahdah Islamiyah:**
- `smpmalili` - SMPIT Wahdah 01 Malili
- `smpkalaena` - SMPIT Wahdah 02 Kalaena

**SMAIT Wahdah Islamiyah:**
- `smatomoni` - SMAIT Wahdah 01 Tomoni

**PPTQ:**
- `pptqmalili` - PPTQ Malili
- `pptqsalman` - PPTQ Salman Alfarisi Putra
- `pptqsorowako` - PPTQ Sorowako

**Pondok Pesantren:**
- `pondokinformatika` - Pondok Informatika & Bahasa

## 🔧 Troubleshooting

### Database Issues

#### Connection Failed
```bash
# Check MySQL service status
sudo systemctl status mysql

# Start MySQL service
sudo systemctl start mysql

# Login to MySQL and verify
mysql -u root -p
SHOW DATABASES;
USE ypwi_db;
SHOW TABLES;
```

#### Import Database Schema
```bash
# Import complete schema (recommended)
mysql -u root -p < ypwi_db_final.sql

# Or setup development user first
mysql -u root -p < setup-dev-db.sql
mysql -u ypwi_dev -p ypwi_db < ypwi_db.sql
```

#### Table Missing Errors
Jika mendapat error "Table doesn't exist":
1. Pastikan sudah import `ypwi_db_final.sql`
2. Check dengan: `SHOW TABLES;`
3. Jika masih error, recreate database

### Application Issues

#### Port Already in Use
```bash
# Find process using port 3001
netstat -tulpn | grep :3001

# Kill process (replace PID)
kill -9 <PID>

# Or use npx
npx kill-port 3001
```

#### File Upload Issues
```bash
# Ensure uploads directory exists
mkdir -p uploads

# Check permissions
chmod 755 uploads
```

### Authentication Issues

#### Login Not Working
1. **Check Database**: Pastikan teacher data ada di tabel `teachers`
2. **Password Hashing**: Password sudah di-hash dengan bcrypt
3. **Email Field**: Login menggunakan field `email`
4. **Profile Completion**: Guru baru harus lengkapi profile dulu

#### JWT Token Issues
- Check `JWT_SECRET` di `.env`
- Token expire dalam 24 jam
- Pastikan token dikirim di header `Authorization: Bearer <token>`

### WhatsApp Integration

#### Development Mode (Mock)
- Aplikasi menggunakan mock mode secara default
- Semua pesan WhatsApp akan dilog tapi tidak dikirim
- Aman untuk development tanpa device ID

#### Production Setup
1. **Whacenter Setup**:
   - Login ke https://app.whacenter.com/
   - Buat device baru (Multidevice)
   - Scan QR code dengan WhatsApp
   - Copy Device ID ke `.env`

2. **Environment Variables**:
   ```env
   WHATSAPP_DEVICE_ID=your_real_device_id
   WHATSAPP_API_URL=https://app.whacenter.id/apisend
   ```

3. **Alternative**: Gunakan Fonnte API jika Whacenter unavailable

### Performance Issues

#### Slow Loading
- Check database indexes
- Monitor dengan `SHOW PROCESSLIST;`
- Enable query logging di MySQL

#### Memory Usage
- Monitor dengan `top` atau `htop`
- Check untuk memory leaks di Node.js
- Restart aplikasi jika perlu

## 💻 Development Guidelines

### Code Standards
1. **Environment Variables** - Selalu gunakan `.env` untuk konfigurasi sensitive
2. **Error Handling** - Handle semua errors dengan proper logging
3. **Database Security** - Selalu gunakan prepared statements
4. **Input Validation** - Validate semua input user
5. **Password Security** - Password di-hash dengan bcrypt

### Database Best Practices
1. **Connection Pooling** - Menggunakan mysql2 pool untuk performance
2. **Prepared Statements** - Prevent SQL injection
3. **Transaction Management** - Gunakan transactions untuk data integrity
4. **Indexing** - Pastikan fields yang sering query memiliki index

### Logging Standards
```javascript
// Use Winston logger
logger.info('User login successful', { userId, tenantId });
logger.error('Database error', { error: err.message, stack: err.stack });
logger.warn('Deprecated API usage', { endpoint, userAgent });
```

### File Upload Security
1. **File Type Validation** - Hanya allow tipe file yang aman
2. **File Size Limits** - Batasi ukuran upload
3. **Secure Storage** - Simpan di directory terproteksi
4. **Clean Filenames** - Sanitize nama file

### API Design
1. **RESTful Endpoints** - Ikuti REST conventions
2. **Consistent Response Format** - JSON dengan struktur standar
3. **Proper HTTP Status Codes** - 200, 400, 401, 403, 500
4. **Pagination** - Implement untuk large datasets
5. **Rate Limiting** - Protect dari abuse

## 🚀 Deployment Guide

### Production Setup

#### 1. Server Requirements
- **Node.js** >= 14.0.0 LTS
- **MySQL** >= 8.0 atau **MariaDB** >= 10.4
- **PM2** untuk process management
- **Nginx** sebagai reverse proxy
- **SSL Certificate** (Let's Encrypt)

#### 2. Environment Configuration
```env
NODE_ENV=production
PORT=3001
DB_HOST=localhost
DB_USER=ypwi_prod
DB_PASSWORD=strong_production_password
DB_NAME=ypwi_db
JWT_SECRET=very_strong_random_secret_key
WHATSAPP_DEVICE_ID=real_device_id_from_whacenter
LOG_LEVEL=info
```

#### 3. Database Setup
```bash
# Create production database
mysql -u root -p
CREATE DATABASE ypwi_db;
CREATE USER 'ypwi_prod'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON ypwi_db.* TO 'ypwi_prod'@'localhost';
FLUSH PRIVILEGES;

# Import schema
mysql -u ypwi_prod -p ypwi_db < ypwi_db_final.sql
```

#### 4. Application Deployment
```bash
# Install PM2 globally
npm install -g pm2

# Install dependencies
npm ci --production

# Build application (if needed)
npm run build

# Start with PM2
pm2 start server.js --name "ypwi-app"
pm2 startup
pm2 save

# Check status
pm2 status
pm2 logs ypwi-app
```

#### 5. Nginx Configuration
```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### 6. SSL Setup (Let's Encrypt)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal (add to crontab)
0 12 * * * /usr/bin/certbot renew --quiet
```

### Monitoring & Maintenance

#### Health Checks
```bash
# Application health
curl https://your-domain.com/api/test-db

# PM2 monitoring
pm2 monit

# Database monitoring
mysql -u ypwi_prod -p -e "SHOW PROCESSLIST;"
```

#### Backup Strategy
```bash
# Database backup script
mysqldump -u ypwi_prod -p ypwi_db > backup_$(date +%Y%m%d).sql

# File backup
tar -czf uploads_backup_$(date +%Y%m%d).tar.gz uploads/

# Automated backup (crontab)
0 2 * * * /path/to/backup-script.sh
```

#### Log Rotation
```bash
# PM2 log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

## 🤝 Contributing

1. Fork repository
2. Buat feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

Internal YPWI Project