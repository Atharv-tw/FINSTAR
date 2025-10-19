# FINSTAR Backend - Complete Step-by-Step Implementation Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Prerequisites](#prerequisites)
4. [Phase 1: Foundation Setup](#phase-1-foundation-setup)
5. [Phase 2: Core Features](#phase-2-core-features)
6. [Phase 3: Gamification & Social](#phase-3-gamification--social)
7. [Phase 4: Testing & Deployment](#phase-4-testing--deployment)
8. [API Reference](#api-reference)
9. [Database Schema](#database-schema)

---

## Project Overview

**FINSTAR** is a gamified financial literacy learning platform for teens. This backend will support:
- 4 interactive financial games (Life Swipe, Quiz Battle, Market Explorer, Budget Blitz)
- 5 learning modules with 25+ lessons
- User authentication and profiles
- XP/leveling system with coins
- Achievements and badges
- Daily streak tracking
- Global leaderboard

---

## Technology Stack

- **Runtime:** Node.js (v18+)
- **Framework:** Express.js
- **Database:** PostgreSQL 15+
- **ORM:** Prisma
- **Cache/Sessions:** Redis
- **Authentication:** JWT + bcrypt
- **Validation:** Joi
- **Documentation:** Swagger/OpenAPI
- **Testing:** Jest + Supertest

---

## Prerequisites

Before starting, ensure you have installed:

```bash
# Check versions
node --version    # Should be v18+
npm --version     # Should be v9+
psql --version    # PostgreSQL 15+
redis-cli --version  # Redis 7+

# Install globally if needed
npm install -g nodemon
```

---

## Phase 1: Foundation Setup

### STEP 1: Initialize Backend Project

#### 1.1 Create Project Directory
```bash
# Navigate to your project root
cd "C:\Users\tiwar\Desktop\FINSTAR APP"

# Create backend directory
mkdir backend
cd backend
```

#### 1.2 Initialize Node.js Project
```bash
npm init -y
```

#### 1.3 Install Dependencies
```bash
# Core dependencies
npm install express dotenv cors helmet morgan

# Database & ORM
npm install @prisma/client
npm install -D prisma

# Authentication
npm install bcryptjs jsonwebtoken

# Validation
npm install joi

# Redis
npm install redis

# Rate limiting
npm install express-rate-limit

# API Documentation
npm install swagger-ui-express swagger-jsdoc

# Development dependencies
npm install -D nodemon
```

#### 1.4 Create Folder Structure
```bash
mkdir src
cd src
mkdir config controllers middleware routes services utils
cd ..
mkdir prisma tests
```

**Final Structure:**
```
backend/
├── src/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── routes/
│   ├── services/
│   ├── utils/
│   └── server.js
├── prisma/
│   └── schema.prisma
├── tests/
├── .env
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

#### 1.5 Update package.json Scripts
```json
{
  "name": "finstar-backend",
  "version": "1.0.0",
  "description": "Backend API for FINSTAR financial literacy app",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "prisma:studio": "prisma studio",
    "prisma:seed": "node prisma/seed.js",
    "test": "jest"
  },
  "keywords": ["finstar", "financial", "education", "api"],
  "author": "",
  "license": "MIT"
}
```

---

### STEP 2: Environment Configuration

#### 2.1 Create .env File
```bash
# In backend/ directory
touch .env
```

#### 2.2 Add Environment Variables
```env
# Server Configuration
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database Configuration
DATABASE_URL="postgresql://postgres:password@localhost:5432/finstar_db?schema=public"

# Redis Configuration
REDIS_URL="redis://localhost:6379"
REDIS_PASSWORD=""

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production-min-32-chars
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-token-secret-change-in-production
JWT_REFRESH_EXPIRES_IN=30d

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# XP & Leveling System
BASE_XP_FOR_LEVEL_2=1000
XP_MULTIPLIER=1.5

# Game Rewards
GAME_XP_MULTIPLIER=1.0
GAME_COIN_MULTIPLIER=1.0

# Streak Rewards
STREAK_3_DAY_BONUS_XP=50
STREAK_3_DAY_BONUS_COINS=20
STREAK_7_DAY_BONUS_XP=100
STREAK_7_DAY_BONUS_COINS=50
STREAK_30_DAY_BONUS_XP=500
STREAK_30_DAY_BONUS_COINS=200

# File Upload
MAX_AVATAR_SIZE_MB=5
UPLOAD_PATH=./uploads
```

#### 2.3 Create .env.example
```bash
cp .env .env.example
# Then manually replace sensitive values with placeholders
```

#### 2.4 Create .gitignore
```
node_modules/
.env
uploads/
*.log
.DS_Store
dist/
build/
coverage/
prisma/migrations/
```

---

### STEP 3: Database Schema with Prisma

#### 3.1 Initialize Prisma
```bash
npx prisma init
```

#### 3.2 Configure prisma/schema.prisma
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============================================
// USER MANAGEMENT
// ============================================

model User {
  id              String    @id @default(uuid())
  username        String    @unique
  email           String    @unique
  password        String    // Hashed with bcrypt
  avatarUrl       String?

  // Gamification
  level           Int       @default(1)
  currentXp       Int       @default(0)
  totalXp         Int       @default(0)
  coins           Int       @default(0)

  // Streak Tracking
  streakDays      Int       @default(0)
  lastActiveDate  DateTime  @default(now())

  // Metadata
  joinDate        DateTime  @default(now())
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // Relations
  gameProgress    GameProgress[]
  gameResults     GameResult[]
  lessonProgress  LessonProgress[]
  achievements    UserAchievement[]
  streakHistory   StreakHistory[]

  @@index([totalXp(sort: Desc)]) // For leaderboard queries
  @@index([username])
  @@index([email])
}

// ============================================
// GAME SYSTEM
// ============================================

model GameProgress {
  id              String    @id @default(uuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  gameId          String    // "life_swipe", "quiz_battle", "market_explorer", "budget_blitz"
  gameName        String
  highScore       Int       @default(0)
  timesPlayed     Int       @default(0)
  lastPlayed      DateTime  @default(now())
  isCompleted     Boolean   @default(false)
  gameData        Json?     // Game-specific persistent data

  // Relations
  results         GameResult[]

  @@unique([userId, gameId])
  @@index([userId])
  @@index([gameId])
}

model GameResult {
  id              String    @id @default(uuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  gameProgressId  String
  gameProgress    GameProgress @relation(fields: [gameProgressId], references: [id], onDelete: Cascade)

  gameId          String
  score           Int
  xpEarned        Int
  coinsEarned     Int
  resultData      Json      // Detailed game-specific results
  playedAt        DateTime  @default(now())

  @@index([userId])
  @@index([gameId])
  @@index([playedAt(sort: Desc)])
}

// ============================================
// LEARNING SYSTEM
// ============================================

model LearningModule {
  id              String    @id @default(uuid())
  moduleId        String    @unique // "money_basics", "banking", etc.
  title           String
  description     String
  totalXp         Int
  iconPath        String?
  gradientColors  Json      // Array of hex colors ["#4A90E2", "#50E3C2"]
  order           Int       @default(0)
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // Relations
  lessons         Lesson[]

  @@index([order])
}

model Lesson {
  id              String    @id @default(uuid())
  lessonId        String    @unique // "mb_01", "mb_02", etc.
  moduleId        String
  module          LearningModule @relation(fields: [moduleId], references: [id], onDelete: Cascade)

  title           String
  description     String
  xpReward        Int
  estimatedMinutes Int
  content         Json      // Array of lesson content objects
  order           Int       @default(0)

  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // Relations
  progress        LessonProgress[]

  @@index([moduleId])
  @@index([order])
}

model LessonProgress {
  id              String    @id @default(uuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  lessonId        String
  lesson          Lesson    @relation(fields: [lessonId], references: [id], onDelete: Cascade)

  isCompleted     Boolean   @default(false)
  completedAt     DateTime?
  xpEarned        Int       @default(0)

  @@unique([userId, lessonId])
  @@index([userId])
  @@index([lessonId])
}

// ============================================
// QUIZ SYSTEM
// ============================================

model QuizQuestion {
  id              String    @id @default(uuid())
  questionId      String    @unique
  question        String
  options         Json      // Array of strings
  correctAnswerIndex Int
  difficulty      String    // "easy", "medium", "hard"
  category        String    // "budgeting", "saving", "investing", etc.
  explanation     String
  points          Int

  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  @@index([difficulty])
  @@index([category])
}

// ============================================
// ACHIEVEMENT SYSTEM
// ============================================

model Achievement {
  id              String    @id @default(uuid())
  achievementId   String    @unique // "first_lesson", "week_streak", etc.
  title           String
  description     String
  icon            String    // Icon identifier
  color           String    // Hex color
  category        String    // "learning", "gaming", "streak", "social", "level"
  requirement     Json      // Conditions to unlock { type, value, comparison }

  createdAt       DateTime  @default(now())

  // Relations
  userAchievements UserAchievement[]

  @@index([category])
}

model UserAchievement {
  id              String    @id @default(uuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  achievementId   String
  achievement     Achievement @relation(fields: [achievementId], references: [id], onDelete: Cascade)

  unlockedAt      DateTime  @default(now())

  @@unique([userId, achievementId])
  @@index([userId])
  @@index([unlockedAt(sort: Desc)])
}

// ============================================
// STREAK SYSTEM
// ============================================

model StreakHistory {
  id              String    @id @default(uuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  date            DateTime  @db.Date
  activityType    String    // "lesson", "game", "quiz", "login"
  activityId      String?   // Optional reference to specific activity

  @@unique([userId, date])
  @@index([userId, date(sort: Desc)])
}
```

#### 3.3 Create Database
```bash
# Using PostgreSQL command line
psql -U postgres

# In psql console
CREATE DATABASE finstar_db;
\q
```

#### 3.4 Run Prisma Migrations
```bash
npx prisma migrate dev --name init
npx prisma generate
```

---

### STEP 4: Basic Server Setup

#### 4.1 Create src/config/database.js
```javascript
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

// Test database connection
async function connectDatabase() {
  try {
    await prisma.$connect();
    console.log('✅ Database connected successfully');
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  }
}

// Graceful shutdown
async function disconnectDatabase() {
  await prisma.$disconnect();
  console.log('Database disconnected');
}

module.exports = { prisma, connectDatabase, disconnectDatabase };
```

#### 4.2 Create src/config/redis.js
```javascript
const redis = require('redis');

const redisClient = redis.createClient({
  url: process.env.REDIS_URL,
  password: process.env.REDIS_PASSWORD || undefined,
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error:', err);
});

redisClient.on('connect', () => {
  console.log('✅ Redis connected successfully');
});

async function connectRedis() {
  try {
    await redisClient.connect();
  } catch (error) {
    console.error('❌ Redis connection failed:', error);
    console.log('⚠️  Continuing without Redis cache...');
  }
}

module.exports = { redisClient, connectRedis };
```

#### 4.3 Create src/config/constants.js
```javascript
module.exports = {
  // XP System
  BASE_XP_FOR_LEVEL_2: parseInt(process.env.BASE_XP_FOR_LEVEL_2) || 1000,
  XP_MULTIPLIER: parseFloat(process.env.XP_MULTIPLIER) || 1.5,

  // Game IDs
  GAMES: {
    LIFE_SWIPE: 'life_swipe',
    QUIZ_BATTLE: 'quiz_battle',
    MARKET_EXPLORER: 'market_explorer',
    BUDGET_BLITZ: 'budget_blitz',
  },

  // Streak Milestones
  STREAK_MILESTONES: {
    3: { xp: 50, coins: 20 },
    7: { xp: 100, coins: 50 },
    14: { xp: 200, coins: 100 },
    30: { xp: 500, coins: 200 },
  },

  // Achievement Categories
  ACHIEVEMENT_CATEGORIES: {
    LEARNING: 'learning',
    GAMING: 'gaming',
    STREAK: 'streak',
    SOCIAL: 'social',
    LEVEL: 'level',
  },

  // API Response Codes
  STATUS_CODES: {
    SUCCESS: 200,
    CREATED: 201,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    FORBIDDEN: 403,
    NOT_FOUND: 404,
    CONFLICT: 409,
    SERVER_ERROR: 500,
  },
};
```

#### 4.4 Create src/middleware/errorHandler.js
```javascript
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Prisma errors
  if (err.code === 'P2002') {
    return res.status(409).json({
      success: false,
      error: {
        code: 'DUPLICATE_ENTRY',
        message: 'This record already exists',
        details: err.meta,
      },
    });
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      error: {
        code: 'INVALID_TOKEN',
        message: 'Invalid authentication token',
      },
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      error: {
        code: 'TOKEN_EXPIRED',
        message: 'Authentication token has expired',
      },
    });
  }

  // Validation errors
  if (err.isJoi) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid input data',
        details: err.details.map((d) => ({
          field: d.path.join('.'),
          message: d.message,
        })),
      },
    });
  }

  // Default error
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    error: {
      code: err.code || 'SERVER_ERROR',
      message: err.message || 'An unexpected error occurred',
    },
  });
};

module.exports = errorHandler;
```

#### 4.5 Create src/server.js
```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { connectDatabase, disconnectDatabase } = require('./config/database');
const { connectRedis } = require('./config/redis');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'FINSTAR API is running',
    timestamp: new Date().toISOString(),
  });
});

// API Routes (will add in next steps)
app.get('/api/v1', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to FINSTAR API v1',
    version: '1.0.0',
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: 'The requested endpoint does not exist',
    },
  });
});

// Error handler (must be last)
app.use(errorHandler);

// Start server
async function startServer() {
  try {
    await connectDatabase();
    await connectRedis();

    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📚 Environment: ${process.env.NODE_ENV}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Shutting down gracefully...');
  await disconnectDatabase();
  process.exit(0);
});

startServer();
```

#### 4.6 Test Basic Setup
```bash
# Start development server
npm run dev

# Test in browser or using curl
curl http://localhost:3000/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "FINSTAR API is running",
  "timestamp": "2025-01-XX..."
}
```

---

## Phase 2: Core Features

### STEP 5: Authentication System

#### 5.1 Create src/utils/jwt.js
```javascript
const jwt = require('jsonwebtoken');

function generateAccessToken(userId) {
  return jwt.sign(
    { userId, type: 'access' },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
}

function generateRefreshToken(userId) {
  return jwt.sign(
    { userId, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN }
  );
}

function verifyAccessToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

function verifyRefreshToken(token) {
  return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
}

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
};
```

#### 5.2 Create src/utils/bcrypt.js
```javascript
const bcrypt = require('bcryptjs');

async function hashPassword(password) {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
}

async function comparePassword(password, hashedPassword) {
  return bcrypt.compare(password, hashedPassword);
}

module.exports = {
  hashPassword,
  comparePassword,
};
```

#### 5.3 Create src/middleware/auth.js
```javascript
const { verifyAccessToken } = require('../utils/jwt');

function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'NO_TOKEN',
          message: 'No authentication token provided',
        },
      });
    }

    const token = authHeader.substring(7);
    const decoded = verifyAccessToken(token);

    req.userId = decoded.userId;
    next();
  } catch (error) {
    next(error);
  }
}

module.exports = { authenticate };
```

#### 5.4 Create src/middleware/validation.js
```javascript
const Joi = require('joi');

function validate(schema) {
  return (req, res, next) => {
    const { error } = schema.validate(req.body, { abortEarly: false });

    if (error) {
      error.isJoi = true;
      return next(error);
    }

    next();
  };
}

// Validation schemas
const schemas = {
  register: Joi.object({
    username: Joi.string().alphanum().min(3).max(20).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(6).max(100).required(),
  }),

  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required(),
  }),

  updateProfile: Joi.object({
    username: Joi.string().alphanum().min(3).max(20),
    avatarUrl: Joi.string().uri(),
  }).min(1),
};

module.exports = { validate, schemas };
```

#### 5.5 Create src/services/auth.service.js
```javascript
const { prisma } = require('../config/database');
const { hashPassword, comparePassword } = require('../utils/bcrypt');
const { generateAccessToken, generateRefreshToken } = require('../utils/jwt');

class AuthService {
  async register({ username, email, password }) {
    // Check if user exists
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ email }, { username }],
      },
    });

    if (existingUser) {
      const error = new Error(
        existingUser.email === email ? 'Email already in use' : 'Username already taken'
      );
      error.statusCode = 409;
      error.code = 'USER_EXISTS';
      throw error;
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user
    const user = await prisma.user.create({
      data: {
        username,
        email,
        password: hashedPassword,
      },
      select: {
        id: true,
        username: true,
        email: true,
        level: true,
        totalXp: true,
        coins: true,
        streakDays: true,
        joinDate: true,
      },
    });

    // Generate tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    return { user, accessToken, refreshToken };
  }

  async login({ email, password }) {
    // Find user
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      const error = new Error('Invalid credentials');
      error.statusCode = 401;
      error.code = 'INVALID_CREDENTIALS';
      throw error;
    }

    // Verify password
    const isValidPassword = await comparePassword(password, user.password);

    if (!isValidPassword) {
      const error = new Error('Invalid credentials');
      error.statusCode = 401;
      error.code = 'INVALID_CREDENTIALS';
      throw error;
    }

    // Generate tokens
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Remove password from response
    delete user.password;

    return { user, accessToken, refreshToken };
  }
}

module.exports = new AuthService();
```

#### 5.6 Create src/controllers/auth.controller.js
```javascript
const authService = require('../services/auth.service');

class AuthController {
  async register(req, res, next) {
    try {
      const result = await authService.register(req.body);

      res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  async login(req, res, next) {
    try {
      const result = await authService.login(req.body);

      res.json({
        success: true,
        message: 'Login successful',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController();
```

#### 5.7 Create src/routes/auth.routes.js
```javascript
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validate, schemas } = require('../middleware/validation');

router.post('/register', validate(schemas.register), authController.register);
router.post('/login', validate(schemas.login), authController.login);

module.exports = router;
```

#### 5.8 Update src/server.js - Add Auth Routes
```javascript
// Add after other imports
const authRoutes = require('./routes/auth.routes');

// Add after health check, before 404 handler
app.use('/api/v1/auth', authRoutes);
```

#### 5.9 Test Authentication
```bash
# Register new user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

---

### STEP 6: User Profile & XP System

#### 6.1 Create src/services/xp.service.js
```javascript
const { BASE_XP_FOR_LEVEL_2, XP_MULTIPLIER } = require('../config/constants');

class XPService {
  calculateLevel(totalXp) {
    let level = 1;
    let xpRequired = BASE_XP_FOR_LEVEL_2;
    let accumulatedXp = 0;

    while (totalXp >= accumulatedXp + xpRequired) {
      accumulatedXp += xpRequired;
      level++;
      xpRequired = Math.floor(xpRequired * XP_MULTIPLIER);
    }

    return {
      level,
      currentXp: totalXp - accumulatedXp,
      xpForNextLevel: xpRequired,
    };
  }

  async addXP(userId, xpAmount, prisma) {
    // Get current user
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { totalXp: true, level: true },
    });

    const newTotalXp = user.totalXp + xpAmount;
    const levelData = this.calculateLevel(newTotalXp);

    // Update user
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        totalXp: newTotalXp,
        currentXp: levelData.currentXp,
        level: levelData.level,
      },
      select: {
        id: true,
        username: true,
        level: true,
        currentXp: true,
        totalXp: true,
        coins: true,
      },
    });

    const leveledUp = levelData.level > user.level;

    return {
      user: updatedUser,
      xpGained: xpAmount,
      leveledUp,
      newLevel: levelData.level,
      xpForNextLevel: levelData.xpForNextLevel,
    };
  }
}

module.exports = new XPService();
```

#### 6.2 Create src/services/user.service.js
```javascript
const { prisma } = require('../config/database');

class UserService {
  async getProfile(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        email: true,
        avatarUrl: true,
        level: true,
        currentXp: true,
        totalXp: true,
        coins: true,
        streakDays: true,
        lastActiveDate: true,
        joinDate: true,
        achievements: {
          include: {
            achievement: true,
          },
        },
      },
    });

    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      error.code = 'USER_NOT_FOUND';
      throw error;
    }

    return user;
  }

  async updateProfile(userId, data) {
    const user = await prisma.user.update({
      where: { id: userId },
      data,
      select: {
        id: true,
        username: true,
        email: true,
        avatarUrl: true,
        level: true,
        totalXp: true,
        coins: true,
      },
    });

    return user;
  }

  async getUserStats(userId) {
    // Get games played
    const gamesPlayed = await prisma.gameResult.count({
      where: { userId },
    });

    // Get lessons completed
    const lessonsCompleted = await prisma.lessonProgress.count({
      where: { userId, isCompleted: true },
    });

    // Get achievements unlocked
    const achievementsUnlocked = await prisma.userAchievement.count({
      where: { userId },
    });

    // Get modules progress
    const modulesProgress = await prisma.$queryRaw`
      SELECT
        lm.module_id as "moduleId",
        lm.title,
        COUNT(DISTINCT l.id) as "totalLessons",
        COUNT(DISTINCT lp.lesson_id) as "completedLessons"
      FROM learning_module lm
      LEFT JOIN lesson l ON l.module_id = lm.id
      LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.user_id = ${userId} AND lp.is_completed = true
      GROUP BY lm.module_id, lm.title
      ORDER BY lm."order"
    `;

    return {
      gamesPlayed,
      lessonsCompleted,
      achievementsUnlocked,
      modulesProgress,
    };
  }
}

module.exports = new UserService();
```

#### 6.3 Create src/controllers/user.controller.js
```javascript
const userService = require('../services/user.service');

class UserController {
  async getProfile(req, res, next) {
    try {
      const user = await userService.getProfile(req.userId);

      res.json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  async updateProfile(req, res, next) {
    try {
      const user = await userService.updateProfile(req.userId, req.body);

      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  async getStats(req, res, next) {
    try {
      const stats = await userService.getUserStats(req.userId);

      res.json({
        success: true,
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new UserController();
```

#### 6.4 Create src/routes/user.routes.js
```javascript
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validation');

// All routes require authentication
router.use(authenticate);

router.get('/me', userController.getProfile);
router.put('/me', validate(schemas.updateProfile), userController.updateProfile);
router.get('/me/stats', userController.getStats);

module.exports = router;
```

#### 6.5 Update src/server.js - Add User Routes
```javascript
const userRoutes = require('./routes/user.routes');
app.use('/api/v1/users', userRoutes);
```

---

### STEP 7: Game System

*(Continue with detailed implementation for Games, Learning, Quiz, Leaderboard, Achievements, and Streaks in similar detailed format...)*

**Due to character limits, I'll provide the remaining steps in summary format. Each follows the same pattern:**

1. Create service file with business logic
2. Create controller for handling requests
3. Create routes with validation
4. Add routes to server.js
5. Test endpoints

---

## Remaining Steps Summary

### STEP 7: Game Progress & Results
- Files: `game.service.js`, `game.controller.js`, `game.routes.js`
- Endpoints: `GET /games/progress`, `POST /games/:gameId/results`

### STEP 8: Learning Modules
- Files: `learning.service.js`, `learning.controller.js`, `learning.routes.js`
- Endpoints: `GET /learning/modules`, `POST /lessons/:id/complete`

### STEP 9: Quiz System
- Files: `quiz.service.js`, `quiz.controller.js`, `quiz.routes.js`
- Endpoints: `GET /quiz/questions`, `POST /quiz/submit`

### STEP 10: Leaderboard
- Files: `leaderboard.service.js`, `leaderboard.controller.js`, `leaderboard.routes.js`
- Endpoints: `GET /leaderboard`, `GET /leaderboard/me`
- Uses Redis caching

### STEP 11: Achievement System
- Files: `achievement.service.js`, `achievement.controller.js`, `achievement.routes.js`
- Endpoints: `GET /achievements`, `GET /achievements/me`
- Auto-detection on XP/game/lesson completion

### STEP 12: Streak Tracking
- Files: `streak.service.js`, `streak.controller.js`, `streak.routes.js`
- Endpoints: `GET /streaks/current`, `POST /streaks/check-in`
- Daily activity tracking

---

## Phase 3: Data Seeding

### Create prisma/seed.js
```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Seed Learning Modules
  // Seed Quiz Questions
  // Seed Achievements

  console.log('✅ Database seeded successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

Run: `npm run prisma:seed`

---

## Phase 4: Testing & Deployment

### Testing
```bash
npm install -D jest supertest
```

Create tests for each endpoint.

### Documentation
Add Swagger documentation in `src/config/swagger.js`

### Deployment
- Set up production environment variables
- Deploy to Railway/Render/Heroku
- Set up PostgreSQL and Redis instances
- Run migrations in production

---

## API Endpoints Reference

### Authentication
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`

### Users
- `GET /api/v1/users/me`
- `PUT /api/v1/users/me`
- `GET /api/v1/users/me/stats`

### Games
- `GET /api/v1/games/progress`
- `POST /api/v1/games/:gameId/results`
- `GET /api/v1/games/:gameId/leaderboard`

### Learning
- `GET /api/v1/learning/modules`
- `GET /api/v1/learning/modules/:moduleId`
- `POST /api/v1/learning/lessons/:lessonId/complete`

### Quiz
- `GET /api/v1/quiz/questions`
- `POST /api/v1/quiz/submit`

### Leaderboard
- `GET /api/v1/leaderboard`
- `GET /api/v1/leaderboard/me`

### Achievements
- `GET /api/v1/achievements`
- `GET /api/v1/achievements/me`

### Streaks
- `GET /api/v1/streaks/current`
- `POST /api/v1/streaks/check-in`

---

## Next Steps

1. Complete Phase 1 (Steps 1-4) - Foundation
2. Implement authentication (Step 5)
3. Build remaining features incrementally
4. Test thoroughly
5. Deploy to production

**Estimated Timeline: 12-17 days**

---

## Support & Resources

- Prisma Docs: https://www.prisma.io/docs
- Express.js: https://expressjs.com
- JWT: https://jwt.io
- PostgreSQL: https://www.postgresql.org/docs

---

**Document Version:** 1.0
**Last Updated:** January 2025
**Status:** Ready for Implementation
