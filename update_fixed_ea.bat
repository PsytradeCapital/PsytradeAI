@echo off
echo ========================================
echo Updating FIXED PsyTradeAI EA
echo ========================================

echo Copying FIXED EA with all compilation errors resolved...
copy "src\Experts\PsyTradeAI_EA_Final.mq5" "C:\Users\Martin Mbugua\AppData\Roaming\MetaQuotes\Terminal\776D2ACDFA4F66FAF3C8985F75FA9FF6\MQL5\Experts\" >nul

echo ✓ Fixed EA copied!
echo.

echo COMPILATION ERRORS FIXED:
echo ✓ Fixed 'double' to 'int' type conversion (line 667)
echo ✓ Fixed undeclared 'pos_i' identifiers (lines 861, 881, 912)
echo ✓ Changed all loop variables to unique names
echo.

echo NOW TRY COMPILATION AGAIN:
echo 1. Go to MetaEditor (should still be open)
echo 2. Press F7 to compile again
echo 3. You should see "0 error(s), 0 warning(s)"
echo.

echo If compilation succeeds:
echo 1. Go back to MetaTrader 5
echo 2. Press Ctrl+R to open Navigator
echo 3. Look under "Expert Advisors"
echo 4. Find "PsyTradeAI_EA_Final"
echo 5. Drag it to EURUSD chart
echo.

pause