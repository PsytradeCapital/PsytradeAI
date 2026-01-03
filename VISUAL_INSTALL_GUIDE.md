# 📸 Visual Installation Guide - PsyTradeAI

## **Method 1: Automatic Installation (Recommended)**

### **Step 1: Use the Installation Script**
1. **Double-click `install_psytradeai.bat`** in your PsyTradeAI folder
2. **The script will automatically:**
   - Find your MetaTrader folder
   - Copy all files to the correct locations
   - Show you success/error messages

**What you'll see:**
```
========================================
PsyTradeAI Installation Script
========================================

Found MetaTrader 5 data folder:
C:\Users\YourName\AppData\Roaming\MetaQuotes\Terminal\...

Copying files...
Copying PsyTradeAI_EA.mq5...
Copying include files...

========================================
Installation Complete! ✅
========================================
```

---

## **Method 2: Manual Installation**

### **Step 1: Open MetaTrader Data Folder**

**In MetaTrader 5:**
1. Click **"File"** menu (top left)
2. Click **"Open Data Folder"**

**What you'll see:** Windows Explorer opens showing folders like:
```
📁 Bases
📁 Config  
📁 Logs
📁 MQL5     ← This is what we need!
📁 Profiles
📁 Tester
```

### **Step 2: Navigate to MQL5 Folder**
1. **Double-click the `MQL5` folder**
2. **You'll see folders like:**
```
📁 Experts    ← EA files go here
📁 Include    ← Library files go here  
📁 Indicators
📁 Scripts
```

### **Step 3: Copy the Main EA File**

**From your PsyTradeAI project:**
1. **Open your PsyTradeAI folder**
2. **Open `src` folder**
3. **Open `Experts` folder**
4. **Right-click `PsyTradeAI_EA.mq5`** → **Copy**

**In MetaTrader MQL5 folder:**
1. **Double-click `Experts` folder**
2. **Right-click in empty space** → **Paste**

**Result:** You should see `PsyTradeAI_EA.mq5` in the Experts folder

### **Step 4: Copy the Include Files**

**From your PsyTradeAI project:**
1. **Go back to `src` folder**
2. **Open `Include` folder**
3. **Select ALL 7 files** (Ctrl+A):
   - SMCDetector.mqh
   - PsychologyManager.mqh
   - RiskManager.mqh
   - PropFirmManager.mqh
   - TradeManager.mqh
   - NewsManager.mqh
   - PerformanceTracker.mqh
4. **Right-click** → **Copy**

**In MetaTrader MQL5 folder:**
1. **Go back to MQL5 folder**
2. **Double-click `Include` folder**
3. **Right-click in empty space** → **Paste**

**Result:** You should see all 7 .mqh files in the Include folder

---

## **Step 5: Compile the EA**

### **Open MetaEditor**
**In MetaTrader 5:**
1. **Press F4** OR
2. **Click the MetaEditor icon** (looks like a document with < >)

### **Open the EA File**
**In MetaEditor:**
1. **Click "File"** → **"Open"**
2. **Navigate to `MQL5/Experts/`**
3. **Click `PsyTradeAI_EA.mq5`**
4. **Click "Open"**

**What you'll see:** The EA code opens in the editor

### **Compile the EA**
1. **Press F7** OR
2. **Click the "Compile" button** (gear icon in toolbar)

**What to look for:**
- **Bottom panel shows "Errors" tab**
- **Success message:** `0 error(s), 0 warning(s) - compilation successful`
- **If errors:** Red text showing what's wrong

---

## **Step 6: Attach EA to Chart**

### **Find the EA in Navigator**
**In MetaTrader 5:**
1. **Press Ctrl+R** to open Navigator (or View → Navigator)
2. **Expand "Expert Advisors"** (click the + sign)
3. **Look for "PsyTradeAI_EA"**

### **Attach to Chart**
1. **Drag "PsyTradeAI_EA"** from Navigator
2. **Drop it on any chart** (EURUSD recommended)

**What happens:** Settings dialog opens

### **Configure Settings**
**In the settings dialog:**

**Common tab:**
- ✅ Allow live trading
- ✅ Allow DLL imports (if needed)

**Inputs tab - Key settings:**
```
Risk per trade (%): 1.0
Max daily drawdown (%): 5.0  
Max overall drawdown (%): 10.0
Max open trades: 1
Magic number: 12345
Trade comment: "PsyTradeAI"
```

**Click "OK"**

---

## **Step 7: Enable Auto Trading**

1. **Click "Auto Trading" button** in toolbar (should turn GREEN)
2. **Check chart top-right corner** for smiley face 😊

**Success indicators:**
- ✅ Green "Auto Trading" button
- ✅ Smiley face 😊 on chart
- ✅ "Experts" tab shows: `[PsyTradeAI] Initialization complete`

---

## **🔍 Visual Troubleshooting**

### **❌ Problem: Red sad face on chart**
**Causes:**
- Auto trading disabled
- Compilation errors
- Missing files

**Fix:** Check Experts tab for error messages

### **❌ Problem: EA not in Navigator**
**Fix:**
1. Right-click Navigator → Refresh
2. Check if compilation was successful
3. Restart MetaTrader

### **❌ Problem: Compilation errors**
**Common error messages:**
```
'CSMCDetector' - undeclared identifier
```
**Fix:** Make sure all .mqh files are in Include folder

### **❌ Problem: "Cannot open file"**
**Fix:** Check file paths and names are correct

---

## **✅ Success Checklist**

After installation, verify:
- [ ] EA appears in Navigator under Expert Advisors
- [ ] EA compiles without errors (0 error(s), 0 warning(s))
- [ ] Smiley face 😊 appears on chart when attached
- [ ] Auto Trading button is GREEN
- [ ] Experts tab shows initialization message
- [ ] EA settings dialog opens when attached

---

## **🆘 Still Need Help?**

**If you're stuck:**
1. **Take a screenshot** of your screen
2. **Tell me which step** isn't working
3. **Copy any error messages** from the Experts tab

**Common file locations:**
- **Project files:** Your PsyTradeAI folder/src/
- **MetaTrader data:** `%APPDATA%\MetaQuotes\Terminal\[ID]\MQL5\`
- **EA destination:** `MQL5\Experts\PsyTradeAI_EA.mq5`
- **Include destination:** `MQL5\Include\*.mqh`

I'll help you get it working! 🚀