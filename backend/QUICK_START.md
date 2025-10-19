# FINSTAR Backend - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install PostgreSQL

**Download and install PostgreSQL:**
1. Go to: https://www.postgresql.org/download/windows/
2. Download the installer
3. Run installer and **remember the password you set for 'postgres' user**
4. Keep default port (5432)

### Step 2: Update Configuration

1. Open `backend/.env` file
2. Update this line with YOUR password:
   ```env
   DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@localhost:5432/finstar_db?schema=public"
   ```

### Step 3: Run Setup Script

Open terminal in the `backend` folder and run:

```bash
setup-db.bat
```

This will:
- Create the database
- Set up all tables
- Configure Prisma

**Note:** If you get an error, see DATABASE_SETUP.md for detailed troubleshooting.

### Step 4: Start the Server

```bash
npm run dev
```

You should see:
```
╔════════════════════════════════════════╗
║   FINSTAR Backend API                 ║
╚════════════════════════════════════════╝

🚀 Server running on http://localhost:3000
📚 Environment: development
```

### Step 5: Test It!

Open browser: http://localhost:3000/health

You should see:
```json
{
  "success": true,
  "message": "FINSTAR API is running",
  "timestamp": "2025-01-15T..."
}
```

## ✅ You're Ready!

Your backend is now running and ready for development.

## 🔧 Useful Commands

```bash
npm run dev          # Start development server
npm run prisma:studio # Visual database browser
npm start            # Production server
```

## 📚 Next Steps

- Read `DATABASE_SETUP.md` for detailed setup
- Read `BACKEND_IMPLEMENTATION_GUIDE.md` for architecture
- Check `README.md` for API endpoints

## ❓ Need Help?

1. Can't connect to database? → Check DATABASE_SETUP.md
2. Server won't start? → Make sure PostgreSQL is running
3. Other issues? → See troubleshooting section in DATABASE_SETUP.md
