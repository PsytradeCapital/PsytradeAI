# 🚀 PsyTradeAI Installation Guide - Step by Step

## **IMPORTANT: Follow these steps exactly as written**

### **Step 1: Find Your MetaTrader Data Folder**

1. **Open MetaTrader 5**
2. **Click on "File" menu** → **"Open Data Folder"**
3. This will open Windows Explorer to the correct folder
4. **Keep this window open** - we'll use it in the next steps

### **Step 2: Prepare the Files**

1. **Go back to your PsyTradeAI project folder** (where you can see the `src` folder)
2. **Open the `src` folder**
3. You should see:
   - `Experts` folder (contains PsyTradeAI_EA.mq5)
   - `Include` folder (contains 7 .mqh files)

### **Step 3: Copy Files to MetaTrader**

**From the MetaTrader Data Folder window (Step 1):**

1. **Navigate to the `MQL5` folder** (double-click to open it)
2. You should see folders like: `Experts`, `Include`, `Indicators`, etc.

**Now copy the files:**

#### **Copy the Main EA File:**
1. **From your PsyTradeAI `src/Experts` folder**
2. **Copy `PsyTradeAI_EA.mq5`**
3. **Paste it into** `MetaTrader Data Folder/MQL5/Experts/`

#### **Copy the Include Files:**
1. **From your PsyTradeAI `src/Include` folder**
2. **Select ALL 7 .mqh files:**
   - SMCDetector.mqh
   - PsychologyManager.mqh
   - RiskManager.mqh
   - PropFirmManager.mqh
   - TradeManager.mqh
   - NewsManager.mqh
   - PerformanceTracker.mqh
3. **Copy all of them**
4. **Paste them into** `MetaTrader Data Folder/MQL5/Include/`

### **Step 4: Compile the EA**

1. **Open MetaEditor** (press F4 in MetaTrader, or click the MetaEditor icon)
2. **In MetaEditor, click "File" → "Open"**
3. **Navigate to** `MQL5/Experts/`
4. **Select `PsyTradeAI_EA.mq5`** and click Open
5. **Press F7 or click the "Compile" button** (looks like a gear icon)
6. **Check the "Errors" tab at the bottom**
   - If you see "0 error(s), 0 warning(s)" - SUCCESS! ✅
   - If you see errors, let me know what they are

### **Step 5: Attach EA to Chart**

1. **Go back to MetaTrader 5**
2. **Press Ctrl+R** or click "View" → "Navigator"
3. **In Navigator, expand "Expert Advisors"**
4. **You should see "PsyTradeAI_EA"**
5. **Drag and drop it onto any chart** (EURUSD recommended for testing)

### **Step 6: Configure the EA**

When you drop the EA on the chart, a settings window will appear:

#### **Basic Settings for Testing:**
```
=== Risk Management ===
Risk per trade (%): 1.0
Max daily drawdown (%): 5.0
Max overall drawdown (%): 10.0
Max open trades: 1
Emergency stop (%): 3.0

=== SMC Settings ===
Order Block lookback: 20
FVG minimum size: 10.0
Multi-timeframe analysis: true
Minimum risk-reward: 2.0

=== Psychology Settings ===
Cooling off period: 30
Max consecutive losses: 3
Confidence threshold: 0.7

=== General Settings ===
Magic number: 12345
Trade comment: "PsyTradeAI"
Show visuals: true
```

7. **Click "OK"**

### **Step 7: Enable Auto Trading**

1. **Click the "Auto Trading" button** in MetaTrader toolbar (should turn green)
2. **Check that the EA shows a smiley face** 😊 in the top-right corner of your chart

## **🔍 Troubleshooting**

### **Problem: Can't find the src folder**
**Solution:** The `src` folder is in your PsyTradeAI project directory. Look for:
```
PsyTradeAI/
├── src/           ← This folder
│   ├── Experts/
│   └── Include/
├── docs/
└── README.md
```

### **Problem: Compilation errors**
**Common fixes:**
1. Make sure ALL 7 .mqh files are in the Include folder
2. Check file names are exactly correct (case-sensitive)
3. Make sure files aren't corrupted

### **Problem: EA not showing in Navigator**
**Solution:**
1. Refresh Navigator (right-click → Refresh)
2. Check if compilation was successful
3. Restart MetaTrader

### **Problem: EA not trading**
**Check these:**
1. Auto Trading is enabled (green button)
2. Account has sufficient balance
3. Market is open
4. EA shows smiley face 😊 on chart

## **📱 Quick Visual Check**

After installation, you should see:
- ✅ EA name "PsyTradeAI_EA" in Navigator
- ✅ Smiley face 😊 on chart when attached
- ✅ Messages in "Experts" tab like: "[PsyTradeAI] Initialization complete"

## **🆘 Need Help?**

If you get stuck at any step:
1. **Take a screenshot** of what you see
2. **Tell me exactly which step** you're having trouble with
3. **Copy any error messages** you see

I'll help you fix it immediately! 🚀