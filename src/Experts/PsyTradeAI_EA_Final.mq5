//+------------------------------------------------------------------+
//|                                          PsyTradeAI_EA_Final.mq5 |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"
#property version   "1.00"
#property description "Professional AI Trading Robot - Smart Money Concepts & Psychology"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Risk Management ==="
input double InpRiskPerTrade = 1.0;        // Risk per trade (%)
input double InpMaxDailyDD = 5.0;          // Max daily drawdown (%)
input double InpMaxOverallDD = 10.0;       // Max overall drawdown (%)
input int    InpMaxOpenTrades = 3;         // Maximum concurrent trades
input double InpEmergencyStop = 3.0;      // Emergency stop drawdown (%)

input group "=== SMC Settings ==="
input int    InpOrderBlockLookback = 20;   // Bars to look back for Order Blocks
input double InpFVGMinSize = 10.0;         // Minimum FVG size in points
input int    InpStructureLookback = 50;    // Bars for structure analysis
input bool   InpUseMultiTimeframe = true; // Enable multi-timeframe analysis
input double InpMinRiskReward = 2.0;       // Minimum risk-reward ratio

input group "=== Psychology Settings ==="
input int    InpCoolingOffPeriod = 30;     // Minutes after loss before next trade
input int    InpMaxConsecutiveLosses = 3;  // Max losses before size reduction
input bool   InpEnforceEmotionalRules = true; // Enable psychological rules
input double InpConfidenceThreshold = 0.7; // Minimum setup confidence (0-1)

input group "=== General Settings ==="
input int    InpMagicNumber = 12345;       // Magic number for trades
input string InpTradeComment = "PsyTradeAI"; // Trade comment
input bool   InpShowVisuals = true;        // Show visual indicators
input bool   InpSendAlerts = true;         // Send trade alerts

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade trade;
datetime g_LastBarTime;
bool g_IsInitialized = false;
string g_LogPrefix = "[PsyTradeAI] ";

// Risk Management Variables
double g_StartingBalance;
double g_DailyStartingBalance;
double g_CurrentDrawdown;
double g_DailyDrawdown;
int g_ConsecutiveLosses = 0;
int g_ConsecutiveWins = 0;
datetime g_LastLossTime = 0;
bool g_EmergencyStop = false;

// SMC Variables
struct OrderBlock
{
    datetime timestamp;
    double price_high;
    double price_low;
    int type; // 1 = bullish, -1 = bearish
    bool is_mitigated;
    int strength;
};

OrderBlock g_OrderBlocks[100];
int g_OrderBlockCount = 0;

// Psychology Variables
bool g_InCoolingOff = false;
double g_PositionSizeMultiplier = 1.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print(g_LogPrefix + "Initializing PsyTradeAI Professional Expert Advisor v1.00");
    Print(g_LogPrefix + "Features: Smart Money Concepts, Mark Douglas Psychology, Advanced Risk Management");
    
    // Initialize trade object
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(_Symbol);
    
    // Initialize risk management
    g_StartingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    g_DailyStartingBalance = g_StartingBalance;
    
    // Validate inputs
    if(InpRiskPerTrade <= 0 || InpRiskPerTrade > 10)
    {
        Print(g_LogPrefix + "ERROR: Risk per trade must be between 0 and 10%");
        return INIT_PARAMETERS_INCORRECT;
    }
    
    if(InpConfidenceThreshold < 0.1 || InpConfidenceThreshold > 1.0)
    {
        Print(g_LogPrefix + "ERROR: Confidence threshold must be between 0.1 and 1.0");
        return INIT_PARAMETERS_INCORRECT;
    }
    
    // Set up chart visuals if enabled
    if(InpShowVisuals)
    {
        Print(g_LogPrefix + "Chart visuals enabled - SMC levels will be displayed");
    }
    
    // Log initialization success with psychological reminder
    Print(g_LogPrefix + "Initialization complete. Trading with discipline and probabilistic thinking.");
    Print(g_LogPrefix + "Mark Douglas Principle: Each trade is an independent event in our probabilistic edge.");
    Print(g_LogPrefix + "SMC Analysis: Detecting institutional order flow and market structure.");
    
    g_IsInitialized = true;
    g_LastBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print(g_LogPrefix + "Deinitializing EA. Reason: " + IntegerToString(reason));
    
    // Clean up chart objects
    ObjectsDeleteAll(0, g_LogPrefix);
    
    Print(g_LogPrefix + "Deinitialization complete. Remember: Losses are part of our probabilistic edge.");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(!g_IsInitialized)
        return;
    
    // Check for new bar
    datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    bool isNewBar = (currentBarTime != g_LastBarTime);
    
    if(isNewBar)
    {
        g_LastBarTime = currentBarTime;
        OnNewBar();
    }
    
    // Update real-time monitoring
    UpdateRealTimeMonitoring();
}

//+------------------------------------------------------------------+
//| New bar processing                                               |
//+------------------------------------------------------------------+
void OnNewBar()
{
    // Update risk metrics
    UpdateRiskMetrics();
    
    // Update psychology state
    UpdatePsychologyState();
    
    // Check if trading is allowed
    if(!IsTradeAllowed())
    {
        return;
    }
    
    // Analyze market for trading opportunities
    AnalyzeMarketAndTrade();
}

//+------------------------------------------------------------------+
//| Update risk management metrics                                  |
//+------------------------------------------------------------------+
void UpdateRiskMetrics()
{
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Calculate current drawdown
    if(g_StartingBalance > 0)
    {
        g_CurrentDrawdown = ((g_StartingBalance - currentEquity) / g_StartingBalance) * 100.0;
    }
    
    // Calculate daily drawdown
    if(g_DailyStartingBalance > 0)
    {
        g_DailyDrawdown = ((g_DailyStartingBalance - currentEquity) / g_DailyStartingBalance) * 100.0;
    }
    
    // Check for emergency stop
    if(g_CurrentDrawdown >= InpEmergencyStop)
    {
        g_EmergencyStop = true;
        Print(g_LogPrefix + "EMERGENCY STOP TRIGGERED - Drawdown: " + DoubleToString(g_CurrentDrawdown, 2) + "%");
        CloseAllPositions("Emergency stop - Protecting capital");
    }
    
    // Reset daily metrics at start of new day
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    static int lastDay = -1;
    
    if(lastDay != -1 && dt.day != lastDay)
    {
        g_DailyStartingBalance = currentEquity;
        g_DailyDrawdown = 0;
        Print(g_LogPrefix + "New trading day started. Daily metrics reset.");
    }
    lastDay = dt.day;
}

//+------------------------------------------------------------------+
//| Update psychology state (Mark Douglas principles)              |
//+------------------------------------------------------------------+
void UpdatePsychologyState()
{
    // Check cooling off period (emotional detachment)
    if(g_LastLossTime > 0)
    {
        int minutesSinceLoss = (int)((TimeCurrent() - g_LastLossTime) / 60);
        g_InCoolingOff = (minutesSinceLoss < InpCoolingOffPeriod);
        
        if(g_InCoolingOff)
        {
            Print(g_LogPrefix + "Cooling off period active. Minutes remaining: " + 
                  IntegerToString(InpCoolingOffPeriod - minutesSinceLoss));
        }
    }
    
    // Adjust position size based on consecutive losses (disciplined response)
    if(g_ConsecutiveLosses >= InpMaxConsecutiveLosses)
    {
        g_PositionSizeMultiplier = 0.5; // Reduce size by 50%
        Print(g_LogPrefix + "Position size reduced due to consecutive losses - Maintaining discipline");
    }
    else if(g_ConsecutiveWins >= 3)
    {
        g_PositionSizeMultiplier = 1.2; // Slightly increase size after wins
    }
    else
    {
        g_PositionSizeMultiplier = 1.0; // Normal size
    }
}

//+------------------------------------------------------------------+
//| Check if trading is allowed (psychological & risk rules)       |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
    // Check emergency stop
    if(g_EmergencyStop)
    {
        return false;
    }
    
    // Check drawdown limits (prop firm compliance)
    if(g_DailyDrawdown >= InpMaxDailyDD)
    {
        Print(g_LogPrefix + "Trading blocked: Daily drawdown limit reached (" + 
              DoubleToString(g_DailyDrawdown, 2) + "%)");
        return false;
    }
    
    if(g_CurrentDrawdown >= InpMaxOverallDD)
    {
        Print(g_LogPrefix + "Trading blocked: Overall drawdown limit reached (" + 
              DoubleToString(g_CurrentDrawdown, 2) + "%)");
        return false;
    }
    
    // Check psychology rules (Mark Douglas principles)
    if(InpEnforceEmotionalRules && g_InCoolingOff)
    {
        return false; // Silent during cooling off
    }
    
    // Check maximum open trades
    if(GetOpenTradesCount() >= InpMaxOpenTrades)
    {
        return false;
    }
    
    // Check market hours (avoid low liquidity periods)
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    if(dt.day_of_week == 0 || dt.day_of_week == 6) // Weekend
    {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Analyze market and execute trades (SMC + Psychology)           |
//+------------------------------------------------------------------+
void AnalyzeMarketAndTrade()
{
    // Detect SMC patterns
    DetectOrderBlocks();
    DetectFairValueGaps();
    AnalyzeMarketStructure();
    
    // Find best trading opportunity
    OrderBlock bestSetup;
    double confidence = FindBestSetup(bestSetup);
    
    if(confidence < InpConfidenceThreshold)
    {
        return; // No high-confidence setup found
    }
    
    // Apply Mark Douglas principle: Accept uncertainty, focus on probability
    Print(g_LogPrefix + "High-confidence setup detected. Confidence: " + DoubleToString(confidence, 2));
    Print(g_LogPrefix + "Mark Douglas: Accepting this trade as part of our probabilistic edge.");
    
    // Execute trade
    ExecuteTrade(bestSetup, confidence);
}

//+------------------------------------------------------------------+
//| Detect Order Blocks (Smart Money Concepts)                     |
//+------------------------------------------------------------------+
void DetectOrderBlocks()
{
    g_OrderBlockCount = 0;
    
    for(int i = 5; i < InpOrderBlockLookback; i++)
    {
        // Check for swing low (potential bullish order block)
        if(IsSwingLow(i))
        {
            OrderBlock ob;
            ob.timestamp = iTime(_Symbol, PERIOD_CURRENT, i);
            ob.price_high = iHigh(_Symbol, PERIOD_CURRENT, i);
            ob.price_low = iLow(_Symbol, PERIOD_CURRENT, i);
            ob.type = 1; // Bullish
            ob.is_mitigated = CheckOrderBlockMitigation(i, 1);
            ob.strength = CalculateOrderBlockStrength(i);
            
            if(ob.strength >= 2 && g_OrderBlockCount < 100)
            {
                g_OrderBlocks[g_OrderBlockCount] = ob;
                g_OrderBlockCount++;
                
                // Draw order block on chart if visuals enabled
                if(InpShowVisuals)
                {
                    DrawOrderBlock(ob, g_OrderBlockCount);
                }
            }
        }
        
        // Check for swing high (potential bearish order block)
        if(IsSwingHigh(i))
        {
            OrderBlock ob;
            ob.timestamp = iTime(_Symbol, PERIOD_CURRENT, i);
            ob.price_high = iHigh(_Symbol, PERIOD_CURRENT, i);
            ob.price_low = iLow(_Symbol, PERIOD_CURRENT, i);
            ob.type = -1; // Bearish
            ob.is_mitigated = CheckOrderBlockMitigation(i, -1);
            ob.strength = CalculateOrderBlockStrength(i);
            
            if(ob.strength >= 2 && g_OrderBlockCount < 100)
            {
                g_OrderBlocks[g_OrderBlockCount] = ob;
                g_OrderBlockCount++;
                
                // Draw order block on chart if visuals enabled
                if(InpShowVisuals)
                {
                    DrawOrderBlock(ob, g_OrderBlockCount);
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check if bar is swing low                                       |
//+------------------------------------------------------------------+
bool IsSwingLow(int shift)
{
    if(shift < 2) return false;
    
    double low = iLow(_Symbol, PERIOD_CURRENT, shift);
    
    return (low < iLow(_Symbol, PERIOD_CURRENT, shift-1) && 
            low < iLow(_Symbol, PERIOD_CURRENT, shift+1) &&
            low < iLow(_Symbol, PERIOD_CURRENT, shift-2) && 
            low < iLow(_Symbol, PERIOD_CURRENT, shift+2));
}

//+------------------------------------------------------------------+
//| Check if bar is swing high                                      |
//+------------------------------------------------------------------+
bool IsSwingHigh(int shift)
{
    if(shift < 2) return false;
    
    double high = iHigh(_Symbol, PERIOD_CURRENT, shift);
    
    return (high > iHigh(_Symbol, PERIOD_CURRENT, shift-1) && 
            high > iHigh(_Symbol, PERIOD_CURRENT, shift+1) &&
            high > iHigh(_Symbol, PERIOD_CURRENT, shift-2) && 
            high > iHigh(_Symbol, PERIOD_CURRENT, shift+2));
}

//+------------------------------------------------------------------+
//| Calculate order block strength                                  |
//+------------------------------------------------------------------+
int CalculateOrderBlockStrength(int shift)
{
    int strength = 1;
    
    // Check rejection quality
    double bodySize = MathAbs(iClose(_Symbol, PERIOD_CURRENT, shift) - iOpen(_Symbol, PERIOD_CURRENT, shift));
    double totalSize = iHigh(_Symbol, PERIOD_CURRENT, shift) - iLow(_Symbol, PERIOD_CURRENT, shift);
    
    if(totalSize > 0)
    {
        double rejectionRatio = 1.0 - (bodySize / totalSize);
        if(rejectionRatio > 0.6) strength++;
        if(rejectionRatio > 0.8) strength++;
    }
    
    // Check volume (if available)
    long volume = iVolume(_Symbol, PERIOD_CURRENT, shift);
    long avgVolume = 0;
    for(int vol_i = 1; vol_i <= 10; vol_i++)
    {
        avgVolume += iVolume(_Symbol, PERIOD_CURRENT, shift + vol_i);
    }
    avgVolume /= 10;
    
    if(volume > avgVolume * 1.5) strength++;
    
    // Check follow-through (price action after the swing)
    bool hasFollowThrough = false;
    for(int follow_i = 1; follow_i <= 5; follow_i++)
    {
        if(shift - follow_i >= 0)
        {
            double followPrice = iClose(_Symbol, PERIOD_CURRENT, shift - follow_i);
            double swingPrice = (iHigh(_Symbol, PERIOD_CURRENT, shift) + iLow(_Symbol, PERIOD_CURRENT, shift)) / 2;
            
            if(MathAbs(followPrice - swingPrice) > totalSize * 0.5)
            {
                hasFollowThrough = true;
                break;
            }
        }
    }
    
    if(hasFollowThrough) strength++;
    
    return MathMin(strength, 5);
}

//+------------------------------------------------------------------+
//| Check if order block has been mitigated                        |
//+------------------------------------------------------------------+
bool CheckOrderBlockMitigation(int shift, int type)
{
    double obHigh = iHigh(_Symbol, PERIOD_CURRENT, shift);
    double obLow = iLow(_Symbol, PERIOD_CURRENT, shift);
    
    // Check if price has returned to order block area
    for(int check_i = 1; check_i < shift; check_i++)
    {
        double checkHigh = iHigh(_Symbol, PERIOD_CURRENT, check_i);
        double checkLow = iLow(_Symbol, PERIOD_CURRENT, check_i);
        
        if(type == 1) // Bullish order block
        {
            if(checkLow <= obHigh && checkHigh >= obLow)
            {
                return true; // Price has returned to the order block
            }
        }
        else // Bearish order block
        {
            if(checkHigh >= obLow && checkLow <= obHigh)
            {
                return true; // Price has returned to the order block
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Detect Fair Value Gaps (FVG)                                   |
//+------------------------------------------------------------------+
void DetectFairValueGaps()
{
    for(int i = 2; i < 50; i++)
    {
        // Check for bullish FVG
        double high1 = iHigh(_Symbol, PERIOD_CURRENT, i+1);
        double low1 = iLow(_Symbol, PERIOD_CURRENT, i-1);
        double high2 = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low2 = iLow(_Symbol, PERIOD_CURRENT, i);
        
        if(low1 > high1) // Gap exists
        {
            double gapSize = (low1 - high1) / _Point;
            if(gapSize >= InpFVGMinSize)
            {
                // Draw FVG if visuals enabled
                if(InpShowVisuals)
                {
                    DrawFVG(i, high1, low1, 1); // Bullish FVG
                }
            }
        }
        
        // Check for bearish FVG
        if(high1 < low1) // Gap exists (bearish)
        {
            double gapSize = (low1 - high1) / _Point;
            if(gapSize >= InpFVGMinSize)
            {
                // Draw FVG if visuals enabled
                if(InpShowVisuals)
                {
                    DrawFVG(i, high1, low1, -1); // Bearish FVG
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Analyze market structure (BOS, CHOCH)                          |
//+------------------------------------------------------------------+
void AnalyzeMarketStructure()
{
    // Detect Break of Structure (BOS) and Change of Character (CHOCH)
    // This is a simplified version - can be expanded
    
    double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, 1);
    double currentLow = iLow(_Symbol, PERIOD_CURRENT, 1);
    
    // Find recent swing highs and lows
    double lastSwingHigh = 0;
    double lastSwingLow = 0;
    
    for(int struct_i = 2; struct_i < InpStructureLookback; struct_i++)
    {
        if(IsSwingHigh(struct_i) && lastSwingHigh == 0)
        {
            lastSwingHigh = iHigh(_Symbol, PERIOD_CURRENT, struct_i);
        }
        
        if(IsSwingLow(struct_i) && lastSwingLow == 0)
        {
            lastSwingLow = iLow(_Symbol, PERIOD_CURRENT, struct_i);
        }
        
        if(lastSwingHigh > 0 && lastSwingLow > 0)
            break;
    }
    
    // Check for BOS
    if(lastSwingHigh > 0 && currentHigh > lastSwingHigh)
    {
        Print(g_LogPrefix + "Bullish Break of Structure detected at " + DoubleToString(currentHigh, _Digits));
    }
    
    if(lastSwingLow > 0 && currentLow < lastSwingLow)
    {
        Print(g_LogPrefix + "Bearish Break of Structure detected at " + DoubleToString(currentLow, _Digits));
    }
}

//+------------------------------------------------------------------+
//| Find best trading setup                                         |
//+------------------------------------------------------------------+
double FindBestSetup(OrderBlock &bestSetup)
{
    double bestConfidence = 0;
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    for(int setup_i = 0; setup_i < g_OrderBlockCount; setup_i++)
    {
        OrderBlock ob = g_OrderBlocks[setup_i];
        
        if(ob.is_mitigated) continue;
        
        // Check if price is near order block
        double distance = 0;
        if(ob.type == 1) // Bullish
        {
            distance = MathAbs(currentPrice - ob.price_low);
        }
        else // Bearish
        {
            distance = MathAbs(currentPrice - ob.price_high);
        }
        
        // Calculate confidence based on multiple factors
        double confidence = 0.3; // Base confidence
        
        // Strength factor (40% weight)
        confidence += (ob.strength / 5.0) * 0.4;
        
        // Distance factor (30% weight) - closer is better
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrBuffer[];
        ArraySetAsSeries(atrBuffer, true);
        CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
        double atr = atrBuffer[0];
        
        if(distance < atr * 0.5) confidence += 0.3;
        else if(distance < atr * 1.0) confidence += 0.15;
        
        // Multi-timeframe confirmation (if enabled)
        if(InpUseMultiTimeframe)
        {
            if(CheckHigherTimeframeAlignment(ob))
            {
                confidence += 0.2;
            }
        }
        
        // Time factor - fresher order blocks are better
        int barsAge = iBarShift(_Symbol, PERIOD_CURRENT, ob.timestamp);
        if(barsAge < 10) confidence += 0.1;
        
        if(confidence > bestConfidence)
        {
            bestConfidence = confidence;
            bestSetup = ob;
        }
    }
    
    return bestConfidence;
}

//+------------------------------------------------------------------+
//| Check higher timeframe alignment                                |
//+------------------------------------------------------------------+
bool CheckHigherTimeframeAlignment(const OrderBlock &ob)
{
    // Simple higher timeframe check
    ENUM_TIMEFRAMES higherTF = PERIOD_H4;
    if(Period() >= PERIOD_H4) higherTF = PERIOD_D1;
    
    // Check if higher timeframe trend aligns with order block direction
    double htfMA = iMA(_Symbol, higherTF, 20, 0, MODE_SMA, PRICE_CLOSE);
    double htfMABuffer[];
    ArraySetAsSeries(htfMABuffer, true);
    CopyBuffer(htfMA, 0, 0, 2, htfMABuffer);
    
    bool htfBullish = htfMABuffer[0] > htfMABuffer[1];
    
    return (ob.type == 1 && htfBullish) || (ob.type == -1 && !htfBullish);
}

//+------------------------------------------------------------------+
//| Execute trade with full professional features                   |
//+------------------------------------------------------------------+
void ExecuteTrade(const OrderBlock &setup, double confidence)
{
    double lotSize = CalculatePositionSize(setup);
    if(lotSize <= 0) 
    {
        Print(g_LogPrefix + "Invalid lot size calculated. Skipping trade.");
        return;
    }
    
    double entry, sl, tp;
    
    if(setup.type == 1) // Bullish setup
    {
        entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        
        // Calculate ATR for dynamic stop loss
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrBuffer[];
        ArraySetAsSeries(atrBuffer, true);
        CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
        double atr = atrBuffer[0];
        
        // Set stop loss below order block with ATR buffer
        sl = setup.price_low - (atr * 1.5);
        
        // Set take profit based on risk-reward ratio
        double riskDistance = entry - sl;
        tp = entry + (riskDistance * InpMinRiskReward);
        
        // Execute buy order
        if(trade.Buy(lotSize, _Symbol, entry, sl, tp, InpTradeComment + " | Conf:" + DoubleToString(confidence, 2)))
        {
            ulong ticket = trade.ResultOrder();
            Print(g_LogPrefix + "BUY executed successfully!");
            Print(g_LogPrefix + "Ticket: " + IntegerToString(ticket));
            Print(g_LogPrefix + "Entry: " + DoubleToString(entry, _Digits));
            Print(g_LogPrefix + "Stop Loss: " + DoubleToString(sl, _Digits));
            Print(g_LogPrefix + "Take Profit: " + DoubleToString(tp, _Digits));
            Print(g_LogPrefix + "Lot Size: " + DoubleToString(lotSize, 2));
            Print(g_LogPrefix + "Confidence: " + DoubleToString(confidence, 2));
            Print(g_LogPrefix + "Risk-Reward: 1:" + DoubleToString(InpMinRiskReward, 1));
            
            RecordTradeAttempt(true);
            
            if(InpSendAlerts)
            {
                Alert("PsyTradeAI: BUY order executed on " + _Symbol + " | Confidence: " + DoubleToString(confidence, 2));
            }
        }
        else
        {
            Print(g_LogPrefix + "BUY order failed. Error: " + IntegerToString(GetLastError()));
            RecordTradeAttempt(false);
        }
    }
    else // Bearish setup
    {
        entry = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        
        // Calculate ATR for dynamic stop loss
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrBuffer[];
        ArraySetAsSeries(atrBuffer, true);
        CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
        double atr = atrBuffer[0];
        
        // Set stop loss above order block with ATR buffer
        sl = setup.price_high + (atr * 1.5);
        
        // Set take profit based on risk-reward ratio
        double riskDistance = sl - entry;
        tp = entry - (riskDistance * InpMinRiskReward);
        
        // Execute sell order
        if(trade.Sell(lotSize, _Symbol, entry, sl, tp, InpTradeComment + " | Conf:" + DoubleToString(confidence, 2)))
        {
            ulong ticket = trade.ResultOrder();
            Print(g_LogPrefix + "SELL executed successfully!");
            Print(g_LogPrefix + "Ticket: " + IntegerToString(ticket));
            Print(g_LogPrefix + "Entry: " + DoubleToString(entry, _Digits));
            Print(g_LogPrefix + "Stop Loss: " + DoubleToString(sl, _Digits));
            Print(g_LogPrefix + "Take Profit: " + DoubleToString(tp, _Digits));
            Print(g_LogPrefix + "Lot Size: " + DoubleToString(lotSize, 2));
            Print(g_LogPrefix + "Confidence: " + DoubleToString(confidence, 2));
            Print(g_LogPrefix + "Risk-Reward: 1:" + DoubleToString(InpMinRiskReward, 1));
            
            RecordTradeAttempt(true);
            
            if(InpSendAlerts)
            {
                Alert("PsyTradeAI: SELL order executed on " + _Symbol + " | Confidence: " + DoubleToString(confidence, 2));
            }
        }
        else
        {
            Print(g_LogPrefix + "SELL order failed. Error: " + IntegerToString(GetLastError()));
            RecordTradeAttempt(false);
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate position size with advanced risk management          |
//+------------------------------------------------------------------+
double CalculatePositionSize(const OrderBlock &setup)
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double riskAmount = (equity * InpRiskPerTrade * g_PositionSizeMultiplier) / 100.0;
    
    double entry = (setup.type == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Calculate ATR for dynamic stop loss
    int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);
    CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
    double atr = atrBuffer[0];
    
    double sl = (setup.type == 1) ? setup.price_low - (atr * 1.5) : 
                                   setup.price_high + (atr * 1.5);
    
    double pipRisk = MathAbs(entry - sl);
    if(pipRisk <= 0) return 0;
    
    // Calculate lot size based on risk
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    if(tickValue <= 0 || tickSize <= 0) return 0;
    
    double pipValue = tickValue / tickSize;
    double lotSize = riskAmount / (pipRisk * pipValue);
    
    // Apply lot size restrictions
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    lotSize = MathFloor(lotSize / lotStep) * lotStep;
    lotSize = MathMax(minLot, MathMin(lotSize, maxLot));
    
    // Additional safety check for prop firm compliance
    double maxRiskPerTrade = equity * 0.02; // Never risk more than 2%
    double calculatedRisk = lotSize * pipRisk * pipValue;
    
    if(calculatedRisk > maxRiskPerTrade)
    {
        lotSize = maxRiskPerTrade / (pipRisk * pipValue);
        lotSize = MathFloor(lotSize / lotStep) * lotStep;
        lotSize = MathMax(minLot, lotSize);
    }
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Record trade attempt for psychology tracking                    |
//+------------------------------------------------------------------+
void RecordTradeAttempt(bool isWin)
{
    if(isWin)
    {
        g_ConsecutiveWins++;
        g_ConsecutiveLosses = 0;
        Print(g_LogPrefix + "Trade recorded as WIN. Consecutive wins: " + IntegerToString(g_ConsecutiveWins));
    }
    else
    {
        g_ConsecutiveLosses++;
        g_ConsecutiveWins = 0;
        g_LastLossTime = TimeCurrent();
        Print(g_LogPrefix + "Trade recorded as LOSS. Consecutive losses: " + IntegerToString(g_ConsecutiveLosses));
        Print(g_LogPrefix + "Mark Douglas: This loss is just part of our probabilistic edge. Staying disciplined.");
    }
}

//+------------------------------------------------------------------+
//| Get count of open trades                                        |
//+------------------------------------------------------------------+
int GetOpenTradesCount()
{
    int count = 0;
    for(int pos_i = 0; pos_i < PositionsTotal(); pos_i++)
    {
        if(PositionSelectByIndex(pos_i))
        {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                count++;
            }
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Close all positions                                             |
//+------------------------------------------------------------------+
void CloseAllPositions(string reason)
{
    Print(g_LogPrefix + "Closing all positions - Reason: " + reason);
    
    for(int pos_i = PositionsTotal() - 1; pos_i >= 0; pos_i--)
    {
        if(PositionSelectByIndex(pos_i))
        {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                ulong ticket = PositionGetInteger(POSITION_TICKET);
                if(trade.PositionClose(ticket))
                {
                    Print(g_LogPrefix + "Position closed: " + IntegerToString(ticket));
                }
                else
                {
                    Print(g_LogPrefix + "Failed to close position: " + IntegerToString(ticket));
                }
            }
        }
    }
    
    if(InpSendAlerts)
    {
        Alert("PsyTradeAI: All positions closed - " + reason);
    }
}

//+------------------------------------------------------------------+
//| Update real-time monitoring                                     |
//+------------------------------------------------------------------+
void UpdateRealTimeMonitoring()
{
    // Monitor positions for trailing stops and partial closes
    for(int pos_i = 0; pos_i < PositionsTotal(); pos_i++)
    {
        if(PositionSelectByIndex(pos_i))
        {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                ulong ticket = PositionGetInteger(POSITION_TICKET);
                double profit = PositionGetDouble(POSITION_PROFIT);
                double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                double currentSL = PositionGetDouble(POSITION_SL);
                ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                
                // Implement trailing stop at breakeven after 1:1 profit
                double riskDistance = MathAbs(openPrice - currentSL);
                double currentPrice = (posType == POSITION_TYPE_BUY) ? 
                                    SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                                    SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                
                bool shouldTrail = false;
                double newSL = currentSL;
                
                if(posType == POSITION_TYPE_BUY)
                {
                    if(currentPrice >= openPrice + riskDistance) // 1:1 profit reached
                    {
                        newSL = openPrice + (10 * _Point); // Move to breakeven + 10 points
                        if(newSL > currentSL) shouldTrail = true;
                    }
                }
                else // SELL position
                {
                    if(currentPrice <= openPrice - riskDistance) // 1:1 profit reached
                    {
                        newSL = openPrice - (10 * _Point); // Move to breakeven + 10 points
                        if(newSL < currentSL || currentSL == 0) shouldTrail = true;
                    }
                }
                
                if(shouldTrail)
                {
                    double currentTP = PositionGetDouble(POSITION_TP);
                    if(trade.PositionModify(ticket, newSL, currentTP))
                    {
                        Print(g_LogPrefix + "Trailing stop updated for ticket " + IntegerToString(ticket) + 
                              " to breakeven+ at " + DoubleToString(newSL, _Digits));
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw Order Block on chart                                      |
//+------------------------------------------------------------------+
void DrawOrderBlock(const OrderBlock &ob, int index)
{
    string objName = g_LogPrefix + "OB_" + IntegerToString(index);
    
    color obColor = (ob.type == 1) ? clrLimeGreen : clrCrimson;
    
    ObjectCreate(0, objName, OBJ_RECTANGLE, 0, ob.timestamp, ob.price_high, 
                 TimeCurrent() + PeriodSeconds() * 20, ob.price_low);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, obColor);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objName, OBJPROP_FILL, true);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    
    // Add text label
    string labelName = objName + "_Label";
    ObjectCreate(0, labelName, OBJ_TEXT, 0, ob.timestamp, 
                (ob.price_high + ob.price_low) / 2);
    ObjectSetString(0, labelName, OBJPROP_TEXT, "OB " + IntegerToString(ob.strength));
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, obColor);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
}

//+------------------------------------------------------------------+
//| Draw Fair Value Gap on chart                                   |
//+------------------------------------------------------------------+
void DrawFVG(int shift, double high, double low, int type)
{
    string objName = g_LogPrefix + "FVG_" + IntegerToString(shift);
    datetime startTime = iTime(_Symbol, PERIOD_CURRENT, shift);
    
    color fvgColor = (type == 1) ? clrDodgerBlue : clrOrange;
    
    ObjectCreate(0, objName, OBJ_RECTANGLE, 0, startTime, high, 
                 TimeCurrent() + PeriodSeconds() * 10, low);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, fvgColor);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objName, OBJPROP_FILL, false);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
}