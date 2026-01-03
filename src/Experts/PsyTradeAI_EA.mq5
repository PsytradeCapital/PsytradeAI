//+------------------------------------------------------------------+
//|                                                 PsyTradeAI_EA.mq5 |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"
#property version   "1.00"
#property description "AI-Powered Trading Robot with Smart Money Concepts & Psychology"

//--- Include necessary files
#include "..\\Include\\SMCDetector.mqh"
#include "..\\Include\\PsychologyManager.mqh"
#include "..\\Include\\RiskManager.mqh"
#include "..\\Include\\PropFirmManager.mqh"
#include "..\\Include\\TradeManager.mqh"
#include "..\\Include\\NewsManager.mqh"
#include "..\\Include\\PerformanceTracker.mqh"

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

input group "=== Prop Firm Settings ==="
input ENUM_PROP_FIRM InpPropFirmType = PROP_FIRM_NONE; // Prop firm type
input bool   InpWeekendTrading = true;     // Allow weekend trading
input int    InpMinHoldingTime = 60;       // Minimum holding time (seconds)
input double InpPropDailyDD = 5.0;         // Prop firm daily DD limit (%)
input double InpPropOverallDD = 10.0;      // Prop firm overall DD limit (%)

input group "=== Psychology Settings ==="
input int    InpCoolingOffPeriod = 30;     // Minutes after loss before next trade
input int    InpMaxConsecutiveLosses = 3;  // Max losses before size reduction
input bool   InpEnforceEmotionalRules = true; // Enable psychological rules
input double InpConfidenceThreshold = 0.7; // Minimum setup confidence (0-1)

input group "=== Trading Hours ==="
input bool   InpTradeLondonSession = true; // Trade London session
input bool   InpTradeNewYorkSession = true; // Trade New York session
input bool   InpTradeAsianSession = false; // Trade Asian session
input int    InpNewsFilterMinutes = 30;    // Minutes to avoid before/after news

input group "=== General Settings ==="
input int    InpMagicNumber = 12345;       // Magic number for trades
input string InpTradeComment = "PsyTradeAI"; // Trade comment
input bool   InpShowVisuals = true;        // Show visual indicators
input bool   InpSendAlerts = true;         // Send trade alerts
input ENUM_TIMEFRAMES InpHigherTF = PERIOD_H4; // Higher timeframe for structure
input ENUM_TIMEFRAMES InpLowerTF = PERIOD_M15;  // Lower timeframe for entries

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CSMCDetector*       g_SMCDetector;
CPsychologyManager* g_PsychologyManager;
CRiskManager*       g_RiskManager;
CPropFirmManager*   g_PropFirmManager;
CTradeManager*      g_TradeManager;
CNewsManager*       g_NewsManager;
CPerformanceTracker* g_PerformanceTracker;

datetime g_LastBarTime;
bool     g_IsInitialized = false;
string   g_LogPrefix = "[PsyTradeAI] ";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print(g_LogPrefix + "Initializing PsyTradeAI Expert Advisor v1.00");
    
    // Initialize components
    if(!InitializeComponents())
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize components");
        return INIT_FAILED;
    }
    
    // Validate input parameters
    if(!ValidateInputs())
    {
        Print(g_LogPrefix + "ERROR: Invalid input parameters");
        return INIT_PARAMETERS_INCORRECT;
    }
    
    // Set up chart visuals if enabled
    if(InpShowVisuals)
    {
        SetupChartVisuals();
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
    
    // Clean up components
    if(g_SMCDetector != NULL)
    {
        delete g_SMCDetector;
        g_SMCDetector = NULL;
    }
    
    if(g_PsychologyManager != NULL)
    {
        delete g_PsychologyManager;
        g_PsychologyManager = NULL;
    }
    
    if(g_RiskManager != NULL)
    {
        delete g_RiskManager;
        g_RiskManager = NULL;
    }
    
    if(g_PropFirmManager != NULL)
    {
        delete g_PropFirmManager;
        g_PropFirmManager = NULL;
    }
    
    if(g_TradeManager != NULL)
    {
        delete g_TradeManager;
        g_TradeManager = NULL;
    }
    
    if(g_NewsManager != NULL)
    {
        delete g_NewsManager;
        g_NewsManager = NULL;
    }
    
    if(g_PerformanceTracker != NULL)
    {
        delete g_PerformanceTracker;
        g_PerformanceTracker = NULL;
    }
    
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
    // Update all components with new bar data
    g_SMCDetector.UpdateAnalysis();
    g_PsychologyManager.UpdateState();
    g_RiskManager.UpdateRiskMetrics();
    g_PropFirmManager.UpdateCompliance();
    g_NewsManager.UpdateNewsStatus();
    g_PerformanceTracker.UpdateMetrics();
    
    // Check if trading is allowed
    if(!IsTradeAllowed())
    {
        return;
    }
    
    // Analyze market for trading opportunities
    AnalyzeMarketAndTrade();
}

//+------------------------------------------------------------------+
//| Initialize all components                                        |
//+------------------------------------------------------------------+
bool InitializeComponents()
{
    // Initialize SMC Detector
    g_SMCDetector = new CSMCDetector();
    if(!g_SMCDetector.Initialize(_Symbol, InpOrderBlockLookback, InpFVGMinSize, InpStructureLookback))
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize SMC Detector");
        return false;
    }
    
    // Initialize Psychology Manager
    g_PsychologyManager = new CPsychologyManager();
    if(!g_PsychologyManager.Initialize(InpCoolingOffPeriod, InpMaxConsecutiveLosses, InpConfidenceThreshold))
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize Psychology Manager");
        return false;
    }
    
    // Initialize Risk Manager
    g_RiskManager = new CRiskManager();
    if(!g_RiskManager.Initialize(InpRiskPerTrade, InpMaxDailyDD, InpMaxOverallDD, InpEmergencyStop))
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize Risk Manager");
        return false;
    }
    
    // Initialize Prop Firm Manager
    g_PropFirmManager = new CPropFirmManager();
    if(!g_PropFirmManager.Initialize(InpPropFirmType, InpPropDailyDD, InpPropOverallDD, InpMinHoldingTime))
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize Prop Firm Manager");
        return false;
    }
    
    // Initialize Trade Manager
    g_TradeManager = new CTradeManager();
    if(!g_TradeManager.Initialize(InpMagicNumber, InpTradeComment, InpMinRiskReward))
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize Trade Manager");
        return false;
    }
    
    // Initialize News Manager
    g_NewsManager = new CNewsManager();
    if(!g_NewsManager.Initialize(InpNewsFilterMinutes))
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize News Manager");
        return false;
    }
    
    // Initialize Performance Tracker
    g_PerformanceTracker = new CPerformanceTracker();
    if(!g_PerformanceTracker.Initialize())
    {
        Print(g_LogPrefix + "ERROR: Failed to initialize Performance Tracker");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Validate input parameters                                        |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
    if(InpRiskPerTrade <= 0 || InpRiskPerTrade > 10)
    {
        Print(g_LogPrefix + "ERROR: Risk per trade must be between 0 and 10%");
        return false;
    }
    
    if(InpMaxDailyDD <= 0 || InpMaxDailyDD > 50)
    {
        Print(g_LogPrefix + "ERROR: Max daily drawdown must be between 0 and 50%");
        return false;
    }
    
    if(InpMaxOverallDD <= 0 || InpMaxOverallDD > 50)
    {
        Print(g_LogPrefix + "ERROR: Max overall drawdown must be between 0 and 50%");
        return false;
    }
    
    if(InpMaxOpenTrades <= 0 || InpMaxOpenTrades > 10)
    {
        Print(g_LogPrefix + "ERROR: Max open trades must be between 1 and 10");
        return false;
    }
    
    if(InpMinRiskReward < 1.0)
    {
        Print(g_LogPrefix + "ERROR: Minimum risk-reward ratio must be at least 1.0");
        return false;
    }
    
    if(InpConfidenceThreshold < 0.1 || InpConfidenceThreshold > 1.0)
    {
        Print(g_LogPrefix + "ERROR: Confidence threshold must be between 0.1 and 1.0");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if trading is currently allowed                           |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
    // Check psychology rules
    if(!g_PsychologyManager.IsTradeAllowed())
    {
        return false;
    }
    
    // Check risk management
    if(!g_RiskManager.IsTradeAllowed())
    {
        return false;
    }
    
    // Check prop firm compliance
    if(!g_PropFirmManager.IsTradeAllowed())
    {
        return false;
    }
    
    // Check news events
    if(!g_NewsManager.IsTradeAllowed())
    {
        return false;
    }
    
    // Check trading sessions
    if(!IsTradingSessionActive())
    {
        return false;
    }
    
    // Check maximum open trades
    if(g_TradeManager.GetOpenTradesCount() >= InpMaxOpenTrades)
    {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if current trading session is active                      |
//+------------------------------------------------------------------+
bool IsTradingSessionActive()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    int currentHour = dt.hour;
    
    // London Session: 8:00 - 17:00 GMT
    if(InpTradeLondonSession && currentHour >= 8 && currentHour < 17)
        return true;
    
    // New York Session: 13:00 - 22:00 GMT  
    if(InpTradeNewYorkSession && currentHour >= 13 && currentHour < 22)
        return true;
    
    // Asian Session: 23:00 - 8:00 GMT
    if(InpTradeAsianSession && (currentHour >= 23 || currentHour < 8))
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Analyze market and execute trades                               |
//+------------------------------------------------------------------+
void AnalyzeMarketAndTrade()
{
    // Get SMC analysis
    SMCAnalysis smcAnalysis = g_SMCDetector.GetCurrentAnalysis();
    
    // Check for valid SMC setup
    if(!smcAnalysis.hasValidSetup)
    {
        return;
    }
    
    // Multi-timeframe confluence check
    if(InpUseMultiTimeframe)
    {
        if(!CheckMultiTimeframeConfluence(smcAnalysis))
        {
            return;
        }
    }
    
    // Calculate setup confidence
    double confidence = CalculateSetupConfidence(smcAnalysis);
    if(confidence < InpConfidenceThreshold)
    {
        Print(g_LogPrefix + "Setup confidence (" + DoubleToString(confidence, 2) + 
              ") below threshold (" + DoubleToString(InpConfidenceThreshold, 2) + ")");
        return;
    }
    
    // Prepare trade request
    TradeRequest request;
    if(!PrepareTradeRequest(smcAnalysis, request))
    {
        return;
    }
    
    // Validate trade with risk management
    if(!g_RiskManager.ValidateTrade(request))
    {
        return;
    }
    
    // Validate with prop firm rules
    if(!g_PropFirmManager.ValidateTrade(request))
    {
        return;
    }
    
    // Execute trade
    ExecuteTrade(request, confidence);
}

//+------------------------------------------------------------------+
//| Update real-time monitoring                                     |
//+------------------------------------------------------------------+
void UpdateRealTimeMonitoring()
{
    // Monitor existing positions
    g_TradeManager.MonitorPositions();
    
    // Update risk metrics
    g_RiskManager.UpdateRealTimeRisk();
    
    // Check for emergency stops
    if(g_RiskManager.ShouldEmergencyStop())
    {
        Print(g_LogPrefix + "EMERGENCY STOP TRIGGERED - Closing all positions");
        g_TradeManager.CloseAllPositions("Emergency stop activated");
        g_PsychologyManager.TriggerEmergencyStop();
    }
    
    // Update performance tracking
    g_PerformanceTracker.UpdateRealTimeMetrics();
}

//+------------------------------------------------------------------+
//| Setup chart visual indicators                                   |
//+------------------------------------------------------------------+
void SetupChartVisuals()
{
    // This will be implemented to show SMC levels, trade signals, etc.
    Print(g_LogPrefix + "Chart visuals enabled - SMC levels and signals will be displayed");
}

//+------------------------------------------------------------------+
//| Calculate setup confidence based on multiple factors           |
//+------------------------------------------------------------------+
double CalculateSetupConfidence(const SMCAnalysis& analysis)
{
    double confidence = 0.0;
    int factors = 0;
    
    // SMC setup quality (40% weight)
    if(analysis.orderBlockStrength >= 3)
    {
        confidence += 0.4 * (analysis.orderBlockStrength / 5.0);
        factors++;
    }
    
    // Multi-timeframe alignment (30% weight)
    if(analysis.multiTimeframeAlignment)
    {
        confidence += 0.3;
        factors++;
    }
    
    // Technical confluence (20% weight)
    if(analysis.fibonacciAlignment)
    {
        confidence += 0.2;
        factors++;
    }
    
    // Volume confirmation (10% weight)
    if(analysis.volumeConfirmation)
    {
        confidence += 0.1;
        factors++;
    }
    
    // Normalize based on available factors
    if(factors > 0)
    {
        confidence = confidence * (4.0 / factors); // Normalize to max 1.0
        confidence = MathMin(confidence, 1.0);
    }
    
    return confidence;
}

//+------------------------------------------------------------------+
//| Check multi-timeframe confluence                               |
//+------------------------------------------------------------------+
bool CheckMultiTimeframeConfluence(const SMCAnalysis& analysis)
{
    // Get higher timeframe trend
    double htfHigh = iHigh(_Symbol, InpHigherTF, 1);
    double htfLow = iLow(_Symbol, InpHigherTF, 1);
    double htfClose = iClose(_Symbol, InpHigherTF, 1);
    double htfOpen = iOpen(_Symbol, InpHigherTF, 1);
    
    // Determine higher timeframe bias
    bool htfBullish = htfClose > htfOpen;
    
    // Check alignment with setup
    if(analysis.setupType == ORDER_BLOCK_BULLISH && !htfBullish)
    {
        return false;
    }
    
    if(analysis.setupType == ORDER_BLOCK_BEARISH && htfBullish)
    {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Prepare trade request from SMC analysis                        |
//+------------------------------------------------------------------+
bool PrepareTradeRequest(const SMCAnalysis& analysis, TradeRequest& request)
{
    request.symbol = _Symbol;
    request.entry_price = analysis.entryPrice;
    request.stop_loss = analysis.stopLoss;
    request.take_profit = analysis.takeProfit;
    request.risk_reward_ratio = InpMinRiskReward;
    request.magic_number = InpMagicNumber;
    request.comment = InpTradeComment;
    
    // Determine order type
    if(analysis.setupType == ORDER_BLOCK_BULLISH)
    {
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        if(analysis.entryPrice <= currentPrice)
        {
            request.order_type = ORDER_TYPE_BUY;
            request.price = currentPrice;
        }
        else
        {
            request.order_type = ORDER_TYPE_BUY_LIMIT;
            request.price = analysis.entryPrice;
        }
    }
    else if(analysis.setupType == ORDER_BLOCK_BEARISH)
    {
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        if(analysis.entryPrice >= currentPrice)
        {
            request.order_type = ORDER_TYPE_SELL;
            request.price = currentPrice;
        }
        else
        {
            request.order_type = ORDER_TYPE_SELL_LIMIT;
            request.price = analysis.entryPrice;
        }
    }
    else
    {
        return false;
    }
    
    // Calculate position size
    request.volume = g_RiskManager.CalculatePositionSize(_Symbol, request.price, 
                                                        request.stop_loss, InpRiskPerTrade);
    
    if(request.volume <= 0)
    {
        Print(g_LogPrefix + "Invalid position size calculated");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Execute trade with all validations                             |
//+------------------------------------------------------------------+
void ExecuteTrade(const TradeRequest& request, double confidence)
{
    // Log trade decision with psychological reminder
    string psychReminder = g_PsychologyManager.GetCurrentPsychologicalReminder();
    Print(g_LogPrefix + "Executing trade with discipline: " + psychReminder);
    
    // Execute through trade manager
    if(g_TradeManager.ExecuteTrade(request, confidence))
    {
        // Record trade attempt for psychology tracking
        g_PsychologyManager.RecordTradeAttempt();
        
        Print(g_LogPrefix + "Trade executed successfully - " + request.symbol + 
              " | Volume: " + DoubleToString(request.volume, 2) + 
              " | Confidence: " + DoubleToString(confidence, 2));
    }
    else
    {
        Print(g_LogPrefix + "Trade execution failed - " + request.symbol);
    }
}

//+------------------------------------------------------------------+
//| Calculate realized P&L for today                               |
//+------------------------------------------------------------------+
void CalculateRealizedPnLToday()
{
    double realizedPnL = 0;
    datetime todayStart = 0;
    
    // Get start of today
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    todayStart = StructToTime(dt);
    
    // Check deals history for today
    if(HistorySelect(todayStart, TimeCurrent()))
    {
        int totalDeals = HistoryDealsTotal();
        for(int i = 0; i < totalDeals; i++)
        {
            ulong ticket = HistoryDealGetTicket(i);
            if(ticket > 0)
            {
                if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == InpMagicNumber)
                {
                    ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
                    if(dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL)
                    {
                        realizedPnL += HistoryDealGetDouble(ticket, DEAL_PROFIT);
                    }
                }
            }
        }
    }
    
    // Update risk manager with realized P&L
    // This would be implemented in RiskManager if needed
}

//+------------------------------------------------------------------+
//| Load trade history from account for performance tracking      |
//+------------------------------------------------------------------+
void LoadTradeHistoryFromAccount()
{
    // This function would load historical trades for performance analysis
    // Implementation depends on how much history we want to analyze
    datetime startTime = TimeCurrent() - (30 * 24 * 3600); // Last 30 days
    
    if(HistorySelect(startTime, TimeCurrent()))
    {
        int totalDeals = HistoryDealsTotal();
        Print(g_LogPrefix + "Loading " + IntegerToString(totalDeals) + " historical deals for analysis");
        
        // Process historical deals for performance tracking
        // This would be implemented based on specific requirements
    }
}