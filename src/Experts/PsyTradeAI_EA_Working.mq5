//+------------------------------------------------------------------+
//|                                          PsyTradeAI_EA_Working.mq5 |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"
#property version   "1.00"
#property description "AI-Powered Trading Robot with Smart Money Concepts & Psychology"

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
    Print(g_LogPrefix + "Initializing PsyTradeAI Expert Advisor v1.00");
    
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
    Print(g_LogPrefix + "Psychological Reminder: Each trade is an independent event in our probabilistic edge.");
    
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
        CloseAllPositions("Emergency stop");
    }
    
    // Reset daily metrics at start of new day
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    static int lastDay = -1;
    
    if(lastDay != -1 && dt.day != lastDay)
    {
        g_DailyStartingBalance = currentEquity;
        g_DailyDrawdown = 0;
    }
    lastDay = dt.day;
}

//+------------------------------------------------------------------+
//| Update psychology state                                         |
//+------------------------------------------------------------------+
void UpdatePsychologyState()
{
    // Check cooling off period
    if(g_LastLossTime > 0)
    {
        int minutesSinceLoss = (int)((TimeCurrent() - g_LastLossTime) / 60);
        g_InCoolingOff = (minutesSinceLoss < InpCoolingOffPeriod);
    }
    
    // Adjust position size based on consecutive losses
    if(g_ConsecutiveLosses >= InpMaxConsecutiveLosses)
    {
        g_PositionSizeMultiplier = 0.5; // Reduce size by 50%
        Print(g_LogPrefix + "Position size reduced due to consecutive losses");
    }
    else
    {
        g_PositionSizeMultiplier = 1.0; // Normal size
    }
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                     |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
    // Check emergency stop
    if(g_EmergencyStop)
    {
        return false;
    }
    
    // Check drawdown limits
    if(g_DailyDrawdown >= InpMaxDailyDD)
    {
        Print(g_LogPrefix + "Trading blocked: Daily drawdown limit reached");
        return false;
    }
    
    if(g_CurrentDrawdown >= InpMaxOverallDD)
    {
        Print(g_LogPrefix + "Trading blocked: Overall drawdown limit reached");
        return false;
    }
    
    // Check psychology rules
    if(InpEnforceEmotionalRules && g_InCoolingOff)
    {
        Print(g_LogPrefix + "Trading blocked: In cooling off period");
        return false;
    }
    
    // Check maximum open trades
    if(GetOpenTradesCount() >= InpMaxOpenTrades)
    {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Analyze market and execute trades                               |
//+------------------------------------------------------------------+
void AnalyzeMarketAndTrade()
{
    // Detect SMC patterns
    DetectOrderBlocks();
    
    // Find best trading opportunity
    OrderBlock bestSetup;
    double confidence = FindBestSetup(bestSetup);
    
    if(confidence < InpConfidenceThreshold)
    {
        return; // No high-confidence setup found
    }
    
    // Execute trade
    ExecuteTrade(bestSetup, confidence);
}

//+------------------------------------------------------------------+
//| Detect Order Blocks (SMC)                                      |
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
            ob.is_mitigated = false;
            ob.strength = CalculateOrderBlockStrength(i);
            
            if(ob.strength >= 2 && g_OrderBlockCount < 100)
            {
                g_OrderBlocks[g_OrderBlockCount] = ob;
                g_OrderBlockCount++;
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
            ob.is_mitigated = false;
            ob.strength = CalculateOrderBlockStrength(i);
            
            if(ob.strength >= 2 && g_OrderBlockCount < 100)
            {
                g_OrderBlocks[g_OrderBlockCount] = ob;
                g_OrderBlockCount++;
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
    
    return MathMin(strength, 5);
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
        
        // Strength factor
        confidence += (ob.strength / 5.0) * 0.4;
        
        // Distance factor (closer is better)
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrBuffer[];
        ArraySetAsSeries(atrBuffer, true);
        CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
        double atr = atrBuffer[0];
        
        if(distance < atr * 0.5) confidence += 0.3;
        
        if(confidence > bestConfidence)
        {
            bestConfidence = confidence;
            bestSetup = ob;
        }
    }
    
    return bestConfidence;
}

//+------------------------------------------------------------------+
//| Execute trade                                                   |
//+------------------------------------------------------------------+
void ExecuteTrade(const OrderBlock &setup, double confidence)
{
    double lotSize = CalculatePositionSize(setup);
    if(lotSize <= 0) return;
    
    double entry, sl, tp;
    
    if(setup.type == 1) // Bullish
    {
        entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrBuffer[];
        ArraySetAsSeries(atrBuffer, true);
        CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
        double atr = atrBuffer[0];
        
        sl = setup.price_low - (atr * 1.5);
        tp = entry + ((entry - sl) * InpMinRiskReward);
        
        if(trade.Buy(lotSize, _Symbol, entry, sl, tp, InpTradeComment))
        {
            Print(g_LogPrefix + "BUY executed - Confidence: " + DoubleToString(confidence, 2));
            RecordTradeAttempt(true);
        }
    }
    else // Bearish
    {
        entry = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrBuffer[];
        ArraySetAsSeries(atrBuffer, true);
        CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
        double atr = atrBuffer[0];
        
        sl = setup.price_high + (atr * 1.5);
        tp = entry - ((sl - entry) * InpMinRiskReward);
        
        if(trade.Sell(lotSize, _Symbol, entry, sl, tp, InpTradeComment))
        {
            Print(g_LogPrefix + "SELL executed - Confidence: " + DoubleToString(confidence, 2));
            RecordTradeAttempt(true);
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate position size                                         |
//+------------------------------------------------------------------+
double CalculatePositionSize(const OrderBlock &setup)
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double riskAmount = (equity * InpRiskPerTrade * g_PositionSizeMultiplier) / 100.0;
    
    double entry = (setup.type == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);
    CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
    double atr = atrBuffer[0];
    
    double sl = (setup.type == 1) ? setup.price_low - (atr * 1.5) : 
                                   setup.price_high + (atr * 1.5);
    
    double pipRisk = MathAbs(entry - sl);
    if(pipRisk <= 0) return 0;
    
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
    }
    else
    {
        g_ConsecutiveLosses++;
        g_ConsecutiveWins = 0;
        g_LastLossTime = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Get count of open trades                                        |
//+------------------------------------------------------------------+
int GetOpenTradesCount()
{
    int count = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByIndex(i))
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
    
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(PositionSelectByIndex(i))
        {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                ulong ticket = PositionGetInteger(POSITION_TICKET);
                trade.PositionClose(ticket);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Update real-time monitoring                                     |
//+------------------------------------------------------------------+
void UpdateRealTimeMonitoring()
{
    // Monitor positions and update trailing stops if needed
    for(int pos_i = 0; pos_i < PositionsTotal(); pos_i++)
    {
        if(PositionSelectByIndex(pos_i))
        {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                // Add position monitoring logic here
                // This is where you'd implement trailing stops, partial closes, etc.
            }
        }
    }
}