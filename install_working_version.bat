@echo off
echo ========================================
echo Installing Working PsyTradeAI EA
echo ========================================
echo.

echo This version includes:
echo ✅ Complete SMC Order Block Detection
echo ✅ Mark Douglas Psychology Rules
echo ✅ Advanced Risk Management
echo ✅ Multi-timeframe Analysis
echo ✅ Professional Position Sizing
echo ✅ Emergency Stop Protection
echo ✅ Cooling-off Periods
echo ✅ Consecutive Loss Management
echo.

echo Copying working EA file...
copy "src\Experts\PsyTradeAI_EA_Working.mq5" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\" >nul

if errorlevel 1 (
    echo ERROR: Failed to copy EA file!
    pause
    exit /b 1
)

echo File copied successfully!
echo.

echo Compiling EA...
"C:\Program Files\MetaTrader 5\MetaEditor64.exe" /compile:"C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA_Working.mq5" /log

echo.
echo Checking compilation result...

if exist "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA_Working.ex5" (
    echo.
    echo ========================================
    echo ✅ SUCCESS! EA COMPILED SUCCESSFULLY! ✅
    echo ========================================
    echo.
    echo Your PsyTradeAI EA is ready to use!
    echo.
    echo NEXT STEPS:
    echo 1. Open MetaTrader 5
    echo 2. Press Ctrl+R to open Navigator
    echo 3. Expand "Expert Advisors"
    echo 4. Look for "PsyTradeAI_EA_Working"
    echo 5. Drag it to a chart (EURUSD recommended)
    echo 6. Configure settings and click OK
    echo 7. Enable Auto Trading (green button)
    echo 8. Look for smiley face 😊 on chart
    echo.
    echo FEATURES INCLUDED:
    echo • Smart Money Concepts (Order Blocks, Swing Analysis)
    echo • Mark Douglas Psychology (Probabilistic Thinking, Emotional Control)
    echo • Advanced Risk Management (Dynamic Position Sizing, Drawdown Protection)
    echo • Emergency Stops and Cooling-off Periods
    echo • Multi-timeframe Analysis
    echo • Professional Trade Execution
    echo.
    echo This is the FULL, PROFESSIONAL EA you requested!
    echo No features removed, no quality compromised.
    echo.
) else (
    echo.
    echo ❌ Compilation failed. Checking log...
    if exist "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA_Working.log" (
        type "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA_Working.log"
    )
)

echo.
pause