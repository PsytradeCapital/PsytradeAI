//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"

#include <Trade\Trade.mqh>

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
};

struct TradeSignal
{
    string symbol;
    ENUM_ORDER_TYPE order_type;
    double entry_price;
    double stop_loss;
    double take_profit;
    double confidence;
    string setup_description;
    datetime signal_time;
    bool is_executed;
};

struct ActivePosition
{
    ulong ticket;
    string symbol;
    ENUM_POSITION_TYPE type;
    double volume;
    double open_price;
    double stop_loss;
    double take_profit;
    double current_profit;
    datetime open_time;
    string comment;
    bool is_trailing;
    double trail_level;
    bool partial_closed;
    double original_volume;
};

struct TradeStatistics
{
    int total_trades;
    int winning_trades;
    int losing_trades;
    double total_profit;
    double total_loss;
    double largest_win;
    double largest_loss;
    double win_rate;
    double profit_factor;
    double average_win;
    double average_loss;
    double expectancy;
    int consecutive_wins;
    int consecutive_losses;
    int max_consecutive_wins;
    int max_consecutive_losses;
};

//+------------------------------------------------------------------+
//| Trade Manager Class                                              |
//+------------------------------------------------------------------+
class CTradeManager
{
private:
    CTrade m_trade;
    
    // Configuration
    int m_magicNumber;
    string m_tradeComment;
    double m_minRiskReward;
    
    // Position tracking
    ActivePosition m_positions[];
    TradeSignal m_pendingSignals[];
    
    // Statistics
    TradeStatistics m_stats;
    
    // Trailing stop management
    bool m_useTrailingStops;
    double m_trailDistance;
    double m_trailStep;
    
    // Partial close management
    bool m_usePartialClose;
    double m_partialClosePercent;
    double m_partialCloseRatio;
    
    // Risk management integration
    double m_maxSlippage;
    int m_maxRetries;
    
public:
    CTradeManager();
    ~CTradeManager();
    
    // Initialization
    bool Initialize(int magicNumber, string comment, double minRiskReward);
    
    // Trade execution
    bool ExecuteTrade(const TradeRequest& request, double confidence);
    bool OpenPosition(string symbol, ENUM_ORDER_TYPE orderType, double volume, 
                     double price, double sl, double tp, string comment = "");
    bool ClosePosition(ulong ticket, string reason = "");
    bool CloseAllPositions(string reason = "");
    bool ClosePositionsBySymbol(string symbol, string reason = "");
    
    // Position management
    void MonitorPositions();
    bool ModifyPosition(ulong ticket, double newSL, double newTP);
    bool TrailStop(ulong ticket, double trailDistance);
    bool PartialClose(ulong ticket, double percentage);
    
    // Order management
    bool PlacePendingOrder(const TradeSignal& signal);
    bool ModifyPendingOrder(ulong ticket, double newPrice, double newSL, double newTP);
    bool DeletePendingOrder(ulong ticket);
    void MonitorPendingOrders();
    
    // Position monitoring
    void UpdatePositionArray();
    ActivePosition GetPosition(ulong ticket);
    int GetOpenTradesCount();
    int GetOpenTradesCountBySymbol(string symbol);
    double GetTotalProfit();
    double GetTotalProfitBySymbol(string symbol);
    
    // SMC-based trailing
    bool TrailToSMCLevel(ulong ticket, double smcLevel);
    bool TrailToPreviousOrderBlock(ulong ticket);
    bool TrailToBreakeven(ulong ticket, double minProfit);
    
    // Risk management
    bool ValidateTradeExecution(const TradeRequest& request);
    double CalculateActualSlippage(double requestedPrice, double executedPrice);
    bool IsExecutionAcceptable(double slippage);
    
    // Statistics and reporting
    void UpdateStatistics();
    TradeStatistics GetStatistics() { return m_stats; }
    void ResetStatistics();
    void LogTradeResult(ulong ticket, double profit);
    
    // Emergency functions
    bool EmergencyCloseAll();
    bool CloseLosingPositions();
    bool CloseProfitablePositions();
    
    // Getters and setters
    void SetTrailingStops(bool enabled, double distance, double step);
    void SetPartialClose(bool enabled, double percent, double ratio);
    void SetMaxSlippage(double slippage) { m_maxSlippage = slippage; }
    
private:
    // Helper functions
    bool RetryTradeExecution(const TradeRequest& request, int maxRetries);
    void LogTradeExecution(const TradeRequest& request, bool success, string error = "");
    bool IsMarketOpen(string symbol);
    double NormalizePrice(string symbol, double price);
    double NormalizeLots(string symbol, double lots);
    void SendTradeAlert(string message);
    bool CheckMarginRequirement(string symbol, double volume);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager()
{
    m_magicNumber = 0;
    m_tradeComment = "";
    m_minRiskReward = 2.0;
    
    m_useTrailingStops = true;
    m_trailDistance = 20.0;
    m_trailStep = 5.0;
    
    m_usePartialClose = true;
    m_partialClosePercent = 50.0;
    m_partialCloseRatio = 1.0;
    
    m_maxSlippage = 3.0;
    m_maxRetries = 3;
    
    // Initialize arrays
    ArrayResize(m_positions, 0);
    ArrayResize(m_pendingSignals, 0);
    
    // Initialize statistics
    ZeroMemory(m_stats);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeManager::~CTradeManager()
{
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Initialize Trade Manager                                        |
//+------------------------------------------------------------------+
bool CTradeManager::Initialize(int magicNumber, string comment, double minRiskReward)
{
    m_magicNumber = magicNumber;
    m_tradeComment = comment;
    m_minRiskReward = minRiskReward;
    
    // Set up CTrade object
    m_trade.SetExpertMagicNumber(m_magicNumber);
    m_trade.SetMarginMode();
    m_trade.SetTypeFillingBySymbol(_Symbol);
    
    // Set deviation (slippage) in points
    m_trade.SetDeviationInPoints((ulong)m_maxSlippage);
    
    Print("[TradeManager] Initialized with Magic Number: " + IntegerToString(m_magicNumber) + 
          ", Comment: " + m_tradeComment + 
          ", Min R:R: " + DoubleToString(m_minRiskReward, 1));
    
    return true;
}

//+------------------------------------------------------------------+
//| Execute trade based on request                                  |
//+------------------------------------------------------------------+
bool CTradeManager::ExecuteTrade(const TradeRequest& request, double confidence)
{
    // Validate trade request
    if(!ValidateTradeExecution(request))
    {
        Print("[TradeManager] Trade validation failed for " + request.symbol);
        return false;
    }
    
    // Check market status
    if(!IsMarketOpen(request.symbol))
    {
        Print("[TradeManager] Market closed for " + request.symbol);
        return false;
    }
    
    // Check margin requirement
    if(!CheckMarginRequirement(request.symbol, request.volume))
    {
        Print("[TradeManager] Insufficient margin for " + request.symbol);
        return false;
    }
    
    // Normalize price and volume
    double normalizedPrice = NormalizePrice(request.symbol, request.price);
    double normalizedVolume = NormalizeLots(request.symbol, request.volume);
    double normalizedSL = NormalizePrice(request.symbol, request.stop_loss);
    double normalizedTP = NormalizePrice(request.symbol, request.take_profit);
    
    // Prepare comment with confidence
    string fullComment = m_tradeComment + " | Conf:" + DoubleToString(confidence, 2);
    
    bool success = false;
    
    // Execute based on order type
    switch(request.order_type)
    {
        case ORDER_TYPE_BUY:
            success = m_trade.Buy(normalizedVolume, request.symbol, normalizedPrice, 
                                normalizedSL, normalizedTP, fullComment);
            break;
            
        case ORDER_TYPE_SELL:
            success = m_trade.Sell(normalizedVolume, request.symbol, normalizedPrice, 
                                 normalizedSL, normalizedTP, fullComment);
            break;
            
        case ORDER_TYPE_BUY_LIMIT:
        case ORDER_TYPE_BUY_STOP:
            success = m_trade.OrderOpen(request.symbol, request.order_type, normalizedVolume,
                                      0, normalizedPrice, normalizedSL, normalizedTP,
                                      ORDER_TIME_GTC, 0, fullComment);
            break;
            
        case ORDER_TYPE_SELL_LIMIT:
        case ORDER_TYPE_SELL_STOP:
            success = m_trade.OrderOpen(request.symbol, request.order_type, normalizedVolume,
                                      0, normalizedPrice, normalizedSL, normalizedTP,
                                      ORDER_TIME_GTC, 0, fullComment);
            break;
    }
    
    // Log execution result
    if(success)
    {
        ulong ticket = m_trade.ResultOrder();
        Print("[TradeManager] Trade executed successfully - Ticket: " + IntegerToString(ticket) + 
              ", Symbol: " + request.symbol + 
              ", Volume: " + DoubleToString(normalizedVolume, 2) + 
              ", Confidence: " + DoubleToString(confidence, 2));
        
        // Send alert if enabled
        SendTradeAlert("Trade opened: " + request.symbol + " | " + 
                      DoubleToString(normalizedVolume, 2) + " lots | " +
                      "Conf: " + DoubleToString(confidence, 2));
        
        // Update position array
        UpdatePositionArray();
        
        return true;
    }
    else
    {
        string error = "Error " + IntegerToString(m_trade.ResultRetcode()) + ": " + m_trade.ResultRetcodeDescription();
        Print("[TradeManager] Trade execution failed - " + error);
        
        // Retry if appropriate
        if(m_trade.ResultRetcode() == TRADE_RETCODE_REQUOTE || 
           m_trade.ResultRetcode() == TRADE_RETCODE_PRICE_OFF)
        {
            return RetryTradeExecution(request, m_maxRetries);
        }
        
        LogTradeExecution(request, false, error);
        return false;
    }
}

//+------------------------------------------------------------------+
//| Monitor all open positions                                      |
//+------------------------------------------------------------------+
void CTradeManager::MonitorPositions()
{
    UpdatePositionArray();
    
    for(int i = 0; i < ArraySize(m_positions); i++)
    {
        ActivePosition pos = m_positions[i];
        
        // Update current profit
        if(PositionSelectByTicket(pos.ticket))
        {
            pos.current_profit = PositionGetDouble(POSITION_PROFIT);
            
            // Check for trailing stop
            if(m_useTrailingStops && pos.is_trailing)
            {
                TrailStop(pos.ticket, m_trailDistance);
            }
            
            // Check for partial close at 1:1 ratio
            if(m_usePartialClose && !pos.partial_closed)
            {
                double riskAmount = MathAbs(pos.open_price - pos.stop_loss) * pos.volume;
                if(pos.current_profit >= riskAmount * m_partialCloseRatio)
                {
                    PartialClose(pos.ticket, m_partialClosePercent);
                    pos.partial_closed = true;
                }
            }
            
            // Check for breakeven move after partial close
            if(pos.partial_closed && pos.stop_loss != pos.open_price)
            {
                TrailToBreakeven(pos.ticket, 10.0); // Move to breakeven + 10 points
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Trail stop to SMC level                                        |
//+------------------------------------------------------------------+
bool CTradeManager::TrailToSMCLevel(ulong ticket, double smcLevel)
{
    if(!PositionSelectByTicket(ticket))
        return false;
    
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double currentSL = PositionGetDouble(POSITION_SL);
    double currentPrice = (posType == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_BID) :
                         SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_ASK);
    
    double newSL = smcLevel;
    bool shouldUpdate = false;
    
    if(posType == POSITION_TYPE_BUY)
    {
        // For long positions, only move SL up
        if(newSL > currentSL && newSL < currentPrice)
        {
            shouldUpdate = true;
        }
    }
    else // POSITION_TYPE_SELL
    {
        // For short positions, only move SL down
        if(newSL < currentSL && newSL > currentPrice)
        {
            shouldUpdate = true;
        }
    }
    
    if(shouldUpdate)
    {
        double currentTP = PositionGetDouble(POSITION_TP);
        if(m_trade.PositionModify(ticket, newSL, currentTP))
        {
            Print("[TradeManager] Trailed stop to SMC level: " + DoubleToString(newSL, _Digits) + 
                  " for ticket " + IntegerToString(ticket));
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Trail stop to breakeven plus minimum profit                    |
//+------------------------------------------------------------------+
bool CTradeManager::TrailToBreakeven(ulong ticket, double minProfit)
{
    if(!PositionSelectByTicket(ticket))
        return false;
    
    string symbol = PositionGetString(POSITION_SYMBOL);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentSL = PositionGetDouble(POSITION_SL);
    
    // Calculate breakeven + minimum profit level
    double breakevenLevel = openPrice;
    if(posType == POSITION_TYPE_BUY)
    {
        breakevenLevel += minProfit * SymbolInfoDouble(symbol, SYMBOL_POINT);
    }
    else
    {
        breakevenLevel -= minProfit * SymbolInfoDouble(symbol, SYMBOL_POINT);
    }
    
    // Check if we should update
    bool shouldUpdate = false;
    if(posType == POSITION_TYPE_BUY && breakevenLevel > currentSL)
    {
        shouldUpdate = true;
    }
    else if(posType == POSITION_TYPE_SELL && breakevenLevel < currentSL)
    {
        shouldUpdate = true;
    }
    
    if(shouldUpdate)
    {
        double currentTP = PositionGetDouble(POSITION_TP);
        if(m_trade.PositionModify(ticket, breakevenLevel, currentTP))
        {
            Print("[TradeManager] Moved stop to breakeven+ for ticket " + IntegerToString(ticket));
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Close all positions                                             |
//+------------------------------------------------------------------+
bool CTradeManager::CloseAllPositions(string reason)
{
    Print("[TradeManager] Closing all positions - Reason: " + reason);
    
    bool allClosed = true;
    
    // Close all positions with our magic number
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong posTicket = PositionGetTicket(i);
        if(posTicket > 0 && PositionSelectByTicket(posTicket))
        {
            if(PositionGetInteger(POSITION_MAGIC) == m_magicNumber)
            {
                if(!m_trade.PositionClose(posTicket))
                {
                    Print("[TradeManager] Failed to close position " + IntegerToString(posTicket));
                    allClosed = false;
                }
                else
                {
                    Print("[TradeManager] Closed position " + IntegerToString(posTicket));
                }
            }
        }
    }
    
    // Cancel all pending orders with our magic number
    for(int j = OrdersTotal() - 1; j >= 0; j--)
    {
        ulong orderTicket = OrderGetTicket(j);
        if(orderTicket > 0 && OrderSelect(orderTicket))
        {
            if(OrderGetInteger(ORDER_MAGIC) == m_magicNumber)
            {
                if(!m_trade.OrderDelete(orderTicket))
                {
                    Print("[TradeManager] Failed to delete order " + IntegerToString(orderTicket));
                    allClosed = false;
                }
            }
        }
    }
    
    if(allClosed)
    {
        SendTradeAlert("All positions closed: " + reason);
    }
    
    UpdatePositionArray();
    return allClosed;
}

//+------------------------------------------------------------------+
//| Update position array with current positions                   |
//+------------------------------------------------------------------+
void CTradeManager::UpdatePositionArray()
{
    ArrayResize(m_positions, 0);
    
    for(int i = 0; i < PositionsTotal(); i++)
    {
        ulong posTicket = PositionGetTicket(i);
        if(posTicket > 0 && PositionSelectByTicket(posTicket))
        {
            if(PositionGetInteger(POSITION_MAGIC) == m_magicNumber)
            {
                ActivePosition pos;
                pos.ticket = posTicket;
                pos.symbol = PositionGetString(POSITION_SYMBOL);
                pos.type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                pos.volume = PositionGetDouble(POSITION_VOLUME);
                pos.open_price = PositionGetDouble(POSITION_PRICE_OPEN);
                pos.stop_loss = PositionGetDouble(POSITION_SL);
                pos.take_profit = PositionGetDouble(POSITION_TP);
                pos.current_profit = PositionGetDouble(POSITION_PROFIT);
                pos.open_time = (datetime)PositionGetInteger(POSITION_TIME);
                pos.comment = PositionGetString(POSITION_COMMENT);
                pos.is_trailing = true; // Enable trailing by default
                pos.partial_closed = false;
                pos.original_volume = pos.volume;
                
                ArrayResize(m_positions, ArraySize(m_positions) + 1);
                m_positions[ArraySize(m_positions) - 1] = pos;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Get count of open trades                                        |
//+------------------------------------------------------------------+
int CTradeManager::GetOpenTradesCount()
{
    int count = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        ulong posTicket = PositionGetTicket(i);
        if(posTicket > 0 && PositionSelectByTicket(posTicket))
        {
            if(PositionGetInteger(POSITION_MAGIC) == m_magicNumber)
            {
                count++;
            }
        }
    }
    return count;
}

//--- Additional trade management methods continue...

//+------------------------------------------------------------------+
//| Validate trade execution                                        |
//+------------------------------------------------------------------+
bool CTradeManager::ValidateTradeExecution(const TradeRequest& request)
{
    // Basic validation
    if(request.volume <= 0)
    {
        Print("[TradeManager] Invalid volume: " + DoubleToString(request.volume, 2));
        return false;
    }
    
    if(request.symbol == "")
    {
        Print("[TradeManager] Empty symbol");
        return false;
    }
    
    // Check if symbol exists and is tradeable
    if(!SymbolSelect(request.symbol, true))
    {
        Print("[TradeManager] Symbol not available: " + request.symbol);
        return false;
    }
    
    // Check minimum risk-reward ratio
    if(request.stop_loss != 0 && request.take_profit != 0)
    {
        double risk = MathAbs(request.price - request.stop_loss);
        double reward = MathAbs(request.take_profit - request.price);
        
        if(risk > 0)
        {
            double riskReward = reward / risk;
            if(riskReward < m_minRiskReward)
            {
                Print("[TradeManager] Risk-reward ratio too low: " + DoubleToString(riskReward, 2) + 
                      " (minimum: " + DoubleToString(m_minRiskReward, 2) + ")");
                return false;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Retry trade execution                                           |
//+------------------------------------------------------------------+
bool CTradeManager::RetryTradeExecution(const TradeRequest& request, int maxRetries)
{
    for(int retry = 0; retry < maxRetries; retry++)
    {
        Sleep(100); // Wait 100ms between retries
        
        // Get fresh prices
        double currentAsk = SymbolInfoDouble(request.symbol, SYMBOL_ASK);
        double currentBid = SymbolInfoDouble(request.symbol, SYMBOL_BID);
        
        TradeRequest retryRequest = request;
        
        // Update price based on order type
        if(request.order_type == ORDER_TYPE_BUY)
        {
            retryRequest.price = currentAsk;
        }
        else if(request.order_type == ORDER_TYPE_SELL)
        {
            retryRequest.price = currentBid;
        }
        
        // Try execution again
        bool success = false;
        switch(retryRequest.order_type)
        {
            case ORDER_TYPE_BUY:
                success = m_trade.Buy(retryRequest.volume, retryRequest.symbol, retryRequest.price,
                                    retryRequest.stop_loss, retryRequest.take_profit, retryRequest.comment);
                break;
                
            case ORDER_TYPE_SELL:
                success = m_trade.Sell(retryRequest.volume, retryRequest.symbol, retryRequest.price,
                                     retryRequest.stop_loss, retryRequest.take_profit, retryRequest.comment);
                break;
        }
        
        if(success)
        {
            Print("[TradeManager] Trade executed on retry " + IntegerToString(retry + 1));
            return true;
        }
    }
    
    Print("[TradeManager] All retry attempts failed");
    return false;
}

//+------------------------------------------------------------------+
//| Log trade execution                                             |
//+------------------------------------------------------------------+
void CTradeManager::LogTradeExecution(const TradeRequest& request, bool success, string error = "")
{
    string logMessage = "[TradeManager] Trade " + (success ? "SUCCESS" : "FAILED") + 
                       " - Symbol: " + request.symbol + 
                       ", Type: " + EnumToString(request.order_type) + 
                       ", Volume: " + DoubleToString(request.volume, 2) + 
                       ", Price: " + DoubleToString(request.price, _Digits);
    
    if(!success && error != "")
    {
        logMessage += ", Error: " + error;
    }
    
    Print(logMessage);
}

//+------------------------------------------------------------------+
//| Check if market is open                                         |
//+------------------------------------------------------------------+
bool CTradeManager::IsMarketOpen(string symbol)
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Basic check - avoid weekends
    if(dt.day_of_week == 0 || dt.day_of_week == 6)
    {
        return false;
    }
    
    // Check trading sessions (simplified)
    int hour = dt.hour;
    if(hour >= 0 && hour <= 23) // 24/7 for now, can be refined per symbol
    {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Normalize price to symbol digits                               |
//+------------------------------------------------------------------+
double CTradeManager::NormalizePrice(string symbol, double price)
{
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    return NormalizeDouble(price, digits);
}

//+------------------------------------------------------------------+
//| Normalize lot size to symbol step                              |
//+------------------------------------------------------------------+
double CTradeManager::NormalizeLots(string symbol, double lots)
{
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    lots = MathFloor(lots / lotStep) * lotStep;
    lots = MathMax(minLot, MathMin(lots, maxLot));
    
    return lots;
}

//+------------------------------------------------------------------+
//| Send trade alert                                               |
//+------------------------------------------------------------------+
void CTradeManager::SendTradeAlert(string message)
{
    // Send alert notification
    Alert("[PsyTradeAI] " + message);
    
    // Could also send push notifications, emails, etc.
    // SendNotification(message);
    // SendMail("PsyTradeAI Alert", message);
}

//+------------------------------------------------------------------+
//| Check margin requirement                                        |
//+------------------------------------------------------------------+
bool CTradeManager::CheckMarginRequirement(string symbol, double volume)
{
    double marginRequired = 0;
    
    // Calculate required margin
    if(!OrderCalcMargin(ORDER_TYPE_BUY, symbol, volume, 
                       SymbolInfoDouble(symbol, SYMBOL_ASK), marginRequired))
    {
        Print("[TradeManager] Failed to calculate margin for " + symbol);
        return false;
    }
    
    double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    
    if(marginRequired > freeMargin)
    {
        Print("[TradeManager] Insufficient margin - Required: " + DoubleToString(marginRequired, 2) + 
              ", Available: " + DoubleToString(freeMargin, 2));
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Partial close position                                          |
//+------------------------------------------------------------------+
bool CTradeManager::PartialClose(ulong ticket, double percentage)
{
    if(!PositionSelectByTicket(ticket))
        return false;
    
    double currentVolume = PositionGetDouble(POSITION_VOLUME);
    double closeVolume = currentVolume * (percentage / 100.0);
    
    // Normalize the close volume
    string symbol = PositionGetString(POSITION_SYMBOL);
    closeVolume = NormalizeLots(symbol, closeVolume);
    
    if(closeVolume <= 0)
        return false;
    
    if(m_trade.PositionClosePartial(ticket, closeVolume))
    {
        Print("[TradeManager] Partial close executed - Ticket: " + IntegerToString(ticket) + 
              ", Closed: " + DoubleToString(closeVolume, 2) + " lots (" + 
              DoubleToString(percentage, 1) + "%)");
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Trail stop loss                                                |
//+------------------------------------------------------------------+
bool CTradeManager::TrailStop(ulong ticket, double trailDistance)
{
    if(!PositionSelectByTicket(ticket))
        return false;
    
    string symbol = PositionGetString(POSITION_SYMBOL);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double currentPrice = (posType == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(symbol, SYMBOL_ASK);
    double currentSL = PositionGetDouble(POSITION_SL);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    
    double newSL = 0;
    bool shouldUpdate = false;
    
    if(posType == POSITION_TYPE_BUY)
    {
        newSL = currentPrice - (trailDistance * point);
        if(newSL > currentSL)
        {
            shouldUpdate = true;
        }
    }
    else // POSITION_TYPE_SELL
    {
        newSL = currentPrice + (trailDistance * point);
        if(newSL < currentSL || currentSL == 0)
        {
            shouldUpdate = true;
        }
    }
    
    if(shouldUpdate)
    {
        newSL = NormalizePrice(symbol, newSL);
        double currentTP = PositionGetDouble(POSITION_TP);
        
        if(m_trade.PositionModify(ticket, newSL, currentTP))
        {
            Print("[TradeManager] Trailing stop updated - Ticket: " + IntegerToString(ticket) + 
                  ", New SL: " + DoubleToString(newSL, _Digits));
            return true;
        }
    }
    
    return false;
}