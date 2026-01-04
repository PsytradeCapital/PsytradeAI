//+------------------------------------------------------------------+
//|                                               PropFirmManager.mqh |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"

// Forward declarations
struct TradeRequest;

//+------------------------------------------------------------------+
//| Forward Declarations and Structures                             |
//+------------------------------------------------------------------+
// TradeRequest is defined in TradeManager.mqh - using that definition

enum ENUM_VIOLATION_SEVERITY
{
    VIOLATION_INFO,
    VIOLATION_WARNING,
    VIOLATION_CRITICAL
};

struct ViolationRecord
{
    string type;
    string description;
    datetime timestamp;
    ENUM_VIOLATION_SEVERITY severity;
};

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

enum ENUM_ACCOUNT_PHASE
{
    PHASE_CHALLENGE_1,
    PHASE_CHALLENGE_2,
    PHASE_VERIFICATION,
    PHASE_LIVE_FUNDED,
    PHASE_UNKNOWN
};

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct PropFirmRules
{
    string firm_name;
    double daily_drawdown_limit;      // Daily DD limit (%)
    double overall_drawdown_limit;    // Overall DD limit (%)
    double profit_target_phase1;      // Phase 1 profit target (%)
    double profit_target_phase2;      // Phase 2 profit target (%)
    int min_trading_days;             // Minimum trading days
    int max_trading_days;             // Maximum trading days for challenge
    bool weekend_trading_allowed;     // Weekend trading permission
    bool news_trading_allowed;        // News trading permission
    int min_holding_time;             // Minimum position holding time (seconds)
    int max_holding_time;             // Maximum position holding time (seconds)
    double max_lot_size;              // Maximum lot size per trade
    double max_daily_loss;            // Maximum daily loss amount
    bool requires_consistency;        // Requires consistent trading
    bool allows_ea_trading;           // Allows Expert Advisor trading
    bool allows_copy_trading;         // Allows copy trading
    int max_open_positions;           // Maximum concurrent positions
};

struct ComplianceMetrics
{
    double current_daily_dd;
    double current_overall_dd;
    double current_profit;
    double daily_profit_target;
    double overall_profit_target;
    int trading_days_count;
    int consecutive_trading_days;
    datetime last_trade_time;
    datetime phase_start_time;
    bool is_compliant;
    string violation_reason;
    int violation_count;
    bool weekend_violation;
    bool news_violation;
    bool holding_time_violation;
    bool lot_size_violation;
};

//+------------------------------------------------------------------+
//| Prop Firm Manager Class                                         |
//+------------------------------------------------------------------+
class CPropFirmManager
{
private:
    ENUM_PROP_FIRM m_firmType;
    ENUM_ACCOUNT_PHASE m_currentPhase;
    PropFirmRules m_rules;
    ComplianceMetrics m_metrics;
    
    // Account tracking
    double m_startingBalance;
    double m_dailyStartingBalance;
    double m_phaseStartingBalance;
    datetime m_dailyResetTime;
    datetime m_phaseStartTime;
    
    // Violation tracking
    ViolationRecord m_violations[];
    int m_violationCount;
    bool m_accountSuspended;
    bool m_alertsEnabled;
    
    // Daily tracking variables
    double m_dailyPnL;
    double m_dailyDrawdown;
    double m_overallDrawdown;
    double m_dailyPeakBalance;
    double m_peakBalance;
    int m_tradesToday;
    
    // Trading session tracking
    bool m_isWeekend;
    bool m_isNewsTime;
    datetime m_lastNewsCheck;
    
public:
    CPropFirmManager();
    ~CPropFirmManager();
    
    // Initialization
    bool Initialize(ENUM_PROP_FIRM firmType, double dailyDD, double overallDD, int minHoldingTime);
    void UpdateCompliance();
    
    // Rule validation
    bool ValidateTrade(const TradeRequest& request);
    bool IsTradeAllowed();
    bool IsWeekendTradingAllowed();
    bool IsNewsTradingAllowed();
    
    // Phase management
    void SetAccountPhase(ENUM_ACCOUNT_PHASE phase);
    ENUM_ACCOUNT_PHASE DetectAccountPhase();
    bool CheckPhaseCompletion();
    void TransitionToNextPhase();
    
    // Compliance monitoring
    void MonitorDrawdownLimits();
    void MonitorProfitTargets();
    void MonitorTradingDays();
    void MonitorHoldingTimes(ulong ticket, datetime openTime, datetime closeTime);
    
    // Violation handling
    void RecordViolation(string violationType, string description);
    bool HasRecentViolations(int minutes = 60);
    void ResetViolations();
    
    // Getters
    PropFirmRules GetRules() { return m_rules; }
    ComplianceMetrics GetMetrics() { return m_metrics; }
    ENUM_PROP_FIRM GetFirmType() { return m_firmType; }
    ENUM_ACCOUNT_PHASE GetCurrentPhase() { return m_currentPhase; }
    
    // Utilities
    string GetFirmName();
    string GetPhaseName();
    double GetRemainingDrawdown();
    double GetRequiredProfit();
    int GetRemainingTradingDays();
    bool IsAccountSuspended();
    string GetViolationReport();
    void SetAlertsEnabled(bool enabled);
    void UpdateDailyStats();
    
private:
    // Helper functions
    void InitializeFirmRules();
    void SetFTMORules();
    void SetFundedNextRules();
    void SetGoatFundedRules();
    void SetEquityEdgeRules();
    void SetMyForexFundsRules();
    void SetThe5ersRules();
    void UpdateDailyMetrics();
    void CheckWeekendStatus();
    void CheckNewsStatus();
    bool IsHighImpactNewsTime();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPropFirmManager::CPropFirmManager()
{
    m_firmType = PROP_FIRM_NONE;
    m_currentPhase = PHASE_UNKNOWN;
    
    // Initialize metrics
    ZeroMemory(m_metrics);
    ZeroMemory(m_rules);
    
    m_startingBalance = 0;
    m_dailyStartingBalance = 0;
    m_phaseStartingBalance = 0;
    m_dailyResetTime = 0;
    m_phaseStartTime = 0;
    
    m_isWeekend = false;
    m_isNewsTime = false;
    m_lastNewsCheck = 0;
    
    // Initialize violation tracking
    m_violationCount = 0;
    m_accountSuspended = false;
    m_alertsEnabled = true;
    
    // Initialize daily tracking
    m_dailyPnL = 0.0;
    m_dailyDrawdown = 0.0;
    m_overallDrawdown = 0.0;
    m_dailyPeakBalance = 0.0;
    m_peakBalance = 0.0;
    m_tradesToday = 0;
    
    ArrayResize(m_violations, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPropFirmManager::~CPropFirmManager()
{
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Initialize Prop Firm Manager                                    |
//+------------------------------------------------------------------+
bool CPropFirmManager::Initialize(ENUM_PROP_FIRM firmType, double dailyDD, double overallDD, int minHoldingTime)
{
    m_firmType = firmType;
    
    if(m_firmType == PROP_FIRM_NONE)
    {
        Print("[PropFirmManager] No prop firm selected - compliance monitoring disabled");
        return true;
    }
    
    // Initialize firm-specific rules
    InitializeFirmRules();
    
    // Override with custom settings if provided
    if(dailyDD > 0)
        m_rules.daily_drawdown_limit = dailyDD;
    if(overallDD > 0)
        m_rules.overall_drawdown_limit = overallDD;
    if(minHoldingTime > 0)
        m_rules.min_holding_time = minHoldingTime;
    
    // Set starting balances
    m_startingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_dailyStartingBalance = m_startingBalance;
    m_phaseStartingBalance = m_startingBalance;
    m_phaseStartTime = TimeCurrent();
    
    // Detect current phase
    m_currentPhase = DetectAccountPhase();
    
    // Initialize daily reset time (typically 5 PM EST)
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    dt.hour = 22; // 5 PM EST = 22:00 GMT
    dt.min = 0;
    dt.sec = 0;
    m_dailyResetTime = StructToTime(dt);
    
    Print("[PropFirmManager] Initialized for " + GetFirmName() + 
          " - Phase: " + GetPhaseName() + 
          ", Daily DD Limit: " + DoubleToString(m_rules.daily_drawdown_limit, 1) + "%" +
          ", Overall DD Limit: " + DoubleToString(m_rules.overall_drawdown_limit, 1) + "%");
    
    return true;
}

//+------------------------------------------------------------------+
//| Update compliance monitoring                                    |
//+------------------------------------------------------------------+
void CPropFirmManager::UpdateCompliance()
{
    if(m_firmType == PROP_FIRM_NONE)
        return;
    
    // Update daily metrics if new day
    UpdateDailyMetrics();
    
    // Check weekend status
    CheckWeekendStatus();
    
    // Check news status
    CheckNewsStatus();
    
    // Monitor compliance
    MonitorDrawdownLimits();
    MonitorProfitTargets();
    MonitorTradingDays();
    
    // Check phase completion
    if(CheckPhaseCompletion())
    {
        TransitionToNextPhase();
    }
    
    // Update overall compliance status
    m_metrics.is_compliant = (m_metrics.violation_count == 0) && 
                            (m_metrics.current_daily_dd < m_rules.daily_drawdown_limit) &&
                            (m_metrics.current_overall_dd < m_rules.overall_drawdown_limit);
}

//+------------------------------------------------------------------+
//| Validate trade against prop firm rules                         |
//+------------------------------------------------------------------+
bool CPropFirmManager::ValidateTrade(const TradeRequest& request)
{
    if(m_firmType == PROP_FIRM_NONE)
        return true;
    
    // Check if trading is allowed
    if(!IsTradeAllowed())
    {
        return false;
    }
    
    // Check lot size limits
    if(request.volume > m_rules.max_lot_size)
    {
        RecordViolation("LotSizeViolation", 
                       "Trade volume (" + DoubleToString(request.volume, 2) + 
                       ") exceeds maximum (" + DoubleToString(m_rules.max_lot_size, 2) + ")");
        return false;
    }
    
    // Check weekend trading
    if(m_isWeekend && !m_rules.weekend_trading_allowed)
    {
        RecordViolation("WeekendTradingViolation", "Weekend trading not allowed");
        return false;
    }
    
    // Check news trading
    if(m_isNewsTime && !m_rules.news_trading_allowed)
    {
        RecordViolation("NewsTradingViolation", "News trading not allowed");
        return false;
    }
    
    // Check maximum open positions
    if(PositionsTotal() >= m_rules.max_open_positions)
    {
        RecordViolation("MaxPositionsViolation", 
                       "Maximum open positions (" + IntegerToString(m_rules.max_open_positions) + ") reached");
        return false;
    }
    
    // Check if trade would exceed daily loss limit
    double potentialLoss = MathAbs(request.price - request.stop_loss) * request.volume;
    if(potentialLoss > m_rules.max_daily_loss)
    {
        RecordViolation("DailyLossViolation", 
                       "Potential loss exceeds daily limit");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                     |
//+------------------------------------------------------------------+
bool CPropFirmManager::IsTradeAllowed()
{
    if(m_firmType == PROP_FIRM_NONE)
        return true;
    
    // Check compliance status
    if(!m_metrics.is_compliant)
    {
        Print("[PropFirmManager] Trading blocked: Account not compliant - " + m_metrics.violation_reason);
        return false;
    }
    
    // Check drawdown limits
    if(m_metrics.current_daily_dd >= m_rules.daily_drawdown_limit)
    {
        Print("[PropFirmManager] Trading blocked: Daily drawdown limit reached");
        return false;
    }
    
    if(m_metrics.current_overall_dd >= m_rules.overall_drawdown_limit)
    {
        Print("[PropFirmManager] Trading blocked: Overall drawdown limit reached");
        return false;
    }
    
    // Check weekend trading
    if(m_isWeekend && !m_rules.weekend_trading_allowed)
    {
        Print("[PropFirmManager] Trading blocked: Weekend trading not allowed");
        return false;
    }
    
    // Check news trading
    if(m_isNewsTime && !m_rules.news_trading_allowed)
    {
        Print("[PropFirmManager] Trading blocked: News trading not allowed");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize firm-specific rules                                  |
//+------------------------------------------------------------------+
void CPropFirmManager::InitializeFirmRules()
{
    switch(m_firmType)
    {
        case PROP_FIRM_FTMO:
            SetFTMORules();
            break;
        case PROP_FIRM_FUNDEDNEXT:
            SetFundedNextRules();
            break;
        case PROP_FIRM_GOATFUNDED:
            SetGoatFundedRules();
            break;
        case PROP_FIRM_EQUITYEDGE:
            SetEquityEdgeRules();
            break;
        case PROP_FIRM_MYFOREXFUNDS:
            SetMyForexFundsRules();
            break;
        case PROP_FIRM_THE5ERS:
            SetThe5ersRules();
            break;
        default:
            // Default conservative rules
            m_rules.daily_drawdown_limit = 5.0;
            m_rules.overall_drawdown_limit = 10.0;
            m_rules.profit_target_phase1 = 8.0;
            m_rules.profit_target_phase2 = 5.0;
            m_rules.min_trading_days = 4;
            m_rules.max_trading_days = 30;
            m_rules.weekend_trading_allowed = false;
            m_rules.news_trading_allowed = true;
            m_rules.min_holding_time = 60;
            m_rules.max_holding_time = 0;
            m_rules.max_lot_size = 2.0;
            m_rules.max_daily_loss = 1000.0;
            m_rules.requires_consistency = true;
            m_rules.allows_ea_trading = true;
            m_rules.allows_copy_trading = false;
            m_rules.max_open_positions = 3;
            break;
    }
}

//+------------------------------------------------------------------+
//| Set FTMO specific rules                                         |
//+------------------------------------------------------------------+
void CPropFirmManager::SetFTMORules()
{
    m_rules.firm_name = "FTMO";
    m_rules.daily_drawdown_limit = 5.0;
    m_rules.overall_drawdown_limit = 10.0;
    m_rules.profit_target_phase1 = 8.0;
    m_rules.profit_target_phase2 = 5.0;
    m_rules.min_trading_days = 4;
    m_rules.max_trading_days = 30;
    m_rules.weekend_trading_allowed = false;
    m_rules.news_trading_allowed = true;
    m_rules.min_holding_time = 60; // 1 minute minimum
    m_rules.max_holding_time = 0;  // No maximum
    m_rules.max_lot_size = 2.0;
    m_rules.max_daily_loss = 0; // Calculated based on account size
    m_rules.requires_consistency = true;
    m_rules.allows_ea_trading = true;
    m_rules.allows_copy_trading = false;
    m_rules.max_open_positions = 10;
}

//+------------------------------------------------------------------+
//| Set FundedNext specific rules                                   |
//+------------------------------------------------------------------+
void CPropFirmManager::SetFundedNextRules()
{
    m_rules.firm_name = "FundedNext";
    m_rules.daily_drawdown_limit = 5.0;
    m_rules.overall_drawdown_limit = 12.0;
    m_rules.profit_target_phase1 = 8.0;
    m_rules.profit_target_phase2 = 5.0;
    m_rules.min_trading_days = 5;
    m_rules.max_trading_days = 30;
    m_rules.weekend_trading_allowed = false;
    m_rules.news_trading_allowed = true;
    m_rules.min_holding_time = 60;
    m_rules.max_holding_time = 0;
    m_rules.max_lot_size = 1.0; // More conservative
    m_rules.max_daily_loss = 0;
    m_rules.requires_consistency = true;
    m_rules.allows_ea_trading = true;
    m_rules.allows_copy_trading = true;
    m_rules.max_open_positions = 5;
}

//+------------------------------------------------------------------+
//| Set GoatFunded specific rules                                   |
//+------------------------------------------------------------------+
void CPropFirmManager::SetGoatFundedRules()
{
    m_rules.firm_name = "GoatFunded";
    m_rules.daily_drawdown_limit = 5.0;
    m_rules.overall_drawdown_limit = 10.0;
    m_rules.profit_target_phase1 = 8.0;
    m_rules.profit_target_phase2 = 5.0;
    m_rules.min_trading_days = 4;
    m_rules.max_trading_days = 30;
    m_rules.weekend_trading_allowed = false;
    m_rules.news_trading_allowed = true;
    m_rules.min_holding_time = 60;
    m_rules.max_holding_time = 0;
    m_rules.max_lot_size = 1.5;
    m_rules.max_daily_loss = 0;
    m_rules.requires_consistency = true;
    m_rules.allows_ea_trading = true;
    m_rules.allows_copy_trading = false;
    m_rules.max_open_positions = 8;
}

//+------------------------------------------------------------------+
//| Set EquityEdge specific rules                                   |
//+------------------------------------------------------------------+
void CPropFirmManager::SetEquityEdgeRules()
{
    m_rules.firm_name = "EquityEdge";
    m_rules.daily_drawdown_limit = 4.0;
    m_rules.overall_drawdown_limit = 8.0;
    m_rules.profit_target_phase1 = 10.0;
    m_rules.profit_target_phase2 = 5.0;
    m_rules.min_trading_days = 5;
    m_rules.max_trading_days = 30;
    m_rules.weekend_trading_allowed = false;
    m_rules.news_trading_allowed = false;
    m_rules.min_holding_time = 120;
    m_rules.max_holding_time = 0;
    m_rules.max_lot_size = 1.0;
    m_rules.max_daily_loss = 0;
    m_rules.requires_consistency = true;
    m_rules.allows_ea_trading = true;
    m_rules.allows_copy_trading = false;
    m_rules.max_open_positions = 5;
}

//+------------------------------------------------------------------+
//| Set MyForexFunds specific rules                                 |
//+------------------------------------------------------------------+
void CPropFirmManager::SetMyForexFundsRules()
{
    m_rules.firm_name = "MyForexFunds";
    m_rules.daily_drawdown_limit = 5.0;
    m_rules.overall_drawdown_limit = 12.0;
    m_rules.profit_target_phase1 = 8.0;
    m_rules.profit_target_phase2 = 5.0;
    m_rules.min_trading_days = 4;
    m_rules.max_trading_days = 30;
    m_rules.weekend_trading_allowed = true;
    m_rules.news_trading_allowed = true;
    m_rules.min_holding_time = 60;
    m_rules.max_holding_time = 0;
    m_rules.max_lot_size = 2.0;
    m_rules.max_daily_loss = 0;
    m_rules.requires_consistency = false;
    m_rules.allows_ea_trading = true;
    m_rules.allows_copy_trading = true;
    m_rules.max_open_positions = 10;
}

//+------------------------------------------------------------------+
//| Set The5%ers specific rules                                     |
//+------------------------------------------------------------------+
void CPropFirmManager::SetThe5ersRules()
{
    m_rules.firm_name = "The5%ers";
    m_rules.daily_drawdown_limit = 5.0;
    m_rules.overall_drawdown_limit = 10.0;
    m_rules.profit_target_phase1 = 8.0;
    m_rules.profit_target_phase2 = 5.0;
    m_rules.min_trading_days = 4;
    m_rules.max_trading_days = 30;
    m_rules.weekend_trading_allowed = false;
    m_rules.news_trading_allowed = true;
    m_rules.min_holding_time = 60;
    m_rules.max_holding_time = 0;
    m_rules.max_lot_size = 1.0;
    m_rules.max_daily_loss = 0;
    m_rules.requires_consistency = true;
    m_rules.allows_ea_trading = true;
    m_rules.allows_copy_trading = false;
    m_rules.max_open_positions = 6;
}

//+------------------------------------------------------------------+
//| Monitor drawdown limits                                         |
//+------------------------------------------------------------------+
void CPropFirmManager::MonitorDrawdownLimits()
{
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Calculate daily drawdown
    if(m_dailyStartingBalance > 0)
    {
        m_metrics.current_daily_dd = ((m_dailyStartingBalance - currentEquity) / m_dailyStartingBalance) * 100.0;
    }
    
    // Calculate overall drawdown
    if(m_phaseStartingBalance > 0)
    {
        m_metrics.current_overall_dd = ((m_phaseStartingBalance - currentEquity) / m_phaseStartingBalance) * 100.0;
    }
    
    // Check for violations
    if(m_metrics.current_daily_dd >= m_rules.daily_drawdown_limit)
    {
        RecordViolation("DailyDrawdownViolation", 
                       "Daily drawdown (" + DoubleToString(m_metrics.current_daily_dd, 2) + 
                       "%) exceeds limit (" + DoubleToString(m_rules.daily_drawdown_limit, 2) + "%)");
    }
    
    if(m_metrics.current_overall_dd >= m_rules.overall_drawdown_limit)
    {
        RecordViolation("OverallDrawdownViolation", 
                       "Overall drawdown (" + DoubleToString(m_metrics.current_overall_dd, 2) + 
                       "%) exceeds limit (" + DoubleToString(m_rules.overall_drawdown_limit, 2) + "%)");
    }
}

//+------------------------------------------------------------------+
//| Get phase name as string                                        |
//+------------------------------------------------------------------+
string CPropFirmManager::GetPhaseName()
{
    switch(m_currentPhase)
    {
        case PHASE_CHALLENGE_1: return "Challenge Phase 1";
        case PHASE_CHALLENGE_2: return "Challenge Phase 2";
        case PHASE_VERIFICATION: return "Verification";
        case PHASE_LIVE_FUNDED: return "Live Funded";
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| Detect account phase                                            |
//+------------------------------------------------------------------+
ENUM_ACCOUNT_PHASE CPropFirmManager::DetectAccountPhase()
{
    // Simple detection based on account balance and profit
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double profit = currentBalance - m_startingBalance;
    double profitPercent = (profit / m_startingBalance) * 100.0;
    
    // This is a simplified detection - in reality, you'd need more sophisticated logic
    if(profitPercent >= m_rules.profit_target_phase1)
        return PHASE_CHALLENGE_2;
    else if(profitPercent >= m_rules.profit_target_phase2)
        return PHASE_VERIFICATION;
    else
        return PHASE_CHALLENGE_1;
}

//+------------------------------------------------------------------+
//| Check phase completion                                          |
//+------------------------------------------------------------------+
bool CPropFirmManager::CheckPhaseCompletion()
{
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double profit = currentBalance - m_phaseStartingBalance;
    double profitPercent = (profit / m_phaseStartingBalance) * 100.0;
    
    switch(m_currentPhase)
    {
        case PHASE_CHALLENGE_1:
            return profitPercent >= m_rules.profit_target_phase1;
        case PHASE_CHALLENGE_2:
            return profitPercent >= m_rules.profit_target_phase2;
        case PHASE_VERIFICATION:
            return true; // Verification phase completion logic
        default:
            return false;
    }
}

//+------------------------------------------------------------------+
//| Transition to next phase                                        |
//+------------------------------------------------------------------+
void CPropFirmManager::TransitionToNextPhase()
{
    switch(m_currentPhase)
    {
        case PHASE_CHALLENGE_1:
            m_currentPhase = PHASE_CHALLENGE_2;
            break;
        case PHASE_CHALLENGE_2:
            m_currentPhase = PHASE_VERIFICATION;
            break;
        case PHASE_VERIFICATION:
            m_currentPhase = PHASE_LIVE_FUNDED;
            break;
        default:
            break;
    }
    
    // Reset phase metrics
    m_phaseStartingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_phaseStartTime = TimeCurrent();
    
    Print("[PropFirmManager] Transitioned to " + GetPhaseName());
}

//+------------------------------------------------------------------+
//| Monitor profit targets                                          |
//+------------------------------------------------------------------+
void CPropFirmManager::MonitorProfitTargets()
{
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double profit = currentBalance - m_phaseStartingBalance;
    double profitPercent = (profit / m_phaseStartingBalance) * 100.0;
    
    m_metrics.current_profit = profitPercent;
    
    switch(m_currentPhase)
    {
        case PHASE_CHALLENGE_1:
            m_metrics.overall_profit_target = m_rules.profit_target_phase1;
            break;
        case PHASE_CHALLENGE_2:
            m_metrics.overall_profit_target = m_rules.profit_target_phase2;
            break;
        default:
            m_metrics.overall_profit_target = 0;
            break;
    }
}

//+------------------------------------------------------------------+
//| Monitor trading days                                            |
//+------------------------------------------------------------------+
void CPropFirmManager::MonitorTradingDays()
{
    // Calculate trading days since phase start
    int daysSinceStart = (int)((TimeCurrent() - m_phaseStartTime) / 86400);
    m_metrics.trading_days_count = daysSinceStart;
    
    // Check minimum trading days requirement
    if(m_currentPhase != PHASE_LIVE_FUNDED && daysSinceStart < m_rules.min_trading_days)
    {
        // Still need more trading days
    }
    
    // Check maximum trading days limit
    if(daysSinceStart > m_rules.max_trading_days)
    {
        RecordViolation("MaxTradingDaysViolation", 
                       "Maximum trading days (" + IntegerToString(m_rules.max_trading_days) + ") exceeded");
    }
}

//+------------------------------------------------------------------+
//| Monitor holding times                                           |
//+------------------------------------------------------------------+
void CPropFirmManager::MonitorHoldingTimes(ulong ticket, datetime openTime, datetime closeTime)
{
    int holdingTimeSeconds = (int)(closeTime - openTime);
    
    if(holdingTimeSeconds < m_rules.min_holding_time)
    {
        RecordViolation("MinHoldingTimeViolation", 
                       "Trade held for " + IntegerToString(holdingTimeSeconds) + 
                       " seconds, minimum is " + IntegerToString(m_rules.min_holding_time));
    }
    
    if(m_rules.max_holding_time > 0 && holdingTimeSeconds > m_rules.max_holding_time)
    {
        RecordViolation("MaxHoldingTimeViolation", 
                       "Trade held for " + IntegerToString(holdingTimeSeconds) + 
                       " seconds, maximum is " + IntegerToString(m_rules.max_holding_time));
    }
}

//+------------------------------------------------------------------+
//| Check weekend trading status                                    |
//+------------------------------------------------------------------+
void CPropFirmManager::CheckWeekendStatus()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Weekend is Saturday (6) and Sunday (0)
    m_isWeekend = (dt.day_of_week == 0 || dt.day_of_week == 6);
}

//+------------------------------------------------------------------+
//| Check news trading status                                       |
//+------------------------------------------------------------------+
void CPropFirmManager::CheckNewsStatus()
{
    // Simple news detection - in practice, you'd integrate with news calendar
    // For now, assume news time during certain hours
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Assume high-impact news during 8:30-9:30 EST (13:30-14:30 GMT)
    m_isNewsTime = (dt.hour >= 13 && dt.hour <= 14);
}

//+------------------------------------------------------------------+
//| Check if weekend trading is allowed                            |
//+------------------------------------------------------------------+
bool CPropFirmManager::IsWeekendTradingAllowed()
{
    return m_rules.weekend_trading_allowed;
}

//+------------------------------------------------------------------+
//| Check if news trading is allowed                               |
//+------------------------------------------------------------------+
bool CPropFirmManager::IsNewsTradingAllowed()
{
    return m_rules.news_trading_allowed;
}

//+------------------------------------------------------------------+
//| Set account phase                                               |
//+------------------------------------------------------------------+
void CPropFirmManager::SetAccountPhase(ENUM_ACCOUNT_PHASE phase)
{
    m_currentPhase = phase;
    m_phaseStartingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_phaseStartTime = TimeCurrent();
    
    Print("[PropFirmManager] Account phase set to: " + GetPhaseName());
}

//+------------------------------------------------------------------+
//| Get remaining drawdown                                          |
//+------------------------------------------------------------------+
double CPropFirmManager::GetRemainingDrawdown()
{
    return m_rules.daily_drawdown_limit - m_metrics.current_daily_dd;
}

//+------------------------------------------------------------------+
//| Get required profit                                             |
//+------------------------------------------------------------------+
double CPropFirmManager::GetRequiredProfit()
{
    return m_metrics.overall_profit_target - m_metrics.current_profit;
}

//+------------------------------------------------------------------+
//| Get remaining trading days                                      |
//+------------------------------------------------------------------+
int CPropFirmManager::GetRemainingTradingDays()
{
    return m_rules.max_trading_days - m_metrics.trading_days_count;
}

//+------------------------------------------------------------------+
//| Update daily metrics                                            |
//+------------------------------------------------------------------+
void CPropFirmManager::UpdateDailyMetrics()
{
    // Check if it's a new day
    static datetime lastUpdateDay = 0;
    datetime currentDay = (TimeCurrent() / 86400) * 86400; // Start of current day
    
    if(lastUpdateDay != currentDay)
    {
        // New day - reset daily metrics
        m_dailyStartingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_dailyPeakBalance = m_dailyStartingBalance;
        lastUpdateDay = currentDay;
        
        Print("[PropFirmManager] New trading day - Daily balance reset to: " + 
              DoubleToString(m_dailyStartingBalance, 2));
    }
    
    UpdateDailyStats();
}

//+------------------------------------------------------------------+
//| Get firm name as string                                         |
//+------------------------------------------------------------------+
string CPropFirmManager::GetFirmName()
{
    switch(m_firmType)
    {
        case PROP_FIRM_FTMO: return "FTMO";
        case PROP_FIRM_FUNDEDNEXT: return "FundedNext";
        case PROP_FIRM_GOATFUNDED: return "GoatFunded";
        case PROP_FIRM_EQUITYEDGE: return "EquityEdge";
        case PROP_FIRM_MYFOREXFUNDS: return "MyForexFunds";
        case PROP_FIRM_THE5ERS: return "The5%ers";
        case PROP_FIRM_TOPSTEPTRADER: return "TopstepTrader";
        case PROP_FIRM_SURGETRADER: return "SurgeTrader";
        case PROP_FIRM_BLUEGUARDIAN: return "BlueGuardian";
        default: return "None";
    }
}

//--- Additional prop firm management methods continue...
//+------------------------------------------------------------------+
//| Record violation                                                |
//+------------------------------------------------------------------+
void CPropFirmManager::RecordViolation(string violationType, string description)
{
    // Add to violations array
    int size = ArraySize(m_violations);
    ArrayResize(m_violations, size + 1);
    
    m_violations[size].type = violationType;
    m_violations[size].description = description;
    m_violations[size].timestamp = TimeCurrent();
    m_violations[size].severity = VIOLATION_WARNING; // Default severity
    
    // Log the violation
    Print("[PropFirmManager] VIOLATION: " + violationType + " - " + description);
    
    // Send alert if enabled
    if(m_alertsEnabled)
    {
        Alert("PropFirm Violation: " + violationType + " - " + description);
    }
    
    // Update violation count
    m_violationCount++;
    
    // Check if account should be suspended
    if(m_violationCount >= 5) // Suspend after 5 violations
    {
        m_accountSuspended = true;
        Print("[PropFirmManager] ACCOUNT SUSPENDED due to multiple violations");
        Alert("ACCOUNT SUSPENDED: Multiple prop firm rule violations detected");
    }
}

//+------------------------------------------------------------------+
//| Check for recent violations                                     |
//+------------------------------------------------------------------+
bool CPropFirmManager::HasRecentViolations(int minutes = 60)
{
    datetime cutoffTime = TimeCurrent() - (minutes * 60);
    
    int recent_i;
    for(recent_i = 0; recent_i < ArraySize(m_violations); recent_i++)
    {
        if(m_violations[recent_i].timestamp > cutoffTime)
        {
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Reset violations                                                |
//+------------------------------------------------------------------+
void CPropFirmManager::ResetViolations()
{
    ArrayResize(m_violations, 0);
    m_violationCount = 0;
    m_accountSuspended = false;
    
    Print("[PropFirmManager] Violations reset");
}

//+------------------------------------------------------------------+
//| Update daily statistics                                         |
//+------------------------------------------------------------------+
void CPropFirmManager::UpdateDailyStats()
{
    // Update daily P&L
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_dailyPnL = currentEquity - m_dailyStartingBalance;
    
    // Update daily drawdown
    if(currentEquity < m_dailyPeakBalance)
    {
        m_dailyDrawdown = (m_dailyPeakBalance - currentEquity) / m_dailyStartingBalance * 100.0;
    }
    else
    {
        m_dailyPeakBalance = currentEquity;
        m_dailyDrawdown = 0.0;
    }
    
    // Update overall drawdown
    if(currentEquity < m_peakBalance)
    {
        m_overallDrawdown = (m_peakBalance - currentEquity) / m_startingBalance * 100.0;
    }
    else
    {
        m_peakBalance = currentEquity;
        m_overallDrawdown = 0.0;
    }
    
    // Check for new trading day
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    static int lastDay = -1;
    
    if(lastDay != -1 && dt.day != lastDay)
    {
        // New day started - reset daily metrics
        m_dailyStartingBalance = currentEquity;
        m_dailyPeakBalance = currentEquity;
        m_dailyPnL = 0.0;
        m_dailyDrawdown = 0.0;
        m_tradesToday = 0;
        
        Print("[PropFirmManager] New trading day - Daily metrics reset");
    }
    lastDay = dt.day;
}

//+------------------------------------------------------------------+
//| Check if account is suspended                                   |
//+------------------------------------------------------------------+
bool CPropFirmManager::IsAccountSuspended()
{
    return m_accountSuspended;
}

//+------------------------------------------------------------------+
//| Get violation report                                            |
//+------------------------------------------------------------------+
string CPropFirmManager::GetViolationReport()
{
    string report = "=== PROP FIRM VIOLATION REPORT ===\n";
    report += "Firm: " + GetFirmName() + "\n";
    report += "Phase: " + EnumToString(m_currentPhase) + "\n";
    report += "Total Violations: " + IntegerToString(m_violationCount) + "\n";
    report += "Account Status: " + (m_accountSuspended ? "SUSPENDED" : "ACTIVE") + "\n\n";
    
    if(ArraySize(m_violations) > 0)
    {
        report += "RECENT VIOLATIONS:\n";
        int viol_i;
        for(viol_i = 0; viol_i < ArraySize(m_violations); viol_i++)
        {
            report += TimeToString(m_violations[viol_i].timestamp) + " - ";
            report += m_violations[viol_i].type + ": ";
            report += m_violations[viol_i].description + "\n";
        }
    }
    else
    {
        report += "No violations recorded.\n";
    }
    
    return report;
}

//+------------------------------------------------------------------+
//| Enable/disable alerts                                           |
//+------------------------------------------------------------------+
void CPropFirmManager::SetAlertsEnabled(bool enabled)
{
    m_alertsEnabled = enabled;
    Print("[PropFirmManager] Alerts " + (enabled ? "enabled" : "disabled"));
}