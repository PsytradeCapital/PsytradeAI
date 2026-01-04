@echo off
echo ========================================
echo Testing Include Files Compilation
echo ========================================

echo Copying include files to MetaTrader...

REM Copy include files
copy "src\Include\*.mqh" "%APPDATA%\MetaQuotes\Terminal\Common\Files\Include\" /Y

echo.
echo Include files copied!
echo.
echo NEXT STEPS:
echo 1. Open MetaTrader 5
echo 2. Press F4 to open MetaEditor
echo 3. Try to compile any include file to test
echo 4. Check for compilation errors
echo.
echo Files copied:
echo - RiskManager.mqh
echo - TradeManager.mqh  
echo - SMCDetector.mqh
echo - PerformanceTracker.mqh
echo - PropFirmManager.mqh
echo - PsychologyManager.mqh
echo - NewsManager.mqh
echo.
pause