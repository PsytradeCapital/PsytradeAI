//+------------------------------------------------------------------+
//|                                                  NewsManager.mqh |
//|                                    Copyright 2026, PsyTradeAI Ltd |
//|                                       https://www.psytradeai.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, PsyTradeAI Ltd"
#property link      "https://www.psytradeai.com"

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_NEWS_IMPACT
{
    NEWS_IMPACT_LOW,
    NEWS_IMPACT_MEDIUM,
    NEWS_IMPACT_HIGH,
    NEWS_IMPACT_UNKNOWN
};

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct NewsEvent
{
    datetime event_time;
    string currency;
    string event_name;
    ENUM_NEWS_IMPACT impact;
    string forecast;
    string previous;
    bool is_processed;
    int minutes_before_filter;
    int minutes_after_filter;
};

struct NewsFilter
{
    bool filter_high_impact;
    bool filter_medium_impact;
    bool filter_low_impact;
    int minutes_before;
    int minutes_after;
    bool close_positions_before;
    bool widen_stops_during;
    double stop_multiplier;
    bool pause_new_trades;
};

//+------------------------------------------------------------------+
//| News Manager Class                                              |
//+------------------------------------------------------------------+
class CNewsManager
{
private:
    NewsFilter m_filter;
    NewsEvent m_newsEvents[];
    
    // Configuration
    int m_filterMinutes;
    bool m_autoCloseBeforeNews;
    bool m_widenStopsDuringNews;
    double m_stopMultiplier;
    
    // State tracking
    bool m_isNewsTime;
    bool m_isHighImpactTime;
    datetime m_nextNewsTime;
    string m_nextNewsEvent;
    datetime m_lastNewsCheck;
    
    // Manual news events (when calendar API not available)
    string m_manualEvents[];
    datetime m_manualEventTimes[];
    ENUM_NEWS_IMPACT m_manualEventImpacts[];
    
public:
    CNewsManager();
    ~CNewsManager();
    
    // Initialization
    bool Initialize(int filterMinutes);
    void UpdateNewsStatus();
    
    // News filtering
    bool IsTradeAllowed();
    bool IsNewsTime();
    bool IsHighImpactNewsTime();
    datetime GetNextNewsTime();
    string GetNextNewsEvent();
    
    // Configuration
    void SetNewsFilter(bool highImpact, bool mediumImpact, bool lowImpact, 
                      int minutesBefore, int minutesAfter);
    void SetAutoClose(bool enabled) { m_autoCloseBeforeNews = enabled; }
    void SetStopWidening(bool enabled, double multiplier);
    
    // Manual news management
    void AddManualNewsEvent(datetime eventTime, string eventName, ENUM_NEWS_IMPACT impact);
    void ClearManualEvents();
    bool LoadNewsFromFile(string filename);
    
    // News impact assessment
    ENUM_NEWS_IMPACT AssessNewsImpact(string eventName);
    bool ShouldFilterNews(const NewsEvent& news);
    int GetFilterMinutes(ENUM_NEWS_IMPACT impact);
    
    // Market volatility during news
    bool IsVolatilityHigh();
    double GetATRMultiplier();
    bool ShouldWidenStops();
    
    // Getters
    NewsFilter GetFilter() { return m_filter; }
    bool IsAutoCloseEnabled() { return m_autoCloseBeforeNews; }
    
private:
    // Helper functions
    void LoadDefaultNewsEvents();
    void CheckUpcomingNews();
    bool IsWithinNewsWindow(datetime newsTime, int minutesBefore, int minutesAfter);
    void ProcessNewsEvent(const NewsEvent& news);
    string GetCurrencyFromSymbol(string symbol);
    bool IsCurrencyAffected(string currency, string symbol);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CNewsManager::CNewsManager()
{
    m_filterMinutes = 30;
    m_autoCloseBeforeNews = false;
    m_widenStopsDuringNews = true;
    m_stopMultiplier = 1.5;
    
    m_isNewsTime = false;
    m_isHighImpactTime = false;
    m_nextNewsTime = 0;
    m_nextNewsEvent = "";
    m_lastNewsCheck = 0;
    
    // Initialize filter settings
    m_filter.filter_high_impact = true;
    m_filter.filter_medium_impact = false;
    m_filter.filter_low_impact = false;
    m_filter.minutes_before = 30;
    m_filter.minutes_after = 30;
    m_filter.close_positions_before = false;
    m_filter.widen_stops_during = true;
    m_filter.stop_multiplier = 1.5;
    m_filter.pause_new_trades = true;
    
    ArrayResize(m_newsEvents, 0);
    ArrayResize(m_manualEvents, 0);
    ArrayResize(m_manualEventTimes, 0);
    ArrayResize(m_manualEventImpacts, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CNewsManager::~CNewsManager()
{
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| Initialize News Manager                                         |
//+------------------------------------------------------------------+
bool CNewsManager::Initialize(int filterMinutes)
{
    m_filterMinutes = filterMinutes;
    
    // Load default high-impact news events
    LoadDefaultNewsEvents();
    
    Print("[NewsManager] Initialized with filter: " + IntegerToString(m_filterMinutes) + " minutes");
    Print("[NewsManager] High impact filter: " + (m_filter.filter_high_impact ? "ON" : "OFF"));
    Print("[NewsManager] Auto close before news: " + (m_autoCloseBeforeNews ? "ON" : "OFF"));
    
    return true;
}

//+------------------------------------------------------------------+
//| Update news status                                              |
//+------------------------------------------------------------------+
void CNewsManager::UpdateNewsStatus()
{
    datetime currentTime = TimeCurrent();
    
    // Update only every minute to avoid excessive processing
    if(currentTime - m_lastNewsCheck < 60)
        return;
    
    m_lastNewsCheck = currentTime;
    
    // Check for upcoming news
    CheckUpcomingNews();
    
    // Update news time status
    m_isNewsTime = false;
    m_isHighImpactTime = false;
    
    // Check manual events
    for(int i = 0; i < ArraySize(m_manualEventTimes); i++)
    {
        if(IsWithinNewsWindow(m_manualEventTimes[i], m_filter.minutes_before, m_filter.minutes_after))
        {
            m_isNewsTime = true;
            if(m_manualEventImpacts[i] == NEWS_IMPACT_HIGH)
            {
                m_isHighImpactTime = true;
            }
        }
    }
    
    // Check loaded news events
    for(int i = 0; i < ArraySize(m_newsEvents); i++)
    {
        if(IsWithinNewsWindow(m_newsEvents[i].event_time, 
                             m_newsEvents[i].minutes_before_filter,
                             m_newsEvents[i].minutes_after_filter))
        {
            m_isNewsTime = true;
            if(m_newsEvents[i].impact == NEWS_IMPACT_HIGH)
            {
                m_isHighImpactTime = true;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check if trading is allowed based on news                      |
//+------------------------------------------------------------------+
bool CNewsManager::IsTradeAllowed()
{
    if(!m_filter.pause_new_trades)
        return true;
    
    // Check high impact news
    if(m_filter.filter_high_impact && m_isHighImpactTime)
    {
        Print("[NewsManager] Trading blocked: High impact news time");
        return false;
    }
    
    // Check medium impact news
    if(m_filter.filter_medium_impact && m_isNewsTime)
    {
        // Additional check for medium impact specifically
        for(int i = 0; i < ArraySize(m_newsEvents); i++)
        {
            if(m_newsEvents[i].impact == NEWS_IMPACT_MEDIUM &&
               IsWithinNewsWindow(m_newsEvents[i].event_time, 
                                m_newsEvents[i].minutes_before_filter,
                                m_newsEvents[i].minutes_after_filter))
            {
                Print("[NewsManager] Trading blocked: Medium impact news time");
                return false;
            }
        }
    }
    
    // Check low impact news
    if(m_filter.filter_low_impact && m_isNewsTime)
    {
        for(int i = 0; i < ArraySize(m_newsEvents); i++)
        {
            if(m_newsEvents[i].impact == NEWS_IMPACT_LOW &&
               IsWithinNewsWindow(m_newsEvents[i].event_time, 
                                m_newsEvents[i].minutes_before_filter,
                                m_newsEvents[i].minutes_after_filter))
            {
                Print("[NewsManager] Trading blocked: Low impact news time");
                return false;
            }
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Load default high-impact news events                           |
//+------------------------------------------------------------------+
void CNewsManager::LoadDefaultNewsEvents()
{
    // Clear existing events
    ArrayResize(m_newsEvents, 0);
    
    // Get current time for scheduling
    datetime currentTime = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);
    
    // Add major recurring news events (examples - in real implementation, 
    // these would be loaded from economic calendar API or file)
    
    // US Non-Farm Payrolls (First Friday of month at 8:30 AM EST)
    AddManualNewsEvent(GetNextNFPTime(), "US Non-Farm Payrolls", NEWS_IMPACT_HIGH);
    
    // FOMC Rate Decision (8 times per year, 2:00 PM EST)
    AddManualNewsEvent(GetNextFOMCTime(), "FOMC Rate Decision", NEWS_IMPACT_HIGH);
    
    // US CPI (Monthly, usually 8:30 AM EST)
    AddManualNewsEvent(GetNextCPITime(), "US CPI", NEWS_IMPACT_HIGH);
    
    // ECB Rate Decision (8 times per year, 7:45 AM EST)
    AddManualNewsEvent(GetNextECBTime(), "ECB Rate Decision", NEWS_IMPACT_HIGH);
    
    Print("[NewsManager] Loaded " + IntegerToString(ArraySize(m_manualEvents)) + " default news events");
}

//+------------------------------------------------------------------+
//| Add manual news event                                           |
//+------------------------------------------------------------------+
void CNewsManager::AddManualNewsEvent(datetime eventTime, string eventName, ENUM_NEWS_IMPACT impact)
{
    int size = ArraySize(m_manualEvents);
    ArrayResize(m_manualEvents, size + 1);
    ArrayResize(m_manualEventTimes, size + 1);
    ArrayResize(m_manualEventImpacts, size + 1);
    
    m_manualEvents[size] = eventName;
    m_manualEventTimes[size] = eventTime;
    m_manualEventImpacts[size] = impact;
    
    Print("[NewsManager] Added manual event: " + eventName + " at " + TimeToString(eventTime));
}

//+------------------------------------------------------------------+
//| Check if within news window                                     |
//+------------------------------------------------------------------+
bool CNewsManager::IsWithinNewsWindow(datetime newsTime, int minutesBefore, int minutesAfter)
{
    datetime currentTime = TimeCurrent();
    datetime startWindow = newsTime - (minutesBefore * 60);
    datetime endWindow = newsTime + (minutesAfter * 60);
    
    return (currentTime >= startWindow && currentTime <= endWindow);
}

//+------------------------------------------------------------------+
//| Check upcoming news                                             |
//+------------------------------------------------------------------+
void CNewsManager::CheckUpcomingNews()
{
    datetime currentTime = TimeCurrent();
    datetime nextNews = 0;
    string nextEvent = "";
    
    // Check manual events
    for(int i = 0; i < ArraySize(m_manualEventTimes); i++)
    {
        if(m_manualEventTimes[i] > currentTime)
        {
            if(nextNews == 0 || m_manualEventTimes[i] < nextNews)
            {
                nextNews = m_manualEventTimes[i];
                nextEvent = m_manualEvents[i];
            }
        }
    }
    
    // Check loaded events
    for(int i = 0; i < ArraySize(m_newsEvents); i++)
    {
        if(m_newsEvents[i].event_time > currentTime)
        {
            if(nextNews == 0 || m_newsEvents[i].event_time < nextNews)
            {
                nextNews = m_newsEvents[i].event_time;
                nextEvent = m_newsEvents[i].event_name;
            }
        }
    }
    
    m_nextNewsTime = nextNews;
    m_nextNewsEvent = nextEvent;
    
    // Alert if news is within 1 hour
    if(nextNews > 0 && nextNews - currentTime <= 3600 && nextNews - currentTime > 3540)
    {
        Print("[NewsManager] Upcoming news in 1 hour: " + nextEvent + " at " + TimeToString(nextNews));
    }
}

//+------------------------------------------------------------------+
//| Get next NFP time (first Friday of month)                      |
//+------------------------------------------------------------------+
datetime GetNextNFPTime()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Move to next month
    dt.mon++;
    if(dt.mon > 12)
    {
        dt.mon = 1;
        dt.year++;
    }
    
    // Set to first day of month
    dt.day = 1;
    dt.hour = 13; // 8:30 AM EST = 13:30 GMT
    dt.min = 30;
    dt.sec = 0;
    
    datetime firstDay = StructToTime(dt);
    TimeToStruct(firstDay, dt);
    
    // Find first Friday (day_of_week = 5)
    int daysToAdd = (5 - dt.day_of_week + 7) % 7;
    if(daysToAdd == 0 && dt.day_of_week != 5)
        daysToAdd = 7;
    
    return firstDay + (daysToAdd * 86400);
}

//+------------------------------------------------------------------+
//| Get next FOMC time (approximate - 8 times per year)           |
//+------------------------------------------------------------------+
datetime GetNextFOMCTime()
{
    // Simplified - in real implementation, use actual FOMC schedule
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Next month, mid-month, 2 PM EST
    dt.mon++;
    if(dt.mon > 12)
    {
        dt.mon = 1;
        dt.year++;
    }
    
    dt.day = 15; // Mid-month approximation
    dt.hour = 19; // 2 PM EST = 19:00 GMT
    dt.min = 0;
    dt.sec = 0;
    
    return StructToTime(dt);
}

//+------------------------------------------------------------------+
//| Get next CPI time (monthly, usually mid-month)                |
//+------------------------------------------------------------------+
datetime GetNextCPITime()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Next month, around 13th, 8:30 AM EST
    dt.mon++;
    if(dt.mon > 12)
    {
        dt.mon = 1;
        dt.year++;
    }
    
    dt.day = 13; // Typical CPI release day
    dt.hour = 13; // 8:30 AM EST = 13:30 GMT
    dt.min = 30;
    dt.sec = 0;
    
    return StructToTime(dt);
}

//+------------------------------------------------------------------+
//| Get next ECB time (8 times per year)                          |
//+------------------------------------------------------------------+
datetime GetNextECBTime()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    // Next month, mid-month, 7:45 AM EST
    dt.mon++;
    if(dt.mon > 12)
    {
        dt.mon = 1;
        dt.year++;
    }
    
    dt.day = 20; // Typical ECB meeting day
    dt.hour = 12; // 7:45 AM EST = 12:45 GMT
    dt.min = 45;
    dt.sec = 0;
    
    return StructToTime(dt);
}

//--- Additional news management methods continue...