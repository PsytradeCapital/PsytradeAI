# Design Document - AI Trading Expert Advisor

## Architecture Overview

The EA follows a modular architecture with clear separation of concerns:

```
ChartlordAI_EA
├── Core Engine
│   ├── SMC Detection Module
│   ├── Psychology Enforcement Module
│   ├── Risk Management Module
│   └── Trade Execution Module
├── Analysis Layer
│   ├── Multi-Timeframe Analyzer
│   ├── Confluence Detector
│   └── Market Structure Analyzer
├── Risk & Compliance
│   ├── Funded Account Manager
│   ├── Drawdown Monitor
│   └── News Event Handler
└── Utilities
    ├── Logging System
    ├── Performance Tracker
    └── Configuration Manager
```

## Core Modules Design

### 1. SMC Detection Module

**Purpose:** Identify institutional trading patterns and Smart Money Concepts

**Key Functions:**
- `DetectOrderBlocks()` - Identifies swing-based order blocks
- `FindFairValueGaps()` - Detects price imbalances
- `AnalyzeMarketStructure()` - Identifies BOS/CHOCH patterns
- `DetectLiquidityGrabs()` - Finds manipulation patterns
- `ValidateBreakerBlocks()` - Tracks failed order blocks

**Data Structures:**
```cpp
struct OrderBlock {
    datetime timestamp;
    double price_high;
    double price_low;
    ENUM_ORDER_BLOCK_TYPE type; // BULLISH, BEARISH
    bool is_mitigated;
    int strength; // 1-5 based on rejection quality
};

struct FairValueGap {
    datetime start_time;
    double gap_high;
    double gap_low;
    bool is_filled;
    ENUM_FVG_TYPE type;
};
```

### 2. Psychology Enforcement Module

**Purpose:** Implement Mark Douglas's trading psychology principles

**Key Functions:**
- `EnforceProbabilisticThinking()` - Treats each trade independently
- `PreventRevengeTrding()` - Implements cooling-off periods
- `ManageEmotionalState()` - Tracks consecutive losses
- `AcceptUncertainty()` - Avoids forcing trades in unclear conditions

**Psychological Rules:**
1. **Independence Rule:** Each trade is treated as separate event
2. **Acceptance Rule:** Accept losses as part of the process
3. **Discipline Rule:** Follow systematic approach regardless of emotions
4. **Patience Rule:** Wait for proper setups rather than forcing entries

### 3. Risk Management Module

**Purpose:** Comprehensive risk control and account protection

**Key Functions:**
- `CalculatePositionSize()` - Dynamic lot sizing based on risk percentage
- `MonitorDrawdown()` - Real-time drawdown tracking
- `SetStopLoss()` - SMC-based stop loss placement
- `TrailStops()` - SMC level-based trailing
- `EmergencyStop()` - Circuit breaker for excessive losses

**Risk Parameters:**
```cpp
struct RiskSettings {
    double risk_per_trade;      // 0.5-2% of equity
    double max_daily_dd;        // Maximum daily drawdown
    double max_overall_dd;      // Maximum overall drawdown
    int max_open_trades;        // Concurrent position limit
    double emergency_stop;      // Hard stop at equity level
};
```

### 4. Multi-Timeframe Analysis

**Purpose:** Analyze market across multiple timeframes for confluence

**Timeframe Strategy:**
- **H4/D1:** Overall trend and major structure
- **H1:** Intermediate structure and setup identification  
- **M15/M5:** Precise entry timing and execution

**Confluence Requirements:**
- Minimum 3 factors must align for trade execution
- Higher timeframe bias must support lower timeframe entry
- SMC patterns must be present on multiple timeframes

## Trade Execution Logic

### Entry Conditions (ALL must be met):

1. **SMC Setup Present:**
   - Order block identified with clear rejection
   - OR Fair Value Gap with institutional interest
   - OR Breaker block with momentum confirmation

2. **Multi-Timeframe Confluence:**
   - Higher timeframe trend alignment
   - Lower timeframe entry signal
   - No conflicting structure on intermediate timeframes

3. **Technical Confluence:**
   - Fibonacci retracement (0.618, 0.786) alignment
   - Volume profile confirmation
   - Momentum indicators supporting direction

4. **Risk Management Approval:**
   - Position size within risk limits
   - Drawdown levels acceptable
   - No correlation conflicts with existing positions

5. **Market Conditions Suitable:**
   - No high-impact news within 30-60 minutes
   - Normal volatility levels (ATR < 3x average)
   - Trading session active and liquid

### Exit Conditions:

**Stop Loss Placement:**
- Below/above nearest SMC invalidation level
- Minimum 1:2 risk-reward ratio maintained
- Adjusted for broker spread and slippage

**Take Profit Strategy:**
- Primary target at next liquidity pool
- Secondary target at FVG or structure level
- Partial profit taking at 1:1 ratio

**Trailing Stop Logic:**
- Trail to previous order block after BOS confirmation
- Use SMC levels rather than fixed pip distances
- Protect minimum 50% of unrealized profits

## Funded Account Compliance

### Prop Firm Rule Engine:

```cpp
class PropFirmManager {
private:
    ENUM_PROP_FIRM firm_type;
    double daily_dd_limit;
    double overall_dd_limit;
    bool weekend_trading_allowed;
    int min_holding_time; // seconds
    
public:
    bool ValidateTradeCompliance(TradeRequest& request);
    void MonitorDrawdownLimits();
    void EnforceHoldingTimes();
    void HandlePhaseTransitions();
};
```

### Supported Prop Firms:
- FundedNext
- FTMO  
- GoatFunded
- EquityEdge
- MyForexFunds
- The5%ers

### Phase-Specific Logic:
- **Challenge Phase:** Conservative approach, focus on consistency
- **Verification Phase:** Maintain performance while proving consistency
- **Live Phase:** Optimize for long-term profitability

## Performance Optimization

### Account Scaling Strategy:

**Small Accounts ($100-$1,000):**
- Use micro lots (0.01)
- Focus on 1-2 major pairs (EURUSD, GBPUSD)
- Higher risk tolerance (1.5-2% per trade)
- Aggressive compounding every 10% growth

**Medium Accounts ($1,000-$10,000):**
- Standard lots with careful sizing
- Trade 3-5 instruments
- Moderate risk (1% per trade)
- Balanced growth approach

**Large Accounts ($10,000+):**
- Diversified across 5-10 instruments
- Conservative risk (0.5-1% per trade)
- Correlation analysis for position management
- Focus on capital preservation

### Machine Learning Integration:

```cpp
class MLPatternRecognition {
private:
    double pattern_weights[10];
    int historical_performance[100];
    
public:
    double CalculateSetupProbability(SMCSetup& setup);
    void UpdateWeights(TradeResult& result);
    bool IsPatternReliable(int pattern_id);
};
```

## Error Handling and Robustness

### Broker Compatibility:
- Handle different execution modes (Instant, Market, Exchange)
- Adapt to varying spread conditions
- Manage requotes and slippage
- Support different account currencies

### Connection Management:
- Detect connection losses
- Queue pending orders during disconnection
- Validate order execution status
- Implement retry mechanisms with exponential backoff

### Data Validation:
- Verify price data integrity
- Handle missing bars and gaps
- Validate indicator calculations
- Cross-check multiple data sources

## Logging and Monitoring

### Trade Decision Logging:
```cpp
struct TradeLog {
    datetime timestamp;
    string symbol;
    string decision_factors;
    string psychological_state;
    double confidence_level;
    string smc_setup_type;
    double risk_reward_ratio;
};
```

### Performance Metrics:
- Win Rate (target >70%)
- Profit Factor (target >1.5)
- Maximum Drawdown (target <10%)
- Sharpe Ratio (target >1.0)
- Calmar Ratio (target >2.0)

### Psychological Reminders:
- "Executing with discipline: Accepting this as a probabilistic setup"
- "Market uncertainty accepted: Waiting for clear confluence"
- "Emotional detachment maintained: Following systematic rules"
- "Loss accepted: Part of the probabilistic edge"

## Configuration and Customization

### User Parameters:
```cpp
input group "=== Risk Management ==="
input double RiskPerTrade = 1.0;        // Risk per trade (%)
input double MaxDailyDD = 5.0;          // Max daily drawdown (%)
input double MaxOverallDD = 10.0;       // Max overall drawdown (%)
input int MaxOpenTrades = 3;            // Maximum concurrent trades

input group "=== SMC Settings ==="
input int OrderBlockLookback = 20;      // Bars to look back for OB
input double FVGMinSize = 10.0;         // Minimum FVG size in points
input bool UseMultiTimeframe = true;    // Enable MTF analysis

input group "=== Prop Firm Settings ==="
input ENUM_PROP_FIRM PropFirmType = PROP_FIRM_NONE;
input bool WeekendTradingAllowed = true;
input int MinHoldingTime = 60;          // Minimum holding time (seconds)

input group "=== Psychology Settings ==="
input int CoolingOffPeriod = 30;       // Minutes after loss
input int MaxConsecutiveLosses = 3;    // Before reducing size
input bool EnforceEmotionalRules = true;
```

## Testing and Validation

### Backtesting Requirements:
- Minimum 2 years of tick data
- Multiple market conditions (trending, ranging, volatile)
- Different currency pairs and timeframes
- Monte Carlo analysis for robustness

### Performance Targets:
- Annual Return: >50%
- Maximum Drawdown: <10%
- Win Rate: >70%
- Profit Factor: >1.5
- Minimum 1000 trades for statistical significance

### Forward Testing:
- 3-month demo account validation
- Multiple broker environments
- Different account sizes
- Real market conditions including news events

This design provides a comprehensive framework for implementing the AI Trading EA with all required features while maintaining modularity and extensibility.