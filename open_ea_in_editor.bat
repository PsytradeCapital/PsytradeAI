@echo off
echo Opening PsyTradeAI EA in MetaEditor...
echo.

set "EA_PATH=C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\PsyTradeAI_EA.mq5"
set "METAEDITOR=C:\Program Files\MetaTrader 5\MetaEditor64.exe"

if not exist "%EA_PATH%" (
    echo ERROR: EA file not found at: %EA_PATH%
    pause
    exit /b 1
)

if not exist "%METAEDITOR%" (
    echo ERROR: MetaEditor not found at: %METAEDITOR%
    echo Please check your MetaTrader 5 installation path.
    pause
    exit /b 1
)

echo Starting MetaEditor with PsyTradeAI EA...
start "" "%METAEDITOR%" "%EA_PATH%"

echo.
echo MetaEditor should now open with the PsyTradeAI EA file loaded.
echo If it opens successfully, press F7 to compile the EA.
echo.
pause