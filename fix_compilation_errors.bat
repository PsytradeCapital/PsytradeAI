@echo off
echo ========================================
echo Fixing PsyTradeAI Compilation Errors
echo ========================================
echo.

echo Copying fixed files...

REM Copy the corrected files back to MetaTrader
copy "src\Experts\PsyTradeAI_EA.mq5" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\" >nul
copy "src\Include\*.mqh" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Include\" >nul

echo Files updated!
echo.

echo Compiling with fixes...
"C:\Program Files\MetaTrader 5\MetaEditor64.exe" /compile:"C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA.mq5" /log

echo.
echo Compilation attempt complete!
echo Check the log for results...
echo.

if exist "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA.ex5" (
    echo SUCCESS: EA compiled successfully! ✅
    echo.
    echo Next steps:
    echo 1. Open MetaTrader 5
    echo 2. Press Ctrl+R to open Navigator
    echo 3. Look under "Expert Advisors"
    echo 4. You should see "PsyTradeAI_EA"
    echo 5. Drag it to a chart to start trading!
) else (
    echo Still have compilation errors. Let me know what the log shows.
)

echo.
pause