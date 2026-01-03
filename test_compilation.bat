@echo off
echo ========================================
echo Testing PsyTradeAI Compilation
echo ========================================

echo Copying updated files to MetaTrader...
copy "src\Experts\PsyTradeAI_EA_Working.mq5" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\" >nul
copy "src\Include\*.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul

echo Files updated!

echo.
echo Testing compilation...
echo Please check MetaTrader 5:
echo 1. Press F4 to open MetaEditor
echo 2. Open PsyTradeAI_EA_Working.mq5
echo 3. Press F7 to compile
echo 4. Check for any remaining errors

echo.
echo If compilation succeeds:
echo 1. Go back to MetaTrader 5
echo 2. Press Ctrl+R to open Navigator
echo 3. Look under "Expert Advisors"
echo 4. Find "PsyTradeAI_EA_Working"
echo 5. Drag it to EURUSD chart

pause