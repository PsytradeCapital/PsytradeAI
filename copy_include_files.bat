@echo off
echo ========================================
echo Copying PsyTradeAI Include Files
echo ========================================

echo Copying all include files to MetaTrader...

copy "src\Include\TradeManager.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul
copy "src\Include\RiskManager.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul
copy "src\Include\SMCDetector.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul
copy "src\Include\PsychologyManager.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul
copy "src\Include\PropFirmManager.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul
copy "src\Include\NewsManager.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul
copy "src\Include\PerformanceTracker.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul

echo ✓ All include files copied!
echo.

echo Include files copied:
echo ✓ TradeManager.mqh
echo ✓ RiskManager.mqh  
echo ✓ SMCDetector.mqh
echo ✓ PsychologyManager.mqh
echo ✓ PropFirmManager.mqh
echo ✓ NewsManager.mqh
echo ✓ PerformanceTracker.mqh
echo.

echo Now you can use the original EA files that reference these includes.
echo The include files are now available in MetaTrader's Include folder.
echo.

pause