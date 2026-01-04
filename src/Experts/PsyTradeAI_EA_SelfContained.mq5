//+------------------------------------------------------------------+
//|                                   PsyTradeAI_EA_SelfContained.mq5 |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"
#property version   "2.00"
#property description "Self-Contained Professional AI Trading Robot - SMC & Psychology"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_PROP_FIRM
{
    PROP_FIRM_NONE,
    PROP_FIRM_FTMO,
    PROP_FIRM_FUNDEDNEXT,
    PROP_FIRM_GOATFUNDED,
    PROP_FIRM_EQUITYEDGE,
    PROP_FIRM_MYFOREXFUNDS,
    PROP_FIRM_THE5ERS,
    PROP_FIRM_TOPSTEPTRADER,
    PROP_FIRM_SURGETRADER,
    PROP_FIRM_BLUEGUARDIAN
};

enum ENUM_ORDER_BLOCK_TYPE
{
    ORDER_BLOCK_BULLISH,
    ORDER_BLOCK_BEARISH,
    ORDER_BLOCK_NONE
};

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct TradeRequest
{
    string symbol;
    ENUM_ORDER_TYPE order_type;
    double volume;
    double price;
    double stop_loss;
    double take_profit;
    string comment;
    datetime expiration;
    double risk_amount;
    double risk_reward_ratio;
};

struct SMCAnalysis
{
    bool hasValidSetup;
    ENUM_ORDER_BLOCK_TYPE setupType;
    double entryPrice;
    double stopLoss;
    double takeProfit;
    int orderBlockStrength;
    bool multiTimeframeAlignment;
    bool fibonacciAlignment;
    bool volumeConfirmation;
    bool liquidityGrabDetected;
    bool inducementDetected;
    double confidenceScore;
    string setupDescription;
};

struct OrderBlock
{
    datetime timestamp;
    double price_high;
    double price_low;
    ENUM_ORDER_BLOCK_TYPE type;
    bool is_mitigated;
    int strength;
    double rejection_volume;
    int touch_count;
    bool is_fresh;
};

struct RiskMetrics
{
    double current_equity;
    double starting_equity;
    double daily_starting_equity;
    double current_drawdown;
    double daily_drawdown;
    double max_drawdown_today;
    double max_drawdown_overall;
    double risk_per_trade;
    double total_risk_exposure;
    int open_positions;
    double unrealized_pnl;
    double realized_pnl_today;
    bool emergency_stop_triggered;
    datetime last_risk_update;
};

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
input double InpMinRiskReward = 2.0;       // Minimum risk-reward ratio
input double InpConfidenceThreshold = 0.7; // Minimum setup confidence (0-1)

input group "=== Psychology Settings ==="
input int    InpCoolingOffPeriod = 30;     // Minutes after loss before next trade
input int    InpMaxConsecutiveLosses = 3;  // Max losses before size reduction
input bool   InpEnforceEmotionalRules = true; // Enable psychological rules

input group "=== Prop Firm Settings ==="
input int    InpPropFirmType = 0;          // 0=None, 1=FTMO, 2=FundedNext, etc.
input int    InpMinHoldingTime = 60;       // Minimum position holding time (seconds)

input group "=== General Settings ==="
input int    InpMagicNumber = 12345;       // Magic number for trades
input string InpTradeComment = "PsyTradeAI"; // Trade comment
input bool   InpShowVisuals = true;        // Show visual indicators
input bool   InpSendAlerts = true;         // Send trade alerts

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTrade g_trade;

// EA state variables
bool g_isInitialized = false;
datetime g_lastBarTime = 0;
int g_totalBars = 0;

// Risk management variables
RiskMetrics g_riskMetrics;
double g_accountBalance;
double g_accountEquity;

// SMC variables
OrderBlock g_orderBlocks[];
int g_atrHandle;
double g_atr[];

// Psychology variables
int g_consecutiveLosses = 0;
int g_consecutiveWins = 0;
datetime g_lastLossTime = 0;
bool g_coolingOff = false;

// Performance tracking
int g_totalTrades = 0;
int g_winningTrades = 0;
double g_totalProfit = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("[PsyTradeAI] Starting initialization...");
    
    // Set up CTrade object
    g_trade.SetExpertMagicNumber(InpMagicNumber);
    g_trade.SetMarginMode();
    g_trade.SetTypeFillingBySymbol(_Symbol);
    g_trade.SetDeviationInPoints(3);
    
    // Initialize ATR indicator
    g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    if(g_atrHandle == INVALID_HANDLE)
    {
        Print("[PsyTradeAI] ERROR: Failed to create ATR indicator");
        return INIT_FAILED;
    }
    
    // Initialize risk metrics
    ZeroMemory(g_riskMetrics);
    g_riskMetrics.starting_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    g_riskMetrics.daily_starting_equity = g_riskMetrics.starting_equity;
    g_riskMetrics.risk_per_trade = InpRiskPerTrade;
    
    // Initialize arrays
    ArrayResize(g_orderBlocks, 0);
    ArrayResize(g_atr, 0);
    
    // Initialize bar tracking
    g_totalBars = Bars(_Symbol, PERIOD_CURRENT);
    g_lastBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    
    g_isInitialized = true;
    
    Print("[PsyTradeAI] ✓ Initialization completed successfully!");
    Print("[PsyTradeAI] ✓ Risk per trade: ", InpRiskPerTrade, "%");
    Print("[PsyTradeAI] ✓ Max daily DD: ", InpMaxDailyDD, "%");
    Print("[PsyTradeAI] ✓ Confidence threshold: ", InpConfidenceThreshold);
    
    if(InpSendAlerts)
        Alert("[PsyTradeAI] EA initialized and ready for trading!");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("[PsyTradeAI] Shutting down...");
    
    // Generate final performance report
    GeneratePerformanceReport();
    
    // Release ATR indicator
    if(g_atrHandle != INVALID_HANDLE)
    {
        IndicatorRelease(g_atrHandle);
    }
    
    Print("[PsyTradeAI] ✓ Cleanup completed");
    
    string reasonText = "";
    switch(reason)
    {
        case REASON_PROGRAM: reasonText = "EA stopped by user"; break;
        case REASON_REMOVE: reasonText = "EA removed from chart"; break;
        case REASON_RECOMPILE: reasonText = "EA recompiled"; break;
        case REASON_CHARTCHANGE: reasonText = "Chart symbol/period changed"; break;
        case REASON_CHARTCLOSE: reasonText = "Chart closed"; break;
        case REASON_PARAMETERS: reasonText = "Input parameters changed"; break;
        case REASON_ACCOUNT: reasonText = "Account changed"; break;
        default: reasonText = "Unknown reason"; break;
    }
    
    Print("[PsyTradeAI] Shutdown reason: ", reasonText);
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if EA is properly initialized
    if(!g_isInitialized)
        return;
    
    // Check for new bar
    datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    bool isNewBar = (currentBarTime != g_lastBarTime);
    
    if(isNewBar)
    {
        g_lastBarTime = currentBarTime;
        OnNewBar();
    }
    
    // Update real-time monitoring
    UpdateRealTimeMonitoring();
    
    // Monitor existing positions
    MonitorPositions();
}

//+------------------------------------------------------------------+
//| New bar event handler                                           |
//+------------------------------------------------------------------+
void OnNewBar()
{
    // Update all analysis on new bar
    UpdateSMCAnalysis();
    UpdateRiskMetrics();
    UpdatePsychologyState();
    
    // Check if trading is allowed
    if(!IsTradeAllowed())
        return;
    
    // Analyze market and execute trades if conditions are met
    AnalyzeMarketAndTrade();
}

//+------------------------------------------------------------------+
//| Update SMC Analysis                                             |
//+------------------------------------------------------------------+
void UpdateSMCAnalysis()
{
    // Update ATR values
    if(CopyBuffer(g_atrHandle, 0, 0, 3, g_atr) <= 0)
    {
        Print("[PsyTradeAI] WARNING: Failed to copy ATR buffer");
        return;
    }
    
    // Detect Order Blocks
    DetectOrderBlocks();
}

//+------------------------------------------------------------------+
//| Detect Order Blocks                                             |
//+------------------------------------------------------------------+
void DetectOrderBlocks()
{
    int barsToAnalyze = MathMin(InpOrderBlockLookback, Bars(_Symbol, PERIOD_CURRENT) - 10);
    
    for(int i = 3; i < barsToAnalyze; i++)
    {
        // Check for bullish order block (swing low with rejection)
        if(IsSwingLow(i) && IsRejectionCandle(i-1))
        {
            OrderBlock ob;
            ob.timestamp = iTime(_Symbol, PERIOD_CURRENT, i);
            ob.price_high = iHigh(_Symbol, PERIOD_CURRENT, i);
            ob.price_low = iLow(_Symbol, PERIOD_CURRENT, i);
            ob.type = ORDER_BLOCK_BULLISH;
            ob.is_mitigated = false;
            ob.strength = CalculateOrderBlockStrength(i);
            ob.rejection_volume = iVolume(_Symbol, PERIOD_CURRENT, i-1);
            ob.touch_count = 0;
            ob.is_fresh = true;
            
            // Add to array if strength is sufficient
            if(ob.strength >= 2)
            {
                ArrayResize(g_orderBlocks, ArraySize(g_orderBlocks) + 1);
                g_orderBlocks[ArraySize(g_orderBlocks) - 1] = ob;
            }
        }
        
        // Check for bearish order block (swing high with rejection)
        if(IsSwingHigh(i) && IsRejectionCandle(i-1))
        {
            OrderBlock ob;
            ob.timestamp = iTime(_Symbol, PERIOD_CURRENT, i);
            ob.price_high = iHigh(_Symbol, PERIOD_CURRENT, i);
            ob.price_low = iLow(_Symbol, PERIOD_CURRENT, i);
            ob.type = ORDER_BLOCK_BEARISH;
            ob.is_mitigated = false;
            ob.strength = CalculateOrderBlockStrength(i);
            ob.rejection_volume = iVolume(_Symbol, PERIOD_CURRENT, i-1);
            ob.touch_count = 0;
            ob.is_fresh = true;
            
            // Add to array if strength is sufficient
            if(ob.strength >= 2)
            {
                ArrayResize(g_orderBlocks, ArraySize(g_orderBlocks) + 1);
                g_orderBlocks[ArraySize(g_orderBlocks) - 1] = ob;
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
    
    // Check if current low is lower than previous and next lows
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
    
    // Check if current high is higher than previous and next highs
    return (high > iHigh(_Symbol, PERIOD_CURRENT, shift-1) && 
            high > iHigh(_Symbol, PERIOD_CURRENT, shift+1) &&
            high > iHigh(_Symbol, PERIOD_CURRENT, shift-2) && 
            high > iHigh(_Symbol, PERIOD_CURRENT, shift+2));
}

//+------------------------------------------------------------------+
//| Check if candle shows rejection                                 |
//+------------------------------------------------------------------+
bool IsRejectionCandle(int shift)
{
    double open = iOpen(_Symbol, PERIOD_CURRENT, shift);
    double close = iClose(_Symbol, PERIOD_CURRENT, shift);
    double high = iHigh(_Symbol, PERIOD_CURRENT, shift);
    double low = iLow(_Symbol, PERIOD_CURRENT, shift);
    
    double bodySize = MathAbs(close - open);
    double upperWick = high - MathMax(open, close);
    double lowerWick = MathMin(open, close) - low;
    double totalRange = high - low;
    
    if(totalRange == 0) return false;
    
    // Check for significant rejection (wick > 60% of total range)
    return (upperWick > totalRange * 0.6 || lowerWick > totalRange * 0.6);
}

//+------------------------------------------------------------------+
//| Calculate order block strength                                  |
//+------------------------------------------------------------------+
int CalculateOrderBlockStrength(int shift)
{
    int strength = 1; // Base strength
    
    // Check rejection quality
    double rejectionStrength = CalculateRejectionStrength(shift);
    if(rejectionStrength > 0.7) strength++;
    if(rejectionStrength > 0.85) strength++;
    
    // Check volume
    double avgVolume = 0;
    for(int i = 1; i <= 10; i++)
    {
        avgVolume += iVolume(_Symbol, PERIOD_CURRENT, shift + i);
    }
    avgVolume /= 10;
    
    double currentVolume = iVolume(_Symbol, PERIOD_CURRENT, shift);
    if(currentVolume > avgVolume * 1.5) strength++;
    if(currentVolume > avgVolume * 2.0) strength++;
    
    return MathMin(strength, 5);
}

//+------------------------------------------------------------------+
//| Calculate rejection strength                                    |
//+------------------------------------------------------------------+
double CalculateRejectionStrength(int shift)
{
    double open = iOpen(_Symbol, PERIOD_CURRENT, shift);
    double close = iClose(_Symbol, PERIOD_CURRENT, shift);
    double high = iHigh(_Symbol, PERIOD_CURRENT, shift);
    double low = iLow(_Symbol, PERIOD_CURRENT, shift);
    
    double bodySize = MathAbs(close - open);
    double upperWick = high - MathMax(open, close);
    double lowerWick = MathMin(open, close) - low;
    double totalRange = high - low;
    
    if(totalRange == 0) return 0.0;
    
    // Return the percentage of the larger wick
    double maxWick = MathMax(upperWick, lowerWick);
    return maxWick / totalRange;
}

//+------------------------------------------------------------------+
//| Get current SMC analysis                                        |
//+------------------------------------------------------------------+
SMCAnalysis GetCurrentSMCAnalysis()
{
    SMCAnalysis analysis;
    ZeroMemory(analysis);
    
    // Find the most recent valid order block
    OrderBlock bestOB;
    ZeroMemory(bestOB);
    bool foundValidOB = false;
    
    for(int i = ArraySize(g_orderBlocks) - 1; i >= 0; i--)
    {
        if(IsOrderBlockValid(g_orderBlocks[i]) && !g_orderBlocks[i].is_mitigated)
        {
            bestOB = g_orderBlocks[i];
            foundValidOB = true;
            break;
        }
    }
    
    if(!foundValidOB)
    {
        return analysis;
    }
    
    // Check if current price is near the order block
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double atr = GetATR();
    double obDistance = 0.0;
    
    if(bestOB.type == ORDER_BLOCK_BULLISH)
    {
        obDistance = MathAbs(currentPrice - bestOB.price_low);
    }
    else if(bestOB.type == ORDER_BLOCK_BEARISH)
    {
        obDistance = MathAbs(currentPrice - bestOB.price_high);
    }
    
    // Check if price is within reasonable distance of order block
    if(obDistance > atr * 2.0)
    {
        return analysis;
    }
    
    // We have a valid setup
    analysis.hasValidSetup = true;
    analysis.setupType = bestOB.type;
    analysis.orderBlockStrength = bestOB.strength;
    
    // Calculate entry, stop loss, and take profit
    if(bestOB.type == ORDER_BLOCK_BULLISH)
    {
        analysis.entryPrice = bestOB.price_low;
        analysis.stopLoss = bestOB.price_low - (atr * 1.5);
        analysis.takeProfit = bestOB.price_low + ((bestOB.price_low - analysis.stopLoss) * 2.0);
        analysis.setupDescription = "Bullish Order Block at " + DoubleToString(bestOB.price_low, _Digits);
    }
    else
    {
        analysis.entryPrice = bestOB.price_high;
        analysis.stopLoss = bestOB.price_high + (atr * 1.5);
        analysis.takeProfit = bestOB.price_high - ((analysis.stopLoss - bestOB.price_high) * 2.0);
        analysis.setupDescription = "Bearish Order Block at " + DoubleToString(bestOB.price_high, _Digits);
    }
    
    // Calculate confidence score
    double confidence = 0.3; // Base confidence for valid OB
    
    if(analysis.orderBlockStrength >= 4) confidence += 0.2;
    if(analysis.fibonacciAlignment) confidence += 0.15;
    if(analysis.volumeConfirmation) confidence += 0.1;
    if(analysis.multiTimeframeAlignment) confidence += 0.15;
    if(analysis.liquidityGrabDetected) confidence += 0.1;
    
    analysis.confidenceScore = MathMin(confidence, 1.0);
    
    return analysis;
}

//+------------------------------------------------------------------+
//| Check if order block is valid                                   |
//+------------------------------------------------------------------+
bool IsOrderBlockValid(const OrderBlock& ob)
{
    // Check if order block is too old
    if(TimeCurrent() - ob.timestamp > PeriodSeconds(PERIOD_D1) * 7) // 7 days
    {
        return false;
    }
    
    // Check if order block has been mitigated
    if(ob.is_mitigated)
    {
        return false;
    }
    
    // Check minimum strength
    if(ob.strength < 2)
    {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get ATR value                                                   |
//+------------------------------------------------------------------+
double GetATR()
{
    if(ArraySize(g_atr) > 0)
    {
        return g_atr[0];
    }
    return 0.0001; // Default small value
}

//+------------------------------------------------------------------+
//| Update risk metrics                                             |
//+------------------------------------------------------------------+
void UpdateRiskMetrics()
{
    g_accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    g_accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    g_riskMetrics.current_equity = g_accountEquity;
    
    // Calculate drawdowns
    if(g_riskMetrics.starting_equity > 0)
    {
        g_riskMetrics.current_drawdown = ((g_riskMetrics.starting_equity - g_accountEquity) / g_riskMetrics.starting_equity) * 100.0;
    }
    
    if(g_riskMetrics.daily_starting_equity > 0)
    {
        g_riskMetrics.daily_drawdown = ((g_riskMetrics.daily_starting_equity - g_accountEquity) / g_riskMetrics.daily_starting_equity) * 100.0;
    }
    
    // Update maximum drawdowns
    g_riskMetrics.max_drawdown_today = MathMax(g_riskMetrics.max_drawdown_today, g_riskMetrics.daily_drawdown);
    g_riskMetrics.max_drawdown_overall = MathMax(g_riskMetrics.max_drawdown_overall, g_riskMetrics.current_drawdown);
    
    g_riskMetrics.open_positions = PositionsTotal();
}

//+------------------------------------------------------------------+
//| Update psychology state                                         |
//+------------------------------------------------------------------+
void UpdatePsychologyState()
{
    // Check if cooling off period has expired
    if(g_coolingOff && (TimeCurrent() - g_lastLossTime) > (InpCoolingOffPeriod * 60))
    {
        g_coolingOff = false;
        Print("[PsyTradeAI] Cooling off period expired - trading resumed");
    }
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                     |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
    // Check if cooling off
    if(g_coolingOff)
    {
        return false;
    }
    
    // Check drawdown limits
    if(g_riskMetrics.daily_drawdown >= InpMaxDailyDD)
    {
        Print("[PsyTradeAI] Trading blocked: Daily drawdown limit reached");
        return false;
    }
    
    if(g_riskMetrics.current_drawdown >= InpMaxOverallDD)
    {
        Print("[PsyTradeAI] Trading blocked: Overall drawdown limit reached");
        return false;
    }
    
    // Check maximum open trades
    if(PositionsTotal() >= InpMaxOpenTrades)
    {
        return false;
    }
    
    // Check account equity
    if(g_accountEquity <= 0)
    {
        Print("[PsyTradeAI] Trading blocked: Invalid account equity");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Analyze market and execute trades                               |
//+------------------------------------------------------------------+
void AnalyzeMarketAndTrade()
{
    // Get SMC analysis
    SMCAnalysis analysis = GetCurrentSMCAnalysis();
    
    // Check if we have a valid setup
    if(!analysis.hasValidSetup)
        return;
    
    // Check confidence threshold
    if(analysis.confidenceScore < InpConfidenceThreshold)
        return;
    
    // Calculate position size
    double positionSize = CalculatePositionSize(analysis.entryPrice, analysis.stopLoss);
    if(positionSize <= 0)
        return;
    
    // Create trade request
    TradeRequest request;
    request.symbol = _Symbol;
    request.volume = positionSize;
    request.price = analysis.entryPrice;
    request.stop_loss = analysis.stopLoss;
    request.take_profit = analysis.takeProfit;
    request.comment = InpTradeComment + " | " + analysis.setupDescription;
    
    // Determine order type based on setup
    if(analysis.setupType == ORDER_BLOCK_BULLISH)
    {
        request.order_type = ORDER_TYPE_BUY;
    }
    else if(analysis.setupType == ORDER_BLOCK_BEARISH)
    {
        request.order_type = ORDER_TYPE_SELL;
    }
    else
    {
        return; // Invalid setup type
    }
    
    // Execute the trade
    if(ExecuteTrade(request, analysis.confidenceScore))
    {
        Print("[PsyTradeAI] ✓ Trade executed: ", analysis.setupDescription, 
              " | Confidence: ", DoubleToString(analysis.confidenceScore, 2));
        
        if(InpSendAlerts)
        {
            Alert("[PsyTradeAI] Trade opened: ", _Symbol, " | ", 
                  DoubleToString(request.volume, 2), " lots | Conf: ", 
                  DoubleToString(analysis.confidenceScore, 2));
        }
    }
    else
    {
        Print("[PsyTradeAI] ✗ Trade execution failed");
    }
}

//+------------------------------------------------------------------+
//| Calculate position size                                         |
//+------------------------------------------------------------------+
double CalculatePositionSize(double entryPrice, double stopLoss)
{
    if(entryPrice <= 0 || stopLoss <= 0)
        return 0;
    
    // Calculate risk amount in account currency
    double riskAmount = (g_accountEquity * InpRiskPerTrade) / 100.0;
    
    // Calculate pip risk
    double pipRisk = MathAbs(entryPrice - stopLoss);
    if(pipRisk <= 0)
        return 0;
    
    // Get symbol specifications
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    if(tickValue <= 0 || tickSize <= 0)
        return 0;
    
    // Calculate position size
    double pipValue = (tickValue / tickSize);
    double positionSize = riskAmount / (pipRisk * pipValue);
    
    // Apply lot size restrictions
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    // Round to lot step
    positionSize = MathFloor(positionSize / lotStep) * lotStep;
    
    // Apply min/max limits
    positionSize = MathMax(minLot, MathMin(positionSize, maxLot));
    
    return positionSize;
}

//+------------------------------------------------------------------+
//| Execute trade                                                   |
//+------------------------------------------------------------------+
bool ExecuteTrade(const TradeRequest& request, double confidence)
{
    // Normalize price and volume
    double normalizedPrice = NormalizeDouble(request.price, _Digits);
    double normalizedVolume = NormalizeDouble(request.volume, 2);
    double normalizedSL = NormalizeDouble(request.stop_loss, _Digits);
    double normalizedTP = NormalizeDouble(request.take_profit, _Digits);
    
    // Prepare comment with confidence
    string fullComment = request.comment + " | Conf:" + DoubleToString(confidence, 2);
    
    bool success = false;
    
    // Execute based on order type
    switch(request.order_type)
    {
        case ORDER_TYPE_BUY:
            success = g_trade.Buy(normalizedVolume, request.symbol, normalizedPrice, 
                                normalizedSL, normalizedTP, fullComment);
            break;
            
        case ORDER_TYPE_SELL:
            success = g_trade.Sell(normalizedVolume, request.symbol, normalizedPrice, 
                                 normalizedSL, normalizedTP, fullComment);
            break;
    }
    
    if(success)
    {
        g_totalTrades++;
        ulong ticket = g_trade.ResultOrder();
        Print("[PsyTradeAI] Trade executed successfully - Ticket: " + IntegerToString(ticket));
        return true;
    }
    else
    {
        string error = "Error " + IntegerToString(g_trade.ResultRetcode()) + ": " + g_trade.ResultRetcodeDescription();
        Print("[PsyTradeAI] Trade execution failed - " + error);
        
        // Record failed trade for psychology
        if(InpEnforceEmotionalRules)
        {
            g_consecutiveLosses++;
            g_lastLossTime = TimeCurrent();
            
            if(g_consecutiveLosses >= InpMaxConsecutiveLosses)
            {
                g_coolingOff = true;
                Print("[PsyTradeAI] Cooling off period activated after ", g_consecutiveLosses, " consecutive losses");
            }
        }
        
        return false;
    }
}

//+------------------------------------------------------------------+
//| Monitor positions                                               |
//+------------------------------------------------------------------+
void MonitorPositions()
{
    // Simple position monitoring
    for(int i = 0; i < PositionsTotal(); i++)
    {
        ulong posTicket = PositionGetTicket(i);
        if(posTicket > 0 && PositionSelectByTicket(posTicket))
        {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                // Basic trailing stop logic could be added here
                // For now, just monitor
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Update real-time monitoring                                     |
//+------------------------------------------------------------------+
void UpdateRealTimeMonitoring()
{
    // Update risk metrics
    UpdateRiskMetrics();
    
    // Check for emergency stop conditions
    if(g_riskMetrics.current_drawdown >= InpEmergencyStop)
    {
        Print("[PsyTradeAI] 🚨 EMERGENCY STOP TRIGGERED!");
        CloseAllPositions("Emergency Stop");
        g_riskMetrics.emergency_stop_triggered = true;
        
        if(InpSendAlerts)
            Alert("[PsyTradeAI] EMERGENCY STOP: All positions closed!");
    }
}

//+------------------------------------------------------------------+
//| Close all positions                                             |
//+------------------------------------------------------------------+
bool CloseAllPositions(string reason)
{
    Print("[PsyTradeAI] Closing all positions - Reason: " + reason);
    
    bool allClosed = true;
    
    // Close all positions with our magic number
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong posTicket = PositionGetTicket(i);
        if(posTicket > 0 && PositionSelectByTicket(posTicket))
        {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                if(!g_trade.PositionClose(posTicket))
                {
                    Print("[PsyTradeAI] Failed to close position " + IntegerToString(posTicket));
                    allClosed = false;
                }
                else
                {
                    Print("[PsyTradeAI] Closed position " + IntegerToString(posTicket));
                }
            }
        }
    }
    
    if(allClosed && InpSendAlerts)
    {
        Alert("[PsyTradeAI] All positions closed: " + reason);
    }
    
    return allClosed;
}

//+------------------------------------------------------------------+
//| Generate performance report                                     |
//+------------------------------------------------------------------+
void GeneratePerformanceReport()
{
    string report = "\n=== PSYTRADEAI PERFORMANCE REPORT ===\n";
    report += "Generated: " + TimeToString(TimeCurrent()) + "\n\n";
    
    report += "BASIC METRICS:\n";
    report += "Total Trades: " + IntegerToString(g_totalTrades) + "\n";
    if(g_totalTrades > 0)
    {
        double winRate = ((double)g_winningTrades / g_totalTrades) * 100.0;
        report += "Win Rate: " + DoubleToString(winRate, 2) + "%\n";
    }
    report += "Total Profit: " + DoubleToString(g_totalProfit, 2) + "\n\n";
    
    report += "RISK METRICS:\n";
    report += "Max Drawdown: " + DoubleToString(g_riskMetrics.max_drawdown_overall, 2) + "%\n";
    report += "Current Drawdown: " + DoubleToString(g_riskMetrics.current_drawdown, 2) + "%\n\n";
    
    report += "ACCOUNT GROWTH:\n";
    report += "Starting Balance: " + DoubleToString(g_riskMetrics.starting_equity, 2) + "\n";
    report += "Current Balance: " + DoubleToString(g_riskMetrics.current_equity, 2) + "\n";
    if(g_riskMetrics.starting_equity > 0)
    {
        double growthRate = ((g_riskMetrics.current_equity - g_riskMetrics.starting_equity) / g_riskMetrics.starting_equity) * 100.0;
        report += "Growth Rate: " + DoubleToString(growthRate, 2) + "%\n";
    }
    
    Print(report);
}