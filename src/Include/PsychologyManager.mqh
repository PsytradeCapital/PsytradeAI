//+------------------------------------------------------------------+
//|                                              PsychologyManager.mqh |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_PSYCHOLOGICAL_STATE
{
    PSYCH_STATE_NEUTRAL,        // Normal trading state
    PSYCH_STATE_COOLING_OFF,    // After loss, waiting period
    PSYCH_STATE_REDUCED_SIZE,   // After consecutive losses
    PSYCH_STATE_EMERGENCY_STOP, // Emergency psychological stop
    PSYCH_STATE_CONFIDENT,      // After wins, but controlled
    PSYCH_STATE_OVERCONFIDENT   // Dangerous state, needs control
};

enum ENUM_TRADE_OUTCOME
{
    TRADE_WIN,
    TRADE_LOSS,
    TRADE_BREAKEVEN
};

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct PsychologicalMetrics
{
    int consecutive_losses;
    int consecutive_wins;
    int total_trades_today;
    double win_rate_last_10;
    double win_rate_last_50;
    datetime last_trade_time;
    datetime last_loss_time;
    ENUM_PSYCHOLOGICAL_STATE current_state;
    bool revenge_trading_risk;
    bool overconfidence_risk;
    double emotional_stability_score; // 0-1, higher is better
};

struct TradingRule
{
    string rule_name;
    string description;
    bool is_active;
    int violation_count;
    datetime last_violation;
};

//+------------------------------------------------------------------+
//| Psychology Manager Class - Implements Mark Douglas Principles   |
//+------------------------------------------------------------------+
class CPsychologyManager
{
private:
    // Core psychological parameters
    int m_coolingOffPeriod;      // Minutes to wait after loss
    int m_maxConsecutiveLosses;  // Before reducing position size
    double m_confidenceThreshold; // Minimum confidence for trades
    
    // Psychological state tracking
    PsychologicalMetrics m_metrics;
    TradingRule m_rules[];
    
    // Trade history for analysis
    ENUM_TRADE_OUTCOME m_recentTrades[50];
    datetime m_tradeTimestamps[50];
    int m_tradeHistoryIndex;
    
    // Mark Douglas principles implementation
    bool m_probabilisticThinking;
    bool m_emotionalDetachment;
    bool m_acceptanceOfUncertainty;
    bool m_disciplinedExecution;
    
    // Internal state
    datetime m_lastStateUpdate;
    string m_currentReminder;
    
public:
    CPsychologyManager();
    ~CPsychologyManager();
    
    // Initialization and configuration
    bool Initialize(int coolingOffPeriod, int maxConsecutiveLosses, double confidenceThreshold);
    void UpdateState();
    
    // Core psychological functions
    bool IsTradeAllowed();
    bool ShouldReducePositionSize();
    double GetPositionSizeMultiplier();
    string GetCurrentPsychologicalReminder();
    
    // Trade outcome processing
    void ProcessTradeOutcome(ENUM_TRADE_OUTCOME outcome, double profit, double loss);
    void RecordTradeAttempt();
    
    // Mark Douglas principles
    bool EnforceProbabilisticThinking(double setupProbability);
    bool AcceptUncertainty(double marketUncertainty);
    bool MaintainEmotionalDetachment();
    bool EnforceDisciplinedExecution();
    
    // Risk management integration
    bool PreventRevengeTradng();
    bool ControlOverconfidence();
    void TriggerEmergencyStop();
    
    // State management
    ENUM_PSYCHOLOGICAL_STATE GetCurrentState();
    void SetState(ENUM_PSYCHOLOGICAL_STATE newState);
    double CalculateEmotionalStability();
    
    // Rule management
    void InitializeTradingRules();
    bool CheckRuleCompliance(string ruleName);
    void LogRuleViolation(string ruleName);
    
    // Metrics and reporting
    PsychologicalMetrics GetMetrics();
    void ResetDailyMetrics();
    double CalculateWinRate(int tradesToAnalyze);
    
private:
    // Internal helper functions
    void UpdateConsecutiveStats();
    void CheckForPsychologicalRisks();
    void GeneratePsychologicalReminder();
    bool IsInCoolingOffPeriod();
    void ApplyMarkDouglasRules();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPsychologyManager::CPsychologyManager()
{
    m_coolingOffPeriod = 30;
    m_maxConsecutiveLosses = 3;
    m_confidenceThreshold = 0.7;
    
    // Initialize metrics
    m_metrics.consecutive_losses = 0;
    m_metrics.consecutive_wins = 0;
    m_metrics.total_trades_today = 0;
    m_metrics.win_rate_last_10 = 0.0;
    m_metrics.win_rate_last_50 = 0.0;
    m_metrics.last_trade_time = 0;
    m_metrics.last_loss_time = 0;
    m_metrics.current_state = PSYCH_STATE_NEUTRAL;
    m_metrics.revenge_trading_risk = false;
    m_metrics.overconfidence_risk = false;
    m_metrics.emotional_stability_score = 1.0;
    
    // Initialize Mark Douglas principles
    m_probabilisticThinking = true;
    m_emotionalDetachment = true;
    m_acceptanceOfUncertainty = true;
    m_disciplinedExecution = true;
    
    // Initialize trade history
    ArrayInitialize(m_recentTrades, TRADE_BREAKEVEN);
    ArrayInitialize(m_tradeTimestamps, 0);
    m_tradeHistoryIndex = 0;
    
    m_lastStateUpdate = 0;
    m_currentReminder = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPsychologyManager::~CPsychologyManager()
{
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Initialize Psychology Manager                                    |
//+------------------------------------------------------------------+
bool CPsychologyManager::Initialize(int coolingOffPeriod, int maxConsecutiveLosses, double confidenceThreshold)
{
    m_coolingOffPeriod = coolingOffPeriod;
    m_maxConsecutiveLosses = maxConsecutiveLosses;
    m_confidenceThreshold = confidenceThreshold;
    
    // Initialize trading rules based on Mark Douglas principles
    InitializeTradingRules();
    
    Print("[PsychologyManager] Initialized with cooling off: " + IntegerToString(m_coolingOffPeriod) + 
          " min, max losses: " + IntegerToString(m_maxConsecutiveLosses) + 
          ", confidence threshold: " + DoubleToString(m_confidenceThreshold, 2));
    
    // Generate initial psychological reminder
    GeneratePsychologicalReminder();
    
    return true;
}

//+------------------------------------------------------------------+
//| Update psychological state                                       |
//+------------------------------------------------------------------+
void CPsychologyManager::UpdateState()
{
    datetime currentTime = TimeCurrent();
    
    // Update only once per minute to avoid excessive processing
    if(currentTime - m_lastStateUpdate < 60)
        return;
    
    m_lastStateUpdate = currentTime;
    
    // Update consecutive statistics
    UpdateConsecutiveStats();
    
    // Check for psychological risks
    CheckForPsychologicalRisks();
    
    // Apply Mark Douglas rules
    ApplyMarkDouglasRules();
    
    // Calculate emotional stability
    m_metrics.emotional_stability_score = CalculateEmotionalStability();
    
    // Generate new psychological reminder if needed
    GeneratePsychologicalReminder();
    
    // Reset daily metrics if new day
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);
    static int lastDay = -1;
    
    if(lastDay != -1 && dt.day != lastDay)
    {
        ResetDailyMetrics();
    }
    lastDay = dt.day;
}

//+------------------------------------------------------------------+
//| Check if trading is psychologically allowed                     |
//+------------------------------------------------------------------+
bool CPsychologyManager::IsTradeAllowed()
{
    // Check if in cooling off period
    if(IsInCoolingOffPeriod())
    {
        Print("[PsychologyManager] Trade blocked: In cooling off period after loss");
        return false;
    }
    
    // Check if in emergency stop state
    if(m_metrics.current_state == PSYCH_STATE_EMERGENCY_STOP)
    {
        Print("[PsychologyManager] Trade blocked: Emergency psychological stop active");
        return false;
    }
    
    // Check for revenge trading risk
    if(m_metrics.revenge_trading_risk && !PreventRevengeTradng())
    {
        Print("[PsychologyManager] Trade blocked: Revenge trading risk detected");
        return false;
    }
    
    // Check for overconfidence risk
    if(m_metrics.overconfidence_risk && !ControlOverconfidence())
    {
        Print("[PsychologyManager] Trade blocked: Overconfidence risk detected");
        return false;
    }
    
    // Check emotional stability
    if(m_metrics.emotional_stability_score < 0.5)
    {
        Print("[PsychologyManager] Trade blocked: Low emotional stability (" + 
              DoubleToString(m_metrics.emotional_stability_score, 2) + ")");
        return false;
    }
    
    // Check rule compliance
    if(!CheckRuleCompliance("ProbabilisticThinking") || 
       !CheckRuleCompliance("EmotionalDetachment") ||
       !CheckRuleCompliance("DisciplinedExecution"))
    {
        Print("[PsychologyManager] Trade blocked: Rule compliance failure");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Process trade outcome for psychological analysis                |
//+------------------------------------------------------------------+
void CPsychologyManager::ProcessTradeOutcome(ENUM_TRADE_OUTCOME outcome, double profit, double loss)
{
    // Record trade in history
    m_recentTrades[m_tradeHistoryIndex] = outcome;
    m_tradeTimestamps[m_tradeHistoryIndex] = TimeCurrent();
    m_tradeHistoryIndex = (m_tradeHistoryIndex + 1) % 50;
    
    m_metrics.last_trade_time = TimeCurrent();
    m_metrics.total_trades_today++;
    
    // Update consecutive statistics
    if(outcome == TRADE_WIN)
    {
        m_metrics.consecutive_wins++;
        m_metrics.consecutive_losses = 0;
        
        // Check for overconfidence risk
        if(m_metrics.consecutive_wins >= 5)
        {
            m_metrics.overconfidence_risk = true;
            Print("[PsychologyManager] WARNING: Overconfidence risk after " + 
                  IntegerToString(m_metrics.consecutive_wins) + " consecutive wins");
        }
    }
    else if(outcome == TRADE_LOSS)
    {
        m_metrics.consecutive_losses++;
        m_metrics.consecutive_wins = 0;
        m_metrics.last_loss_time = TimeCurrent();
        
        // Check for revenge trading risk
        if(m_metrics.consecutive_losses >= 2)
        {
            m_metrics.revenge_trading_risk = true;
            Print("[PsychologyManager] WARNING: Revenge trading risk after " + 
                  IntegerToString(m_metrics.consecutive_losses) + " consecutive losses");
        }
        
        // Trigger state change if max losses reached
        if(m_metrics.consecutive_losses >= m_maxConsecutiveLosses)
        {
            SetState(PSYCH_STATE_REDUCED_SIZE);
            Print("[PsychologyManager] State changed to REDUCED_SIZE after " + 
                  IntegerToString(m_metrics.consecutive_losses) + " losses");
        }
    }
    else // TRADE_BREAKEVEN
    {
        m_metrics.consecutive_losses = 0;
        m_metrics.consecutive_wins = 0;
    }
    
    // Update win rates
    m_metrics.win_rate_last_10 = CalculateWinRate(10);
    m_metrics.win_rate_last_50 = CalculateWinRate(50);
    
    // Generate psychological reminder based on outcome
    string reminder = "";
    switch(outcome)
    {
        case TRADE_WIN:
            reminder = "Win accepted with discipline. Each trade remains an independent probabilistic event.";
            break;
        case TRADE_LOSS:
            reminder = "Loss accepted as part of our probabilistic edge. Maintaining emotional detachment.";
            break;
        case TRADE_BREAKEVEN:
            reminder = "Breakeven trade processed. Continuing with systematic approach.";
            break;
    }
    
    Print("[PsychologyManager] " + reminder);
    m_currentReminder = reminder;
}

//+------------------------------------------------------------------+
//| Enforce probabilistic thinking (Mark Douglas principle)        |
//+------------------------------------------------------------------+
bool CPsychologyManager::EnforceProbabilisticThinking(double setupProbability)
{
    if(!m_probabilisticThinking)
        return true;
    
    // Each trade must be viewed as independent event
    if(setupProbability < m_confidenceThreshold)
    {
        Print("[PsychologyManager] Probabilistic thinking: Setup probability (" + 
              DoubleToString(setupProbability, 2) + ") below threshold");
        return false;
    }
    
    // Don't let recent outcomes affect current trade decision
    if(m_metrics.consecutive_losses > 0)
    {
        Print("[PsychologyManager] Probabilistic thinking: Treating this trade as independent despite recent losses");
    }
    
    if(m_metrics.consecutive_wins > 0)
    {
        Print("[PsychologyManager] Probabilistic thinking: Treating this trade as independent despite recent wins");
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Accept uncertainty (Mark Douglas principle)                    |
//+------------------------------------------------------------------+
bool CPsychologyManager::AcceptUncertainty(double marketUncertainty)
{
    if(!m_acceptanceOfUncertainty)
        return true;
    
    // High uncertainty should be accepted, not fought
    if(marketUncertainty > 0.7)
    {
        Print("[PsychologyManager] Accepting high market uncertainty (" + 
              DoubleToString(marketUncertainty, 2) + "). Waiting for clarity.");
        return false; // Don't trade in high uncertainty
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Maintain emotional detachment                                   |
//+------------------------------------------------------------------+
bool CPsychologyManager::MaintainEmotionalDetachment()
{
    if(!m_emotionalDetachment)
        return true;
    
    // Check for emotional triggers
    bool emotionalTrigger = false;
    
    // Recent loss trigger
    if(m_metrics.last_loss_time > 0 && 
       TimeCurrent() - m_metrics.last_loss_time < m_coolingOffPeriod * 60)
    {
        emotionalTrigger = true;
    }
    
    // Consecutive losses trigger
    if(m_metrics.consecutive_losses >= 2)
    {
        emotionalTrigger = true;
    }
    
    // Overconfidence trigger
    if(m_metrics.consecutive_wins >= 4)
    {
        emotionalTrigger = true;
    }
    
    if(emotionalTrigger)
    {
        Print("[PsychologyManager] Emotional detachment: Potential emotional state detected, maintaining discipline");
        // Still allow trading but with heightened awareness
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get position size multiplier based on psychological state      |
//+------------------------------------------------------------------+
double CPsychologyManager::GetPositionSizeMultiplier()
{
    switch(m_metrics.current_state)
    {
        case PSYCH_STATE_REDUCED_SIZE:
            return 0.5; // Reduce position size by 50%
            
        case PSYCH_STATE_EMERGENCY_STOP:
            return 0.0; // No trading
            
        case PSYCH_STATE_OVERCONFIDENT:
            return 0.75; // Slightly reduce size to control overconfidence
            
        case PSYCH_STATE_COOLING_OFF:
            return 0.0; // No trading during cooling off
            
        case PSYCH_STATE_CONFIDENT:
            return 1.0; // Normal size
            
        default: // PSYCH_STATE_NEUTRAL
            return 1.0; // Normal size
    }
}

//+------------------------------------------------------------------+
//| Initialize trading rules based on Mark Douglas principles      |
//+------------------------------------------------------------------+
void CPsychologyManager::InitializeTradingRules()
{
    ArrayResize(m_rules, 5);
    
    // Rule 1: Probabilistic Thinking
    m_rules[0].rule_name = "ProbabilisticThinking";
    m_rules[0].description = "Each trade is an independent probabilistic event";
    m_rules[0].is_active = true;
    m_rules[0].violation_count = 0;
    
    // Rule 2: Emotional Detachment
    m_rules[1].rule_name = "EmotionalDetachment";
    m_rules[1].description = "Maintain emotional detachment from trade outcomes";
    m_rules[1].is_active = true;
    m_rules[1].violation_count = 0;
    
    // Rule 3: Acceptance of Uncertainty
    m_rules[2].rule_name = "AcceptanceOfUncertainty";
    m_rules[2].description = "Accept market uncertainty without forcing trades";
    m_rules[2].is_active = true;
    m_rules[2].violation_count = 0;
    
    // Rule 4: Disciplined Execution
    m_rules[3].rule_name = "DisciplinedExecution";
    m_rules[3].description = "Follow systematic rules regardless of emotions";
    m_rules[3].is_active = true;
    m_rules[3].violation_count = 0;
    
    // Rule 5: No Revenge Trading
    m_rules[4].rule_name = "NoRevengeTradng";
    m_rules[4].description = "Never trade to recover losses immediately";
    m_rules[4].is_active = true;
    m_rules[4].violation_count = 0;
}

//+------------------------------------------------------------------+
//| Generate psychological reminder                                 |
//+------------------------------------------------------------------+
void CPsychologyManager::GeneratePsychologicalReminder()
{
    string reminders[] = {
        "Trading with discipline: Each setup is an independent probabilistic event",
        "Emotional detachment maintained: Outcomes don't define our edge",
        "Accepting uncertainty: The market doesn't owe us anything",
        "Systematic execution: Following rules regardless of recent results",
        "Probabilistic mindset: Our edge comes from consistency over time",
        "Disciplined approach: Process over outcome focus maintained"
    };
    
    int index = MathRand() % ArraySize(reminders);
    m_currentReminder = reminders[index];
}

//--- Additional helper methods implementation continues...