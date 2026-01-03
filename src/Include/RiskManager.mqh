//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
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

struct TradeRequest
{
    string symbol;
    ENUM_ORDER_TYPE order_type;
    double volume;
    double price;
    double stop_loss;
    double take_profit;
    string comment;
    int magic_number;
    double risk_amount;
    double risk_reward_ratio;
};

struct PositionRisk
{
    ulong ticket;
    string symbol;
    double volume;
    double open_price;
    double stop_loss;
    double take_profit;
    double unrealized_pnl;
    double risk_amount;
    double max_risk_per_position;
    bool is_correlated;
};

//+------------------------------------------------------------------+
//| Risk Manager Class                                              |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
    // Risk parameters
    double m_riskPerTrade;        // Percentage of equity to risk per trade
    double m_maxDailyDD;          // Maximum daily drawdown percentage
    double m_maxOverallDD;        // Maximum overall drawdown percentage
    double m_emergencyStop;       // Emergency stop drawdown percentage
    
    // Risk tracking
    RiskMetrics m_metrics;
    PositionRisk m_positions[];
    
    // Account information
    double m_accountBalance;
    double m_accountEquity;
    double m_accountMargin;
    double m_accountFreeMargin;
    
    // Risk calculation helpers
    double m_tickValue;
    double m_tickSize;
    double m_contractSize;
    
    // Correlation tracking
    string m_correlatedPairs[];
    double m_correlationMatrix[][10]; // Max 10 symbols
    
public:
    CRiskManager();
    ~CRiskManager();
    
    // Initialization
    bool Initialize(double riskPerTrade, double maxDailyDD, double maxOverallDD, double emergencyStop);
    void UpdateRiskMetrics();
    void UpdateRealTimeRisk();
    
    // Trade validation
    bool ValidateTrade(TradeRequest& request);
    bool IsTradeAllowed();
    bool ShouldEmergencyStop();
    
    // Position sizing
    double CalculatePositionSize(string symbol, double entryPrice, double stopLoss, double riskPercent);
    double CalculateRiskAmount(double positionSize, double entryPrice, double stopLoss);
    double GetMaxPositionSize(string symbol);
    
    // Risk monitoring
    void UpdatePositionRisk();
    double CalculatePortfolioRisk();
    double CalculateCorrelationRisk();
    bool CheckDrawdownLimits();
    
    // Account scaling
    double GetScaledRiskPercent();
    double CalculateCompoundingMultiplier();
    bool ShouldReduceRisk();
    
    // Emergency procedures
    void TriggerEmergencyStop();
    void ResetEmergencyStop();
    bool CloseRiskiestPosition();
    
    // Getters
    RiskMetrics GetRiskMetrics() { return m_metrics; }
    double GetCurrentDrawdown() { return m_metrics.current_drawdown; }
    double GetDailyDrawdown() { return m_metrics.daily_drawdown; }
    double GetRiskPerTrade() { return m_riskPerTrade; }
    
    // Setters
    void SetRiskPerTrade(double risk) { m_riskPerTrade = MathMax(0.1, MathMin(risk, 10.0)); }
    void SetMaxDailyDD(double dd) { m_maxDailyDD = MathMax(1.0, MathMin(dd, 50.0)); }
    
private:
    // Helper functions
    void UpdateAccountInfo();
    void CalculateDrawdowns();
    void UpdatePositionArray();
    bool IsSymbolCorrelated(string symbol1, string symbol2);
    double CalculateCorrelation(string symbol1, string symbol2);
    void InitializeCorrelationMatrix();
    double GetSymbolTickValue(string symbol);
    double GetSymbolTickSize(string symbol);
    double GetSymbolContractSize(string symbol);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskManager::CRiskManager()
{
    m_riskPerTrade = 1.0;
    m_maxDailyDD = 5.0;
    m_maxOverallDD = 10.0;
    m_emergencyStop = 3.0;
    
    // Initialize metrics
    ZeroMemory(m_metrics);
    m_metrics.starting_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_metrics.daily_starting_equity = m_metrics.starting_equity;
    m_metrics.last_risk_update = TimeCurrent();
    
    // Initialize arrays
    ArrayResize(m_positions, 0);
    ArrayResize(m_correlatedPairs, 0);
    ArrayResize(m_correlationMatrix, 10, 10);
    
    // Initialize account info
    UpdateAccountInfo();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskManager::~CRiskManager()
{
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Initialize Risk Manager                                         |
//+------------------------------------------------------------------+
bool CRiskManager::Initialize(double riskPerTrade, double maxDailyDD, double maxOverallDD, double emergencyStop)
{
    m_riskPerTrade = MathMax(0.1, MathMin(riskPerTrade, 10.0));
    m_maxDailyDD = MathMax(1.0, MathMin(maxDailyDD, 50.0));
    m_maxOverallDD = MathMax(1.0, MathMin(maxOverallDD, 50.0));
    m_emergencyStop = MathMax(0.5, MathMin(emergencyStop, 20.0));
    
    // Set starting equity levels
    m_metrics.starting_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_metrics.daily_starting_equity = m_metrics.starting_equity;
    
    // Initialize correlation tracking for major pairs
    string majorPairs[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};
    ArrayResize(m_correlatedPairs, ArraySize(majorPairs));
    for(int i = 0; i < ArraySize(majorPairs); i++)
    {
        m_correlatedPairs[i] = majorPairs[i];
    }
    
    InitializeCorrelationMatrix();
    
    Print("[RiskManager] Initialized - Risk per trade: " + DoubleToString(m_riskPerTrade, 1) + 
          "%, Max daily DD: " + DoubleToString(m_maxDailyDD, 1) + 
          "%, Max overall DD: " + DoubleToString(m_maxOverallDD, 1) + "%");
    
    return true;
}

//+------------------------------------------------------------------+
//| Update risk metrics                                             |
//+------------------------------------------------------------------+
void CRiskManager::UpdateRiskMetrics()
{
    UpdateAccountInfo();
    CalculateDrawdowns();
    UpdatePositionRisk();
    
    m_metrics.current_equity = m_accountEquity;
    m_metrics.total_risk_exposure = CalculatePortfolioRisk();
    m_metrics.open_positions = PositionsTotal();
    
    // Calculate unrealized P&L
    m_metrics.unrealized_pnl = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByIndex(i))
        {
            m_metrics.unrealized_pnl += PositionGetDouble(POSITION_PROFIT);
        }
    }
    
    // Calculate realized P&L today
    CalculateRealizedPnLToday();
    
    m_metrics.last_risk_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Validate trade request                                          |
//+------------------------------------------------------------------+
bool CRiskManager::ValidateTrade(TradeRequest& request)
{
    // Check if trading is allowed
    if(!IsTradeAllowed())
    {
        Print("[RiskManager] Trade validation failed: Trading not allowed");
        return false;
    }
    
    // Validate position size
    double maxSize = GetMaxPositionSize(request.symbol);
    if(request.volume > maxSize)
    {
        Print("[RiskManager] Trade validation failed: Position size (" + 
              DoubleToString(request.volume, 2) + ") exceeds maximum (" + 
              DoubleToString(maxSize, 2) + ")");
        return false;
    }
    
    // Calculate and validate risk amount
    double riskAmount = CalculateRiskAmount(request.volume, request.price, request.stop_loss);
    double maxRiskAmount = (m_accountEquity * m_riskPerTrade) / 100.0;
    
    if(riskAmount > maxRiskAmount)
    {
        Print("[RiskManager] Trade validation failed: Risk amount (" + 
              DoubleToString(riskAmount, 2) + ") exceeds maximum (" + 
              DoubleToString(maxRiskAmount, 2) + ")");
        return false;
    }
    
    // Check risk-reward ratio
    double reward = MathAbs(request.take_profit - request.price);
    double risk = MathAbs(request.stop_loss - request.price);
    double rrRatio = (risk > 0) ? reward / risk : 0;
    
    if(rrRatio < request.risk_reward_ratio)
    {
        Print("[RiskManager] Trade validation failed: Risk-reward ratio (" + 
              DoubleToString(rrRatio, 2) + ") below minimum (" + 
              DoubleToString(request.risk_reward_ratio, 2) + ")");
        return false;
    }
    
    // Check correlation risk
    if(CalculateCorrelationRisk() > 0.7) // Max 70% correlation exposure
    {
        Print("[RiskManager] Trade validation failed: High correlation risk detected");
        return false;
    }
    
    // Check total portfolio risk
    double totalRisk = m_metrics.total_risk_exposure + riskAmount;
    double maxTotalRisk = (m_accountEquity * m_riskPerTrade * 3) / 100.0; // Max 3x single trade risk
    
    if(totalRisk > maxTotalRisk)
    {
        Print("[RiskManager] Trade validation failed: Total portfolio risk too high");
        return false;
    }
    
    // Update request with calculated values
    request.risk_amount = riskAmount;
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if trading is allowed based on risk                      |
//+------------------------------------------------------------------+
bool CRiskManager::IsTradeAllowed()
{
    // Check emergency stop
    if(m_metrics.emergency_stop_triggered)
    {
        Print("[RiskManager] Trading blocked: Emergency stop active");
        return false;
    }
    
    // Check drawdown limits
    if(!CheckDrawdownLimits())
    {
        Print("[RiskManager] Trading blocked: Drawdown limits exceeded");
        return false;
    }
    
    // Check account equity
    if(m_accountEquity <= 0)
    {
        Print("[RiskManager] Trading blocked: Invalid account equity");
        return false;
    }
    
    // Check free margin
    if(m_accountFreeMargin < (m_accountEquity * 0.1)) // Minimum 10% free margin
    {
        Print("[RiskManager] Trading blocked: Insufficient free margin");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk                          |
//+------------------------------------------------------------------+
double CRiskManager::CalculatePositionSize(string symbol, double entryPrice, double stopLoss, double riskPercent)
{
    if(entryPrice <= 0 || stopLoss <= 0 || riskPercent <= 0)
        return 0;
    
    // Calculate risk amount in account currency
    double riskAmount = (m_accountEquity * riskPercent) / 100.0;
    
    // Calculate pip risk
    double pipRisk = MathAbs(entryPrice - stopLoss);
    if(pipRisk <= 0)
        return 0;
    
    // Get symbol specifications
    double tickValue = GetSymbolTickValue(symbol);
    double tickSize = GetSymbolTickSize(symbol);
    double contractSize = GetSymbolContractSize(symbol);
    
    if(tickValue <= 0 || tickSize <= 0 || contractSize <= 0)
        return 0;
    
    // Calculate position size
    double pipValue = (tickValue / tickSize);
    double positionSize = riskAmount / (pipRisk * pipValue);
    
    // Apply lot size restrictions
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    // Round to lot step
    positionSize = MathFloor(positionSize / lotStep) * lotStep;
    
    // Apply min/max limits
    positionSize = MathMax(minLot, MathMin(positionSize, maxLot));
    
    return positionSize;
}

//+------------------------------------------------------------------+
//| Calculate drawdowns                                             |
//+------------------------------------------------------------------+
void CRiskManager::CalculateDrawdowns()
{
    // Current overall drawdown
    if(m_metrics.starting_equity > 0)
    {
        m_metrics.current_drawdown = ((m_metrics.starting_equity - m_accountEquity) / m_metrics.starting_equity) * 100.0;
    }
    
    // Daily drawdown
    if(m_metrics.daily_starting_equity > 0)
    {
        m_metrics.daily_drawdown = ((m_metrics.daily_starting_equity - m_accountEquity) / m_metrics.daily_starting_equity) * 100.0;
    }
    
    // Update maximum drawdowns
    m_metrics.max_drawdown_today = MathMax(m_metrics.max_drawdown_today, m_metrics.daily_drawdown);
    m_metrics.max_drawdown_overall = MathMax(m_metrics.max_drawdown_overall, m_metrics.current_drawdown);
}

//+------------------------------------------------------------------+
//| Check drawdown limits                                           |
//+------------------------------------------------------------------+
bool CRiskManager::CheckDrawdownLimits()
{
    // Check daily drawdown
    if(m_metrics.daily_drawdown >= m_maxDailyDD)
    {
        Print("[RiskManager] Daily drawdown limit exceeded: " + 
              DoubleToString(m_metrics.daily_drawdown, 2) + "% >= " + 
              DoubleToString(m_maxDailyDD, 2) + "%");
        return false;
    }
    
    // Check overall drawdown
    if(m_metrics.current_drawdown >= m_maxOverallDD)
    {
        Print("[RiskManager] Overall drawdown limit exceeded: " + 
              DoubleToString(m_metrics.current_drawdown, 2) + "% >= " + 
              DoubleToString(m_maxOverallDD, 2) + "%");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if emergency stop should be triggered                    |
//+------------------------------------------------------------------+
bool CRiskManager::ShouldEmergencyStop()
{
    // Check emergency drawdown threshold
    if(m_metrics.current_drawdown >= m_emergencyStop)
    {
        Print("[RiskManager] Emergency stop threshold reached: " + 
              DoubleToString(m_metrics.current_drawdown, 2) + "% >= " + 
              DoubleToString(m_emergencyStop, 2) + "%");
        return true;
    }
    
    // Check rapid equity loss (more than 2% in 5 minutes)
    static double lastEquity = m_accountEquity;
    static datetime lastCheck = TimeCurrent();
    
    if(TimeCurrent() - lastCheck >= 300) // 5 minutes
    {
        double equityChange = ((lastEquity - m_accountEquity) / lastEquity) * 100.0;
        if(equityChange >= 2.0)
        {
            Print("[RiskManager] Rapid equity loss detected: " + DoubleToString(equityChange, 2) + "% in 5 minutes");
            return true;
        }
        lastEquity = m_accountEquity;
        lastCheck = TimeCurrent();
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Update account information                                      |
//+------------------------------------------------------------------+
void CRiskManager::UpdateAccountInfo()
{
    m_accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_accountMargin = AccountInfoDouble(ACCOUNT_MARGIN);
    m_accountFreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
}

//+------------------------------------------------------------------+
//| Get symbol specifications                                       |
//+------------------------------------------------------------------+
double CRiskManager::GetSymbolTickValue(string symbol)
{
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
}

double CRiskManager::GetSymbolTickSize(string symbol)
{
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
}

double CRiskManager::GetSymbolContractSize(string symbol)
{
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
}

//--- Additional risk management methods continue...