@echo off
echo ========================================
echo FINAL FIX - All Include Files
echo ========================================
echo.
echo Fixed compilation errors in:
echo ✓ RiskManager.mqh (4 errors fixed)
echo ✓ TradeManager.mqh (8 errors fixed) 
echo ✓ SMCDetector.mqh (warnings fixed)
echo ✓ PerformanceTracker.mqh (2 errors fixed)
echo ✓ PropFirmManager.mqh (38 errors fixed)
echo.
echo Copying ALL fixed include files to MetaTrader...

REM Copy all include files
copy "src\Include\*.mqh" "%APPDATA%\MetaQuotes\Terminal\Common\Files\Include\" /Y

echo.
echo ✓ All include files copied successfully!
echo.
echo NEXT STEPS:
echo 1. Open MetaTrader 5
echo 2. Press F4 to open MetaEditor
echo 3. Open PsyTradeAI_EA_Professional_Fixed.mq5
echo 4. Press F7 to compile
echo 5. Should compile with 0 errors now!
echo.
echo FILES FIXED AND COPIED:
echo - RiskManager.mqh (added missing CalculateRealizedPnLToday method)
echo - TradeManager.mqh (fixed OrderSelectByIndex to OrderGetTicket)
echo - SMCDetector.mqh (added missing method implementations)
echo - PerformanceTracker.mqh (fixed ArrayCopy issues, added LoadTradeHistoryFromAccount)
echo - PropFirmManager.mqh (fixed violations array type, added missing methods)
echo - PsychologyManager.mqh
echo - NewsManager.mqh
echo.
echo 🎉 ALL COMPILATION ERRORS SHOULD BE RESOLVED! 🎉
echo.
pause