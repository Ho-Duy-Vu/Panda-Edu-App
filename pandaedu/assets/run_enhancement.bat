@echo off
REM PandaEdu Image Enhancement - Auto Setup and Run
REM ==============================================

echo.
echo ============================================
echo   PandaEdu Image Enhancement Tool
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH!
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)

echo [1/3] Python detected: 
python --version
echo.

REM Install requirements
echo [2/3] Installing required packages...
echo This may take a few minutes...
echo.
pip install -q -r requirements.txt

if errorlevel 1 (
    echo [ERROR] Failed to install packages!
    pause
    exit /b 1
)

echo.
echo [SUCCESS] All packages installed!
echo.

REM Run the enhancement script
echo [3/3] Processing images...
echo.
python enhance_simple.py

echo.
echo ============================================
echo   DONE! Check 'images_enhanced' folder
echo ============================================
echo.
pause

