# YPWI Web Application - Application Flow & Architecture

## 📋 Overview

Aplikasi web YPWI adalah sistem manajemen sekolah multi-tenant yang terintegrasi untuk 26 unit sekolah Yayasan Pesantren Wahdah Islamiyah Luwu Timur.

## 🏛️ System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    YPWI Web Application                         │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │   Frontend  │    │   Backend   │    │     Database        │  │
│  │   (HTML/JS) │◄──►│ (Node.js)   │◄──►│     (MySQL)        │  │
│  │             │    │             │    │                     │  │
│  │ • Landing   │    │ • REST API  │    │ • Multi-tenant DB   │  │
│  │ • Dashboards│    │ • Auth      │    │ • 27 Tenants        │  │
│  │ • Forms     │    │ • File Upload│    │ • User Management  │  │
│  └─────────────┘    └─────────────┘    └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                                                      │
┌─────────────────────────────────────────────────────────────────┐   │
│                    External Integrations                         │   │
│                                                                 │   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │   │
│  │ WhatsApp API│    │   File      │    │   Authentication    │  │   │
│  │ (Whacenter) │    │  Storage    │    │     (JWT)          │  │   │
│  └─────────────┘    └─────────────┘    └─────────────────────┘  │   │
└─────────────────────────────────────────────────────────────────┘   ▼
```

## 🔄 Application Flow

### 1. User Authentication Flow

```mermaid
graph TD
    A[User Access Website] --> B[Landing Page]
    B --> C[Click Login]
    C --> D[Login Form]
    D --> E[Submit Email/Password]
    E --> F{Valid Credentials?}

    F -->|Yes| G[Check Profile Completion]
    F -->|No| H[Show Error Message]

    G --> I{Profile Complete?}
    I -->|Yes| J[Generate JWT Token]
    I -->|No| K[Redirect to Complete Profile]

    J --> L[Login Success]
    K --> M[Complete Profile Form]
    M --> N[Submit Profile Data]
    N --> O[Generate JWT Token]
    O --> L

    L --> P[Redirect to Dashboard]
```

### 2. Multi-tenant Data Flow

```mermaid
graph TD
    A[User Login] --> B{JWT Token Valid?}
    B -->|Yes| C[Extract Tenant ID from Token]
    B -->|No| D[Unauthorized Error]

    C --> E[Database Query with Tenant Filter]
    E --> F{Data Exists for Tenant?}
    F -->|Yes| G[Return Tenant-specific Data]
    F -->|No| H[Return Empty Result]

    G --> I[Render Dashboard]
    H --> J[Show 'No Data' Message]
```

### 3. Attendance System Flow

```mermaid
graph TD
    A[Teacher/Siswa] --> B[Scan QR Code]
    B --> C[Device Captures Data]
    C --> D[Send to Server API]

    D --> E{Device Registered?}
    E -->|No| F[Device Registration Required]
    E -->|Yes| G[Validate Attendance Rules]

    G --> H{Check Time Rules}
    H -->|On Time| I[Mark as Present]
    H -->|Late| J[Mark as Late + Notification]
    H -->|Early| K[Mark as Early Leave]

    I --> L[Send WhatsApp Confirmation]
    J --> L
    K --> L

    L --> M{WhatsApp Success?}
    M -->|Yes| N[Log Success]
    M -->|No| O[Log Failure + Retry Queue]

    N --> P[Update Dashboard]
    O --> Q[Queue for Retry]
```

### 4. Content Management Flow

```mermaid
graph TD
    A[Admin/Guru] --> B[Access CMS]
    B --> C{User Role?}

    C -->|Admin| D[Full CMS Access]
    C -->|Guru| E[Limited to Blog]

    D --> F{Action Type?}
    E --> G{Action Type?}

    F -->|Create News| H[News Editor]
    F -->|Manage Blog| I[Blog Management]
    F -->|Upload Files| J[File Upload]

    G -->|Write Article| K[Blog Editor]
    G -->|Upload Images| L[Image Upload]

    H --> M[Save to Database]
    I --> M
    J --> N[Save to File System]
    K --> O[Save with Author ID]
    L --> N

    M --> P[Update Frontend]
    N --> P
    O --> P
```

## 📊 Database Relationships

### Core Entity Relationships

```mermaid
erDiagram
    TENANTS ||--o{ TEACHERS : contains
    TENANTS ||--o{ STUDENTS : contains
    TENANTS ||--o{ NEWS : publishes
    TENANTS ||--o{ ATTENDANCE_DEVICES : manages

    TEACHERS ||--o{ ATTENDANCE : records
    TEACHERS ||--o{ ATTENDANCE_REQUESTS : submits
    TEACHERS ||--o{ DOCUMENTS : uploads
    TEACHERS ||--o{ GRADES : inputs

    STUDENTS ||--o{ GRADES : receives
    STUDENTS ||--o{ ATTENDANCE : tracked

    ATTENDANCE_DEVICES ||--o{ ATTENDANCE : generates
    ATTENDANCE_RULES ||--o{ ATTENDANCE : validates

    USERS ||--|| TEACHERS : extends
```

### Multi-tenant Isolation

```mermaid
graph TD
    A[Tenant: tkmalili] --> B[Teachers from Malili only]
    A --> C[Students from Malili only]
    A --> D[News tagged with tkmalili]

    E[Tenant: smatomoni] --> F[Teachers from Tomoni only]
    E --> G[Students from Tomoni only]
    E --> H[News tagged with smatomoni]

    I[Tenant: ypwilutim] --> J[Central admin users]
    I --> K[System-wide news]
    I --> L[Cross-tenant reports]
```

## 🔐 Security Flow

### Authentication & Authorization

```mermaid
graph TD
    A[User Request] --> B[JWT Token in Header?]
    B -->|No| C[401 Unauthorized]
    B -->|Yes| D[Verify JWT Signature]

    D --> E{Valid Token?}
    E -->|No| C
    E -->|Yes| F[Extract User Info]

    F --> G[Check User Role]
    G --> H{Authorized for Resource?}
    H -->|No| I[403 Forbidden]
    H -->|Yes| J[Check Tenant Access]

    J --> K{Tenant Match?}
    K -->|No| I
    K -->|Yes| L[Allow Access]

    L --> M[Process Request]
    M --> N[Return Response]
```

### File Upload Security

```mermaid
graph TD
    A[File Upload Request] --> B[Check File Type]
    B --> C{Allowed Type?}
    C -->|No| D[Reject Upload]

    C -->|Yes| E[Check File Size]
    E --> F{Under Limit?}
    F -->|No| D

    F -->|Yes| G[Sanitize Filename]
    G --> H[Generate Unique Name]
    H --> I[Save to Secure Directory]

    I --> J[Update Database Record]
    J --> K[Return Success Response]

    D --> L[Return Error Message]
```

## 📱 API Request Flow

### Typical API Call Sequence

```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Database
    participant WhatsApp

    Client->>Server: POST /api/login
    Server->>Database: SELECT * FROM teachers WHERE email = ?
    Database-->>Server: User data
    Server->>Server: Verify bcrypt password
    Server->>Server: Generate JWT token
    Server-->>Client: { success: true, token: "..." }

    Client->>Server: GET /api/news (with Authorization header)
    Server->>Server: Verify JWT token
    Server->>Database: SELECT * FROM news WHERE tenant_id = ? OR tenant_id IS NULL
    Database-->>Server: News data
    Server-->>Client: [{ title: "...", content: "..." }]

    Client->>Server: POST /api/whatsapp-send
    Server->>Server: Check NODE_ENV
    Server->>WhatsApp: Send message (production only)
    Server-->>Client: { status: "success" }
```

## 🔄 Data Synchronization Flow

### Cross-tenant Data Access

```mermaid
graph TD
    A[Multi-unit Teacher] --> B[Login to System]
    B --> C[JWT contains accessible_units array]
    C --> D[Query data from multiple tenants]

    D --> E[Tenant: tkmalili]
    D --> F[Tenant: sdtomoni]
    D --> G[Tenant: smpmalili]

    E --> H[Aggregate Results]
    F --> H
    G --> H

    H --> I[Return Unified Data]
    I --> J[Display in Dashboard]
```

## 📈 Performance Optimization Flow

### Database Query Optimization

```mermaid
graph TD
    A[API Request] --> B[Check Query Cache]
    B --> C{Cache Hit?}
    C -->|Yes| D[Return Cached Result]

    C -->|No| E[Execute Database Query]
    E --> F[Apply Tenant Filter]
    F --> G[Use Indexed Fields]

    G --> H{Result Size}
    H -->|Large| I[Implement Pagination]
    H -->|Small| J[Return Full Result]

    I --> K[Cache Result]
    J --> K

    K --> D
    D --> L[Return to Client]
```

## 🚨 Error Handling Flow

### Comprehensive Error Management

```mermaid
graph TD
    A[Error Occurs] --> B{Error Type?}

    B -->|Database Error| C[Log to Winston]
    B -->|Authentication Error| D[Return 401/403]
    B -->|Validation Error| E[Return 400 with details]
    B -->|File Upload Error| F[Clean up partial uploads]

    C --> G[Check Error Severity]
    D --> H[Return JSON error]
    E --> H
    F --> I[Log cleanup action]

    G -->|Critical| J[Alert Admin]
    G -->|Warning| K[Log only]

    H --> L[Client handles error]
    I --> L
    J --> M[Send notification]
    K --> L

    M --> L
```

## 📋 Development Workflow

### Feature Development Cycle

```mermaid
graph TD
    A[New Feature Request] --> B[Create Issue/Task]
    B --> C[Design API/Database changes]
    C --> D[Implement Backend Logic]

    D --> E[Write Unit Tests]
    E --> F{Tests Pass?}
    F -->|No| G[Fix Issues]
    F -->|Yes| H[Implement Frontend]

    G --> E
    H --> I[Integration Testing]
    I --> J{Integration OK?}
    J -->|No| K[Debug Integration]
    J -->|Yes| L[Code Review]

    K --> I
    L --> M{Merge Approved?}
    M -->|No| N[Address Review Comments]
    M -->|Yes| O[Deploy to Staging]

    N --> L
    O --> P[User Acceptance Testing]
    P --> Q{UAT Passed?}
    Q -->|No| R[Fix UAT Issues]
    Q -->|Yes| S[Deploy to Production]

    R --> P
    S --> T[Monitor & Support]
```

---

## 📚 Additional Documentation

- [API Documentation](./api-docs.md)
- [Database Schema](./database-schema.md)
- [Deployment Guide](./deployment.md)
- [Security Guidelines](./security.md)
- [Troubleshooting](./troubleshooting.md)