@echo off
REM ============================================
REM Crop Disease Detection - Windows Startup
REM ============================================

echo.
echo ====================================================
echo  🌾 Crop Disease Detection System
echo ====================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.8+
    pause
    exit /b 1
)

REM Check if Java is installed
java -version >nul 2>&1
if errorlevel 1 (
    echo ❌ Java not found. Please install Java 25+
    pause
    exit /b 1
)

echo ✅ Python and Java found

REM Install Flask if not already installed
echo.
echo 📦 Checking Python dependencies...
pip install flask >nul 2>&1

REM Start Python AI API in a new window
echo.
echo 🚀 Starting Python AI API (Port 5000)...
start "Crop Disease Detection - Python API" python python_ai_api.py

REM Wait for Flask to start
timeout /t 3 /nobreak

REM Start Backend
echo 🚀 Starting Backend (Port 8080)...
cd backend
start "Crop Disease Detection - Backend" mvn spring-boot:run
cd ..

REM Wait for backend to start
timeout /t 8 /nobreak

REM Open Browser
echo.
echo 🌐 Opening frontend in browser...
timeout /t 2 /nobreak
start "" http://localhost:3000/index.html

echo.
echo ====================================================
echo  ✅ All services started!
echo.
echo  📍 Python API:  http://localhost:5000
echo  📍 Backend:     http://localhost:8080
echo  📍 Frontend:    Open index.html (local file)
echo.
echo  Make sure to open index.html in your browser
echo ====================================================
echo.

pause
