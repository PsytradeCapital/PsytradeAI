//+------------------------------------------------------------------+
//|                                           PerformanceTracker.mqh |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct PerformanceMetrics
{
    // Basic metrics
    int total_trades;
    int winning_trades;
    int losing_trades;
    double win_rate;
    double profit_factor;
    double expectancy;
    
    // Profit/Loss metrics
    double total_profit;
    double total_loss;
    double net_profit;
    double gross_profit;
    double gross_loss;
    double largest_win;
    double largest_loss;
    double average_win;
    double average_loss;
    
    // Drawdown metrics
    double max_drawdown;
    double current_drawdown;
    double max_drawdown_percent;
    double recovery_factor;
    
    // Risk metrics
    double sharpe_ratio;
    double sortino_ratio;
    double calmar_ratio;
    double mar_ratio;
    double sterling_ratio;
    
    // Consistency metrics
    int consecutive_wins;
    int consecutive_losses;
    int max_consecutive_wins;
    int max_consecutive_losses;
    double consistency_score;
    
    // Time-based metrics
    double daily_return;
    double weekly_return;
    double monthly_return;
    double annual_return;
    
    // Advanced metrics
    double value_at_risk;
    double conditional_var;
    double maximum_adverse_excursion;
    double maximum_favorable_excursion;
    
    // Account growth
    double starting_balance;
    double current_balance;
    double peak_balance;
    double growth_rate;
    double compound_annual_growth;
};

struct TradeRecord
{
    datetime open_time;
    datetime close_time;
    string symbol;
    ENUM_ORDER_TYPE order_type;
    double volume;
    double open_price;
    double close_price;
    double stop_loss;
    double take_profit;
    double profit;
    double commission;
    double swap;
    string comment;
    double mae; // Maximum Adverse Excursion
    double mfe; // Maximum Favorable Excursion
    int duration_minutes;
    double risk_reward_ratio;
};

struct DailyStats
{
    datetime date;
    double starting_balance;
    double ending_balance;
    double daily_profit;
    double daily_return;
    int trades_count;
    int winning_trades;
    double max_drawdown;
    double win_rate;
};

//+------------------------------------------------------------------+
//| Performance Tracker Class                                       |
//+------------------------------------------------------------------+
class CPerformanceTracker
{
private:
    PerformanceMetrics m_metrics;
    TradeRecord m_tradeHistory[];
    DailyStats m_dailyStats[];
    
    // Configuration
    bool m_trackMAE_MFE;
    bool m_calculateAdvancedMetrics;
    int m_maxHistoryRecords;
    
    // Real-time tracking
    double m_startingBalance;
    double m_peakBalance;
    double m_currentBalance;
    datetime m_trackingStartTime;
    
    // Risk-free rate for Sharpe ratio calculation
    double m_riskFreeRate;
    
    // Performance calculation helpers
    double m_returns[];
    double m_dailyReturns[];
    double m_monthlyReturns[];
    
public:
    CPerformanceTracker();
    ~CPerformanceTracker();
    
    // Initialization
    bool Initialize();
    void SetConfiguration(bool trackMAE_MFE, bool advancedMetrics, int maxRecords);
    void SetRiskFreeRate(double rate) { m_riskFreeRate = rate; }
    
    // Trade recording
    void RecordTrade(const TradeRecord& trade);
    void RecordTradeFromHistory(ulong ticket);
    void UpdateMAE_MFE(ulong ticket, double currentProfit);
    
    // Metrics calculation
    void CalculateMetrics();
    void UpdateRealTimeMetrics();
    void CalculateBasicMetrics();
    void CalculateRiskMetrics();
    void CalculateDrawdownMetrics();
    void CalculateConsistencyMetrics();
    void CalculateAdvancedMetrics();
    
    // Daily statistics
    void UpdateDailyStats();
    void RecordDailySnapshot();
    DailyStats GetDailyStats(datetime date);
    
    // Getters
    PerformanceMetrics GetMetrics() { return m_metrics; }
    double GetWinRate() { return m_metrics.win_rate; }
    double GetProfitFactor() { return m_metrics.profit_factor; }
    double GetSharpeRatio() { return m_metrics.sharpe_ratio; }
    double GetMaxDrawdown() { return m_metrics.max_drawdown_percent; }
    double GetExpectancy() { return m_metrics.expectancy; }
    
    // Reporting
    string GeneratePerformanceReport();
    string GenerateDailyReport();
    string GenerateMonthlyReport();
    bool ExportToCSV(string filename);
    
    // Analysis
    bool IsPerformanceAcceptable();
    double GetPerformanceScore();
    string GetPerformanceGrade();
    bool ShouldAdjustStrategy();
    
    // Benchmarking
    void SetBenchmark(string benchmarkSymbol);
    double CompareToBenchmark();
    double GetAlpha();
    double GetBeta();
    
private:
    // Helper functions
    void InitializeArrays();
    double CalculateStandardDeviation(const double& values[]);
    double CalculateDownsideDeviation(const double& values[]);
    void UpdateReturnsArrays();
    double GetRiskFreeRateDaily();
    void SortTradesByProfit(TradeRecord& trades[]);
    double CalculateVaR(double confidence);
    double CalculateCVaR(double confidence);
    void CleanupOldRecords();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPerformanceTracker::CPerformanceTracker()
{
    m_trackMAE_MFE = true;
    m_calculateAdvancedMetrics = true;
    m_maxHistoryRecords = 10000;
    m_riskFreeRate = 0.02; // 2% annual risk-free rate
    
    m_startingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_peakBalance = m_startingBalance;
    m_currentBalance = m_startingBalance;
    m_trackingStartTime = TimeCurrent();
    
    // Initialize metrics
    ZeroMemory(m_metrics);
    m_metrics.starting_balance = m_startingBalance;
    m_metrics.current_balance = m_currentBalance;
    
    InitializeArrays();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPerformanceTracker::~CPerformanceTracker()
{
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Initialize Performance Tracker                                  |
//+------------------------------------------------------------------+
bool CPerformanceTracker::Initialize()
{
    Print("[PerformanceTracker] Initialized - Starting balance: " + 
          DoubleToString(m_startingBalance, 2));
    
    // Load existing trade history if available
    LoadTradeHistoryFromAccount();
    
    // Calculate initial metrics
    CalculateMetrics();
    
    return true;
}

//+------------------------------------------------------------------+
//| Record a completed trade                                        |
//+------------------------------------------------------------------+
void CPerformanceTracker::RecordTrade(const TradeRecord& trade)
{
    // Add to trade history
    int size = ArraySize(m_tradeHistory);
    ArrayResize(m_tradeHistory, size + 1);
    m_tradeHistory[size] = trade;
    
    // Update real-time metrics
    UpdateRealTimeMetrics();
    
    // Recalculate performance metrics
    CalculateMetrics();
    
    // Log trade for analysis
    Print("[PerformanceTracker] Trade recorded: " + trade.symbol + 
          " | Profit: " + DoubleToString(trade.profit, 2) + 
          " | R:R: " + DoubleToString(trade.risk_reward_ratio, 2));
    
    // Cleanup old records if necessary
    if(ArraySize(m_tradeHistory) > m_maxHistoryRecords)
    {
        CleanupOldRecords();
    }
}

//+------------------------------------------------------------------+
//| Calculate all performance metrics                               |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateMetrics()
{
    CalculateBasicMetrics();
    CalculateDrawdownMetrics();
    CalculateConsistencyMetrics();
    CalculateRiskMetrics();
    
    if(m_calculateAdvancedMetrics)
    {
        CalculateAdvancedMetrics();
    }
    
    UpdateReturnsArrays();
}

//+------------------------------------------------------------------+
//| Calculate basic performance metrics                             |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateBasicMetrics()
{
    int totalTrades = ArraySize(m_tradeHistory);
    if(totalTrades == 0)
    {
        ZeroMemory(m_metrics);
        m_metrics.starting_balance = m_startingBalance;
        m_metrics.current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        return;
    }
    
    m_metrics.total_trades = totalTrades;
    m_metrics.winning_trades = 0;
    m_metrics.losing_trades = 0;
    m_metrics.total_profit = 0;
    m_metrics.total_loss = 0;
    m_metrics.largest_win = 0;
    m_metrics.largest_loss = 0;
    
    // Calculate basic statistics
    for(int i = 0; i < totalTrades; i++)
    {
        double profit = m_tradeHistory[i].profit;
        m_metrics.net_profit += profit;
        
        if(profit > 0)
        {
            m_metrics.winning_trades++;
            m_metrics.total_profit += profit;
            m_metrics.gross_profit += profit;
            if(profit > m_metrics.largest_win)
                m_metrics.largest_win = profit;
        }
        else if(profit < 0)
        {
            m_metrics.losing_trades++;
            m_metrics.total_loss += MathAbs(profit);
            m_metrics.gross_loss += MathAbs(profit);
            if(MathAbs(profit) > m_metrics.largest_loss)
                m_metrics.largest_loss = MathAbs(profit);
        }
    }
    
    // Calculate derived metrics
    if(m_metrics.total_trades > 0)
    {
        m_metrics.win_rate = (double)m_metrics.winning_trades / m_metrics.total_trades * 100.0;
    }
    
    if(m_metrics.winning_trades > 0)
    {
        m_metrics.average_win = m_metrics.total_profit / m_metrics.winning_trades;
    }
    
    if(m_metrics.losing_trades > 0)
    {
        m_metrics.average_loss = m_metrics.total_loss / m_metrics.losing_trades;
    }
    
    if(m_metrics.gross_loss > 0)
    {
        m_metrics.profit_factor = m_metrics.gross_profit / m_metrics.gross_loss;
    }
    
    if(m_metrics.total_trades > 0)
    {
        m_metrics.expectancy = m_metrics.net_profit / m_metrics.total_trades;
    }
    
    // Update account metrics
    m_metrics.current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    if(m_metrics.starting_balance > 0)
    {
        m_metrics.growth_rate = ((m_metrics.current_balance - m_metrics.starting_balance) / 
                                m_metrics.starting_balance) * 100.0;
    }
}

//+------------------------------------------------------------------+
//| Calculate drawdown metrics                                      |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateDrawdownMetrics()
{
    if(ArraySize(m_tradeHistory) == 0)
        return;
    
    double runningBalance = m_metrics.starting_balance;
    double peakBalance = runningBalance;
    double maxDD = 0;
    double currentDD = 0;
    
    for(int i = 0; i < ArraySize(m_tradeHistory); i++)
    {
        runningBalance += m_tradeHistory[i].profit;
        
        if(runningBalance > peakBalance)
        {
            peakBalance = runningBalance;
        }
        
        currentDD = peakBalance - runningBalance;
        if(currentDD > maxDD)
        {
            maxDD = currentDD;
        }
    }
    
    m_metrics.max_drawdown = maxDD;
    m_metrics.current_drawdown = peakBalance - m_metrics.current_balance;
    
    if(peakBalance > 0)
    {
        m_metrics.max_drawdown_percent = (maxDD / peakBalance) * 100.0;
    }
    
    if(m_metrics.max_drawdown > 0)
    {
        m_metrics.recovery_factor = m_metrics.net_profit / m_metrics.max_drawdown;
    }
}

//+------------------------------------------------------------------+
//| Calculate risk-adjusted metrics                                 |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateRiskMetrics()
{
    if(ArraySize(m_dailyReturns) < 30) // Need at least 30 days
        return;
    
    // Calculate standard deviation of returns
    double stdDev = CalculateStandardDeviation(m_dailyReturns);
    double downsideDev = CalculateDownsideDeviation(m_dailyReturns);
    
    if(stdDev > 0)
    {
        double avgReturn = 0;
        for(int i = 0; i < ArraySize(m_dailyReturns); i++)
        {
            avgReturn += m_dailyReturns[i];
        }
        avgReturn /= ArraySize(m_dailyReturns);
        
        double riskFreeDaily = GetRiskFreeRateDaily();
        
        // Sharpe Ratio
        m_metrics.sharpe_ratio = (avgReturn - riskFreeDaily) / stdDev;
        
        // Sortino Ratio
        if(downsideDev > 0)
        {
            m_metrics.sortino_ratio = (avgReturn - riskFreeDaily) / downsideDev;
        }
    }
    
    // Calmar Ratio
    if(m_metrics.max_drawdown_percent > 0)
    {
        double annualReturn = m_metrics.growth_rate * (365.0 / MathMax(1, (TimeCurrent() - m_trackingStartTime) / 86400));
        m_metrics.calmar_ratio = annualReturn / m_metrics.max_drawdown_percent;
    }
    
    // MAR Ratio (similar to Calmar)
    m_metrics.mar_ratio = m_metrics.calmar_ratio;
}

//+------------------------------------------------------------------+
//| Calculate consistency metrics                                   |
//+------------------------------------------------------------------+
void CPerformanceTracker::CalculateConsistencyMetrics()
{
    if(ArraySize(m_tradeHistory) == 0)
        return;
    
    int currentWinStreak = 0;
    int currentLossStreak = 0;
    int maxWinStreak = 0;
    int maxLossStreak = 0;
    
    for(int i = 0; i < ArraySize(m_tradeHistory); i++)
    {
        if(m_tradeHistory[i].profit > 0)
        {
            currentWinStreak++;
            currentLossStreak = 0;
            if(currentWinStreak > maxWinStreak)
                maxWinStreak = currentWinStreak;
        }
        else if(m_tradeHistory[i].profit < 0)
        {
            currentLossStreak++;
            currentWinStreak = 0;
            if(currentLossStreak > maxLossStreak)
                maxLossStreak = currentLossStreak;
        }
        else
        {
            currentWinStreak = 0;
            currentLossStreak = 0;
        }
    }
    
    m_metrics.consecutive_wins = currentWinStreak;
    m_metrics.consecutive_losses = currentLossStreak;
    m_metrics.max_consecutive_wins = maxWinStreak;
    m_metrics.max_consecutive_losses = maxLossStreak;
    
    // Calculate consistency score (0-100)
    double winRateScore = m_metrics.win_rate;
    double profitFactorScore = MathMin(m_metrics.profit_factor * 20, 100);
    double drawdownScore = MathMax(0, 100 - m_metrics.max_drawdown_percent * 10);
    
    m_metrics.consistency_score = (winRateScore + profitFactorScore + drawdownScore) / 3.0;
}

//+------------------------------------------------------------------+
//| Generate performance report                                     |
//+------------------------------------------------------------------+
string CPerformanceTracker::GeneratePerformanceReport()
{
    string report = "\n=== CHARTLORD AI PERFORMANCE REPORT ===\n";
    report += "Generated: " + TimeToString(TimeCurrent()) + "\n\n";
    
    report += "BASIC METRICS:\n";
    report += "Total Trades: " + IntegerToString(m_metrics.total_trades) + "\n";
    report += "Win Rate: " + DoubleToString(m_metrics.win_rate, 2) + "%\n";
    report += "Profit Factor: " + DoubleToString(m_metrics.profit_factor, 2) + "\n";
    report += "Expectancy: " + DoubleToString(m_metrics.expectancy, 2) + "\n\n";
    
    report += "PROFIT/LOSS:\n";
    report += "Net Profit: " + DoubleToString(m_metrics.net_profit, 2) + "\n";
    report += "Largest Win: " + DoubleToString(m_metrics.largest_win, 2) + "\n";
    report += "Largest Loss: " + DoubleToString(m_metrics.largest_loss, 2) + "\n";
    report += "Average Win: " + DoubleToString(m_metrics.average_win, 2) + "\n";
    report += "Average Loss: " + DoubleToString(m_metrics.average_loss, 2) + "\n\n";
    
    report += "RISK METRICS:\n";
    report += "Max Drawdown: " + DoubleToString(m_metrics.max_drawdown_percent, 2) + "%\n";
    report += "Sharpe Ratio: " + DoubleToString(m_metrics.sharpe_ratio, 2) + "\n";
    report += "Calmar Ratio: " + DoubleToString(m_metrics.calmar_ratio, 2) + "\n\n";
    
    report += "ACCOUNT GROWTH:\n";
    report += "Starting Balance: " + DoubleToString(m_metrics.starting_balance, 2) + "\n";
    report += "Current Balance: " + DoubleToString(m_metrics.current_balance, 2) + "\n";
    report += "Growth Rate: " + DoubleToString(m_metrics.growth_rate, 2) + "%\n\n";
    
    report += "PERFORMANCE GRADE: " + GetPerformanceGrade() + "\n";
    report += "CONSISTENCY SCORE: " + DoubleToString(m_metrics.consistency_score, 1) + "/100\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| Get performance grade                                           |
//+------------------------------------------------------------------+
string CPerformanceTracker::GetPerformanceGrade()
{
    double score = GetPerformanceScore();
    
    if(score >= 90) return "A+";
    else if(score >= 85) return "A";
    else if(score >= 80) return "A-";
    else if(score >= 75) return "B+";
    else if(score >= 70) return "B";
    else if(score >= 65) return "B-";
    else if(score >= 60) return "C+";
    else if(score >= 55) return "C";
    else if(score >= 50) return "C-";
    else if(score >= 40) return "D";
    else return "F";
}

//--- Additional performance tracking methods continue...