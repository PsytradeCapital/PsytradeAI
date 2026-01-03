# PsyTradeAI Expert Advisor - User Manual

## Table of Contents
1. [Introduction](#introduction)
2. [Installation Guide](#installation-guide)
3. [Configuration](#configuration)
4. [Prop Firm Setup](#prop-firm-setup)
5. [Psychology Settings](#psychology-settings)
6. [Risk Management](#risk-management)
7. [SMC Settings](#smc-settings)
8. [Monitoring and Performance](#monitoring-and-performance)
9. [Troubleshooting](#troubleshooting)
10. [Mark Douglas Trading Psychology](#mark-douglas-trading-psychology)

## Introduction

PsyTradeAI is an advanced Expert Advisor that combines Smart Money Concepts (SMC), Mark Douglas's trading psychology principles, and sophisticated risk management. It's designed to work across all legitimate brokers and is fully compliant with prop firm rules.

### Key Features
- **Smart Money Concepts**: Order blocks, Fair Value Gaps, market structure analysis
- **Psychology Management**: Implements Mark Douglas's "Trading in the Zone" principles
- **Risk Management**: Advanced position sizing and drawdown protection
- **Prop Firm Compliance**: Built-in rules for major prop firms
- **Multi-Timeframe Analysis**: Higher timeframe bias with lower timeframe entries
- **News Filtering**: Automatic news event handling
- **Performance Tracking**: Comprehensive statistics and reporting

## Installation Guide

### Step 1: File Placement
1. Copy the entire `src` folder to your MetaTrader installation directory
2. Place files in the following locations:
   ```
   MetaTrader/MQL5/Experts/PsyTradeAI_EA.mq5
   MetaTrader/MQL5/Include/SMCDetector.mqh
   MetaTrader/MQL5/Include/PsychologyManager.mqh
   MetaTrader/MQL5/Include/RiskManager.mqh
   MetaTrader/MQL5/Include/PropFirmManager.mqh
   MetaTrader/MQL5/Include/TradeManager.mqh
   MetaTrader/MQL5/Include/NewsManager.mqh
   MetaTrader/MQL5/Include/PerformanceTracker.mqh
   ```

### Step 2: Compilation
1. Open MetaEditor (F4 in MetaTrader)
2. Open `PsyTradeAI_EA.mq5`
3. Compile the EA (F7 or Ctrl+F7)
4. Ensure no compilation errors

### Step 3: EA Attachment
1. In MetaTrader, go to Navigator → Expert Advisors
2. Find "PsyTradeAI_EA"
3. Drag and drop onto your chart
4. Configure settings in the parameters dialog

## Configuration

### Basic Setup
```
=== Risk Management ===
Risk per trade (%): 1.0          // Percentage of equity to risk per trade
Max daily drawdown (%): 5.0      // Maximum daily loss before stopping
Max overall drawdown (%): 10.0   // Maximum total loss before stopping
Max open trades: 3               // Maximum concurrent positions
Emergency stop (%): 3.0          // Hard stop at this drawdown level

=== SMC Settings ===
Order Block lookback: 20         // Bars to analyze for order blocks
FVG minimum size: 10.0          // Minimum Fair Value Gap size in points
Structure lookback: 50          // Bars for market structure analysis
Multi-timeframe analysis: true  // Enable MTF confluence
Minimum risk-reward: 2.0        // Minimum R:R ratio for trades

=== General Settings ===
Magic number: 12345             // Unique identifier for EA trades
Trade comment: "PsyTradeAI"    // Comment for all trades
Show visuals: true              // Display SMC levels on chart
Send alerts: true               // Enable trade notifications
Higher timeframe: H4            // Timeframe for overall structure
Lower timeframe: M15            // Timeframe for entry signals
```

## Prop Firm Setup

### Supported Prop Firms
- FTMO
- FundedNext
- GoatFunded
- EquityEdge
- MyForexFunds
- The5%ers
- TopstepTrader
- SurgeTrader
- BlueGuardian

### Configuration for Each Firm

#### FTMO Setup
```
Prop firm type: PROP_FIRM_FTMO
Daily DD limit: 5.0%
Overall DD limit: 10.0%
Weekend trading: false
Minimum holding time: 60 seconds
```

#### FundedNext Setup
```
Prop firm type: PROP_FIRM_FUNDEDNEXT
Daily DD limit: 5.0%
Overall DD limit: 12.0%
Weekend trading: false
Minimum holding time: 60 seconds
```

#### GoatFunded Setup
```
Prop firm type: PROP_FIRM_GOATFUNDED
Daily DD limit: 4.0%
Overall DD limit: 8.0%
Weekend trading: false
Minimum holding time: 60 seconds
```

### Phase-Specific Settings

#### Challenge Phase (Phase 1)
- **Objective**: Achieve 8-10% profit target
- **Strategy**: Conservative approach, focus on consistency
- **Risk per trade**: 0.5-1.0%
- **Max daily trades**: 3-5

#### Verification Phase (Phase 2)
- **Objective**: Achieve 5% profit target
- **Strategy**: Maintain consistency, prove reliability
- **Risk per trade**: 0.5-1.0%
- **Focus**: Steady growth, avoid large drawdowns

#### Live Funded Phase
- **Objective**: Long-term profitability
- **Strategy**: Optimize for sustainable returns
- **Risk per trade**: 1.0-1.5%
- **Focus**: Capital preservation and growth

## Psychology Settings

### Mark Douglas Principles Implementation

#### 1. Probabilistic Thinking
```
Confidence threshold: 0.7        // Minimum setup confidence (0-1)
Enforce emotional rules: true    // Enable psychological controls
```

**Principle**: "Each trade is an independent probabilistic event"
- EA treats every trade separately regardless of previous outcomes
- No revenge trading after losses
- No overconfidence after wins

#### 2. Emotional Detachment
```
Cooling off period: 30          // Minutes to wait after loss
Max consecutive losses: 3       // Before reducing position size
```

**Principle**: "Maintain emotional detachment from outcomes"
- Automatic cooling-off periods after losses
- Position size reduction after consecutive losses
- Systematic approach regardless of emotions

#### 3. Acceptance of Uncertainty
```
Market uncertainty acceptance: true
Force trades in unclear conditions: false
```

**Principle**: "Accept that the market doesn't owe you anything"
- EA waits for clear setups rather than forcing trades
- Accepts losses as part of the probabilistic edge
- No attempts to predict unpredictable market movements

#### 4. Disciplined Execution
```
Follow systematic rules: true
Override emotional responses: true
```

**Principle**: "Follow your trading rules consistently"
- EA executes only when all criteria are met
- No deviation from systematic approach
- Rules-based decision making

### Psychological State Management

The EA monitors and manages psychological states:

1. **NEUTRAL**: Normal trading state
2. **COOLING_OFF**: After loss, waiting period active
3. **REDUCED_SIZE**: After consecutive losses, smaller positions
4. **EMERGENCY_STOP**: Psychological circuit breaker activated
5. **CONFIDENT**: After wins, but controlled
6. **OVERCONFIDENT**: Dangerous state, EA applies controls

## Risk Management

### Position Sizing Formula
```
Position Size = (Account Equity × Risk %) / (Entry Price - Stop Loss) / Pip Value
```

### Dynamic Risk Adjustment
- **Small accounts** (<$1,000): 1.5-2% risk, micro lots
- **Medium accounts** ($1,000-$10,000): 1% risk, standard approach
- **Large accounts** (>$10,000): 0.5-1% risk, diversification focus

### Drawdown Protection
1. **Daily Drawdown**: Stops trading if daily loss exceeds limit
2. **Overall Drawdown**: Stops trading if total loss exceeds limit
3. **Emergency Stop**: Hard stop at critical drawdown level
4. **Equity Protection**: Monitors real-time equity changes

### Correlation Management
- Tracks currency pair correlations
- Limits exposure to correlated instruments
- Prevents over-concentration in single currency

## SMC Settings

### Order Block Detection
```
Lookback period: 20 bars        // How far back to search
Minimum strength: 2             // Quality threshold (1-5)
Rejection quality: 70%          // Minimum rejection strength
```

### Fair Value Gap Settings
```
Minimum size: 10 points         // Smallest FVG to consider
Fill percentage: 50%            // Partial fill threshold
Respect level: 80%              // Reliability threshold
```

### Market Structure Analysis
```
Structure lookback: 50 bars     // Analysis period
BOS confirmation: 2 bars        // Break of structure confirmation
CHOCH sensitivity: Medium       // Change of character detection
```

### Multi-Timeframe Confluence
- **H4/D1**: Overall trend and major structure identification
- **H1**: Intermediate structure and setup confirmation
- **M15/M5**: Precise entry timing and execution

## Monitoring and Performance

### Real-Time Monitoring
The EA provides continuous monitoring of:
- Open positions and their performance
- Risk metrics and drawdown levels
- Psychological state and compliance
- News events and market conditions

### Performance Metrics
- **Win Rate**: Percentage of profitable trades (target >70%)
- **Profit Factor**: Gross profit / Gross loss (target >1.5)
- **Sharpe Ratio**: Risk-adjusted returns (target >1.0)
- **Maximum Drawdown**: Largest peak-to-trough decline (target <10%)
- **Expectancy**: Average profit per trade

### Alerts and Notifications
Configure alerts for:
- Trade executions
- Risk limit breaches
- Psychological state changes
- News events
- Performance milestones

## Troubleshooting

### Common Issues and Solutions

#### 1. EA Not Trading
**Possible Causes:**
- Psychology rules blocking trades
- Risk limits exceeded
- News filter active
- No valid SMC setups

**Solutions:**
- Check psychological state in logs
- Verify drawdown levels
- Review news calendar
- Confirm SMC parameters

#### 2. Frequent Stop Outs
**Possible Causes:**
- Stop loss too tight
- Poor SMC level identification
- High market volatility

**Solutions:**
- Increase ATR multiplier for stops
- Adjust order block strength requirements
- Enable news filtering

#### 3. Low Win Rate
**Possible Causes:**
- Confidence threshold too low
- Poor multi-timeframe alignment
- Inadequate SMC validation

**Solutions:**
- Increase confidence threshold to 0.8+
- Ensure MTF analysis is enabled
- Strengthen SMC detection criteria

#### 4. Prop Firm Violations
**Possible Causes:**
- Incorrect firm settings
- Weekend trading enabled
- Holding time violations

**Solutions:**
- Verify prop firm type selection
- Disable weekend trading
- Increase minimum holding time

### Log Analysis
Monitor EA logs for:
- Trade decision factors
- Psychological reminders
- Risk management actions
- Compliance violations
- Performance updates

## Mark Douglas Trading Psychology

### Core Concepts Implementation

#### "Trading in the Zone" Principles

1. **Anything Can Happen**
   - EA accepts that any individual trade can result in a loss
   - No predictions, only probabilistic assessments
   - Prepared for any outcome

2. **You Don't Need to Know What's Going to Happen Next**
   - EA doesn't try to predict market direction
   - Focuses on identifying high-probability setups
   - Executes based on edge, not predictions

3. **There's a Random Distribution Between Wins and Losses**
   - EA treats each trade independently
   - No pattern seeking in random outcomes
   - Consistent execution regardless of recent results

4. **An Edge is Nothing More Than an Indication of Higher Probability**
   - SMC setups provide the edge
   - Confluence factors increase probability
   - Edge is statistical, not guaranteed

5. **Every Moment in the Market is Unique**
   - EA analyzes current market conditions
   - No assumptions based on past similar situations
   - Fresh analysis for each opportunity

#### "The Disciplined Trader" Implementation

1. **Self-Discipline**
   - Automated rule following
   - No emotional overrides
   - Consistent execution

2. **Overcoming Fear and Greed**
   - Position sizing controls greed
   - Stop losses manage fear
   - Systematic approach eliminates emotions

3. **Developing Consistency**
   - Same analysis process every time
   - Identical execution criteria
   - Standardized risk management

### Psychological Reminders
The EA displays reminders such as:
- "Trading with discipline: Each setup is an independent probabilistic event"
- "Emotional detachment maintained: Outcomes don't define our edge"
- "Accepting uncertainty: The market doesn't owe us anything"
- "Systematic execution: Following rules regardless of recent results"

## Best Practices

### 1. Backtesting
- Test on minimum 2 years of data
- Use tick data for accuracy
- Test multiple market conditions
- Validate across different currency pairs

### 2. Demo Trading
- Run on demo for at least 1 month
- Verify all functions work correctly
- Test prop firm compliance
- Monitor psychological responses

### 3. Live Trading
- Start with minimum position sizes
- Monitor closely for first week
- Gradually increase risk as confidence builds
- Keep detailed performance records

### 4. Optimization
- Review performance monthly
- Adjust parameters based on market conditions
- Update news events regularly
- Maintain psychological discipline

## Support and Updates

For support, updates, and additional resources:
- Documentation: Check the docs folder
- Logs: Monitor MetaTrader Expert tab
- Performance: Review built-in statistics
- Community: Join trading psychology forums

Remember: The EA is a tool to implement disciplined trading. Success depends on proper configuration, realistic expectations, and adherence to Mark Douglas's psychological principles.

---

*"The goal is to learn to think in probabilities and to completely accept the uncertainty of each edge's outcome, while simultaneously keeping the possibility of an unlimited reward constantly available." - Mark Douglas*