@echo off
echo ========================================
echo Compiling PsyTradeAI EA
echo ========================================
echo.

set "EA_PATH=C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA.mq5"
set "METAEDITOR=C:\Program Files\MetaTrader 5\MetaEditor64.exe"

echo Compiling EA...
"%METAEDITOR%" /compile:"%EA_PATH%" /log

echo.
echo Compilation complete!
echo.
echo Now check in MetaTrader 5:
echo 1. Press Ctrl+R to open Navigator
echo 2. Look under "Expert Advisors" 
echo 3. You should see "PsyTradeAI_EA"
echo 4. Drag it to a chart
echo.

echo Checking if compiled file exists...
if exist "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA.ex5" (
    echo SUCCESS: Compiled file (.ex5) found!
) else (
    echo WARNING: Compiled file (.ex5) not found. Check for compilation errors.
)

echo.
pause