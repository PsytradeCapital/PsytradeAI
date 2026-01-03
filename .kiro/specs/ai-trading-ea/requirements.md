# Requirements Document

## Introduction

An AI-powered Expert Advisor (EA) for MetaTrader 4/5 platforms that functions as an automated trading robot, integrating Smart Money Concepts (SMC), psychological trading principles from Mark Douglas's works, and sophisticated risk management for both retail and funded trading accounts.

## Glossary

- **EA**: Expert Advisor - automated trading program for MetaTrader platforms
- **SMC**: Smart Money Concepts - institutional trading methodology focusing on order blocks, liquidity, and market structure
- **Order_Block**: Price level where institutional orders were placed, identified by swing highs/lows with rejection
- **FVG**: Fair Value Gap - imbalance in price action showing institutional interest
- **BOS**: Break of Structure - price breaking previous significant high/low indicating trend continuation
- **CHOCH**: Change of Character - shift in market structure indicating potential trend reversal
- **Breaker_Block**: Failed order block that becomes resistance/support after being broken
- **Mitigation_Block**: Order block that has been partially filled but still holds significance
- **Liquidity_Grab**: Price movement designed to trigger stop losses before reversing
- **Inducement**: Price action designed to attract retail traders before institutional move
- **Prop_Firm**: Proprietary trading firm providing funded accounts with specific rules and drawdown limits
- **Drawdown_Limit**: Maximum allowable loss percentage (daily/overall) before account violation
- **Risk_Reward_Ratio**: Ratio of potential profit to potential loss (e.g., 1:2 means risk $1 to make $2)
- **ATR**: Average True Range - volatility indicator measuring price movement
- **Slippage**: Difference between expected and actual execution price
- **Magic_Number**: Unique identifier for EA trades to distinguish from manual trades

## Requirements

### Requirement 1: Smart Money Concepts Detection

**User Story:** As a trader, I want the EA to identify institutional trading patterns using Smart Money Concepts, so that I can enter trades aligned with institutional flow.

#### Acceptance Criteria

1. WHEN analyzing price action, THE EA SHALL identify order blocks by detecting swing highs/lows with subsequent price rejection
2. WHEN price creates imbalances, THE EA SHALL detect Fair Value Gaps (FVGs) as areas of rapid price movement with minimal trading
3. WHEN market structure changes, THE EA SHALL identify Break of Structure (BOS) events by detecting breaks of previous significant highs/lows
4. WHEN trend direction shifts, THE EA SHALL detect Change of Character (CHOCH) patterns indicating potential reversals
5. WHEN order blocks fail, THE EA SHALL identify breaker blocks that become new support/resistance levels
6. WHEN institutional manipulation occurs, THE EA SHALL detect liquidity grabs and inducement patterns
7. WHEN order blocks are partially filled, THE EA SHALL track mitigation blocks for potential re-entries

### Requirement 2: Multi-Timeframe Analysis

**User Story:** As a trader, I want the EA to analyze multiple timeframes simultaneously, so that I can identify high-probability trade setups with proper confluence.

#### Acceptance Criteria

1. WHEN analyzing market structure, THE EA SHALL use higher timeframes (H4/D1) for overall trend direction
2. WHEN seeking entry points, THE EA SHALL use lower timeframes (M15/M5) for precise timing
3. WHEN timeframes align, THE EA SHALL only execute trades with multi-timeframe confluence
4. WHEN timeframes conflict, THE EA SHALL avoid trading until alignment occurs
5. WHEN structure breaks on higher timeframe, THE EA SHALL look for entries on lower timeframe pullbacks

### Requirement 3: Psychological Trading Rules Implementation

**User Story:** As a trader, I want the EA to enforce disciplined trading psychology based on Mark Douglas's principles, so that I can avoid emotional trading mistakes.

#### Acceptance Criteria

1. WHEN evaluating trades, THE EA SHALL treat each setup as an independent probabilistic event
2. WHEN a losing trade occurs, THE EA SHALL prevent revenge trading by enforcing cooling-off periods
3. WHEN consecutive losses occur, THE EA SHALL reduce position sizes according to predefined rules
4. WHEN market conditions are uncertain, THE EA SHALL accept uncertainty and avoid forcing trades
5. WHEN trades are executed, THE EA SHALL maintain emotional detachment by following systematic rules
6. WHEN fear or greed patterns are detected, THE EA SHALL override emotional responses with rule-based decisions

### Requirement 4: Entry Point Optimization

**User Story:** As a trader, I want the EA to identify perfect entry points with high-probability confluences, so that I can maximize win rate and profitability.

#### Acceptance Criteria

1. WHEN SMC setup is identified, THE EA SHALL confirm entry with Fibonacci retracement levels (0.618, 0.786)
2. WHEN FVG is present, THE EA SHALL enter on partial fill of the gap with volume confirmation
3. WHEN order block is identified, THE EA SHALL enter on first rejection from the block with momentum confirmation
4. WHEN multiple confluences align, THE EA SHALL prioritize trades with 3+ confirmation factors
5. WHEN entry conditions are met, THE EA SHALL execute trades within 1-2 bars of signal generation
6. WHEN no clear setup exists, THE EA SHALL wait for proper confluence rather than forcing entries

### Requirement 5: Risk Management System

**User Story:** As a trader, I want comprehensive risk management that protects my account while allowing for growth, so that I can trade safely across different account types.

#### Acceptance Criteria

1. WHEN calculating position size, THE EA SHALL risk no more than 0.5-2% of account equity per trade
2. WHEN drawdown reaches 3-5%, THE EA SHALL pause all trading until manual review
3. WHEN stop loss is set, THE EA SHALL place it beyond the nearest SMC invalidation level
4. WHEN take profit is set, THE EA SHALL target minimum 1:2 risk-reward ratio
5. WHEN trailing stops are used, THE EA SHALL trail based on SMC levels rather than fixed pips
6. WHEN maximum open trades limit is reached, THE EA SHALL wait for position closure before new entries

### Requirement 6: Funded Account Compliance

**User Story:** As a funded trader, I want the EA to strictly adhere to prop firm rules, so that I can pass challenges and maintain funded accounts.

#### Acceptance Criteria

1. WHEN daily drawdown approaches limit, THE EA SHALL reduce position sizes or pause trading
2. WHEN overall drawdown approaches limit, THE EA SHALL implement emergency stop-loss protocols
3. WHEN trading during challenge phases, THE EA SHALL adjust strategy to meet profit targets within drawdown limits
4. WHEN high-frequency trading is detected, THE EA SHALL enforce minimum holding times (>1 minute)
5. WHEN weekend trading is restricted, THE EA SHALL automatically pause during prohibited hours
6. WHEN news events occur, THE EA SHALL pause trading 30-60 minutes before/after high-impact releases

### Requirement 7: Multi-Asset and Multi-Broker Compatibility

**User Story:** As a trader, I want the EA to work across different brokers and asset classes, so that I can use it flexibly across my trading accounts.

#### Acceptance Criteria

1. WHEN deployed on different brokers, THE EA SHALL adapt to varying spread and execution conditions
2. WHEN trading forex pairs, THE EA SHALL handle major, minor, and exotic currency pairs
3. WHEN trading indices, THE EA SHALL adjust for different contract specifications and trading hours
4. WHEN trading commodities, THE EA SHALL account for seasonal patterns and storage costs
5. WHEN trading cryptocurrencies, THE EA SHALL handle 24/7 markets and high volatility
6. WHEN slippage occurs, THE EA SHALL use pending orders to minimize execution differences
7. WHEN requotes happen, THE EA SHALL retry orders with adjusted prices within tolerance limits

### Requirement 8: News and Market Event Handling

**User Story:** As a trader, I want the EA to handle high-impact news events intelligently, so that I can avoid unnecessary losses during volatile periods.

#### Acceptance Criteria

1. WHEN high-impact news is scheduled, THE EA SHALL pause new entries 30-60 minutes before the event
2. WHEN volatility spikes beyond ATR threshold (>3x), THE EA SHALL widen stop losses or close positions
3. WHEN news events pass, THE EA SHALL resume normal trading after volatility normalizes
4. WHEN economic calendar data is available, THE EA SHALL integrate event impact levels into decision making
5. WHEN unexpected news breaks, THE EA SHALL detect abnormal volatility and adjust accordingly

### Requirement 9: Account Growth and Scaling

**User Story:** As a trader, I want the EA to grow my account systematically while managing risk, so that I can achieve consistent profitability.

#### Acceptance Criteria

1. WHEN account equity increases by 10%, THE EA SHALL compound position sizes proportionally
2. WHEN small accounts (<$1000) are detected, THE EA SHALL use micro-lots and focus on 1-2 pairs
3. WHEN large accounts (>$10000) are detected, THE EA SHALL diversify across 5-10 instruments
4. WHEN correlation between instruments is high, THE EA SHALL limit exposure to correlated assets
5. WHEN account growth targets are met, THE EA SHALL adjust risk parameters to protect profits

### Requirement 10: Performance Monitoring and Logging

**User Story:** As a trader, I want detailed performance tracking and logging, so that I can monitor the EA's effectiveness and make improvements.

#### Acceptance Criteria

1. WHEN trades are executed, THE EA SHALL log all decision factors and psychological reminders
2. WHEN performance metrics are calculated, THE EA SHALL track win rate, profit factor, and drawdown
3. WHEN backtesting is performed, THE EA SHALL generate comprehensive reports with key statistics
4. WHEN optimization is run, THE EA SHALL identify best parameter combinations for different market conditions
5. WHEN errors occur, THE EA SHALL log detailed error messages for troubleshooting
6. WHEN psychological rules are triggered, THE EA SHALL log the specific rule and action taken

### Requirement 11: User Interface and Customization

**User Story:** As a trader, I want an intuitive interface to customize the EA settings, so that I can adapt it to my specific trading preferences and account requirements.

#### Acceptance Criteria

1. WHEN EA is loaded, THE EA SHALL display clear parameter inputs for risk management settings
2. WHEN prop firm rules are selected, THE EA SHALL automatically configure appropriate drawdown limits
3. WHEN trading hours are set, THE EA SHALL respect user-defined active trading sessions
4. WHEN magic numbers are assigned, THE EA SHALL manage multiple instances without conflicts
5. WHEN visual indicators are enabled, THE EA SHALL display SMC levels and trade signals on charts
6. WHEN alerts are configured, THE EA SHALL send notifications for important events and trade executions

### Requirement 12: Backtesting and Optimization Framework

**User Story:** As a trader, I want comprehensive backtesting capabilities, so that I can validate the EA's performance before live trading.

#### Acceptance Criteria

1. WHEN backtesting is initiated, THE EA SHALL use MetaTrader's Strategy Tester with tick-level precision
2. WHEN optimization is performed, THE EA SHALL test parameter combinations across multiple timeframes
3. WHEN historical data is analyzed, THE EA SHALL achieve minimum 50% annual return with <10% maximum drawdown
4. WHEN different market conditions are tested, THE EA SHALL demonstrate adaptability across trending and ranging markets
5. WHEN statistical analysis is performed, THE EA SHALL maintain >70% win rate with minimum 1:2 risk-reward ratio
6. WHEN forward testing is conducted, THE EA SHALL show consistent performance across out-of-sample data