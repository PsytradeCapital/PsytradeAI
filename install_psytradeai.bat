@echo off
echo ========================================
echo PsyTradeAI Installation Script
echo ========================================
echo.

REM Find MetaTrader data folder
set "MT5_DATA="
for /d %%i in ("%APPDATA%\MetaQuotes\Terminal\*") do (
    if exist "%%i\MQL5" (
        set "MT5_DATA=%%i"
        goto :found
    )
)

:found
if "%MT5_DATA%"=="" (
    echo ERROR: Could not find MetaTrader 5 data folder!
    echo Please make sure MetaTrader 5 is installed and has been run at least once.
    echo.
    echo Manual path: %APPDATA%\MetaQuotes\Terminal\
    pause
    exit /b 1
)

echo Found MetaTrader 5 data folder:
echo %MT5_DATA%
echo.

REM Check if source files exist
if not exist "src\Experts\PsyTradeAI_EA.mq5" (
    echo ERROR: Cannot find src\Experts\PsyTradeAI_EA.mq5
    echo Make sure you're running this script from the PsyTradeAI project folder.
    pause
    exit /b 1
)

if not exist "src\Include\SMCDetector.mqh" (
    echo ERROR: Cannot find include files in src\Include\
    echo Make sure all .mqh files are present.
    pause
    exit /b 1
)

echo Copying files...
echo.

REM Create directories if they don't exist
if not exist "%MT5_DATA%\MQL5\Experts" mkdir "%MT5_DATA%\MQL5\Experts"
if not exist "%MT5_DATA%\MQL5\Include" mkdir "%MT5_DATA%\MQL5\Include"

REM Copy EA file
echo Copying PsyTradeAI_EA.mq5...
copy "src\Experts\PsyTradeAI_EA.mq5" "%MT5_DATA%\MQL5\Experts\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy EA file!
    pause
    exit /b 1
)

REM Copy include files
echo Copying include files...
copy "src\Include\*.mqh" "%MT5_DATA%\MQL5\Include\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy include files!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation Complete! ✅
echo ========================================
echo.
echo Files copied to:
echo %MT5_DATA%\MQL5\
echo.
echo Next steps:
echo 1. Open MetaTrader 5
echo 2. Press F4 to open MetaEditor
echo 3. Open PsyTradeAI_EA.mq5 from Experts folder
echo 4. Press F7 to compile
echo 5. Go back to MetaTrader and find the EA in Navigator
echo.
echo For detailed instructions, see INSTALL_GUIDE.md
echo.
pause