# PsyTradeAI Expert Advisor

## 🚀 AI-Powered Trading Robot with Smart Money Concepts & Psychology

PsyTradeAI is a comprehensive Expert Advisor for MetaTrader 4/5 that combines institutional Smart Money Concepts (SMC), Mark Douglas's trading psychology principles, and advanced risk management. Designed for both retail and funded trading accounts with full prop firm compliance.

## ✨ Key Features

### 🧠 Smart Money Concepts (SMC)
- **Order Blocks**: Institutional price levels with rejection analysis
- **Fair Value Gaps (FVGs)**: Price imbalances indicating institutional interest
- **Market Structure**: BOS (Break of Structure) and CHOCH (Change of Character) detection
- **Liquidity Analysis**: Liquidity grabs and inducement pattern recognition
- **Multi-Timeframe Confluence**: H4 structure with M15 entries

### 🧘 Trading Psychology (Mark Douglas Principles)
- **Probabilistic Thinking**: Each trade treated as independent event
- **Emotional Detachment**: Systematic approach regardless of outcomes
- **Acceptance of Uncertainty**: No forcing trades in unclear conditions
- **Disciplined Execution**: Rule-based decision making
- **Cooling-Off Periods**: Prevents revenge trading after losses

### 🛡️ Advanced Risk Management
- **Dynamic Position Sizing**: Based on account equity and risk percentage
- **Drawdown Protection**: Daily and overall drawdown limits
- **Emergency Stops**: Circuit breakers for excessive losses
- **Correlation Management**: Prevents over-exposure to correlated assets
- **Account Scaling**: Adapts to small, medium, and large accounts

### 🏢 Prop Firm Compliance
- **Supported Firms**: FTMO, FundedNext, GoatFunded, EquityEdge, MyForexFunds, The5%ers
- **Phase Management**: Challenge, Verification, and Live phase logic
- **Rule Enforcement**: Automatic compliance with firm-specific rules
- **Violation Prevention**: Real-time monitoring and prevention

### 📊 Performance Tracking
- **Comprehensive Metrics**: Win rate, profit factor, Sharpe ratio, drawdown
- **Real-Time Monitoring**: Live performance analysis
- **Detailed Reporting**: Daily, weekly, and monthly reports
- **Backtesting Framework**: Validation and optimization tools

## 📁 Project Structure

```
PsyTradeAI_EA/
├── .kiro/
│   └── specs/
│       ├── requirements.md      # Detailed requirements
│       └── design.md           # Architecture design
├── src/
│   ├── Experts/
│   │   └── PsyTradeAI_EA.mq5   # Main EA file
│   └── Include/
│       ├── SMCDetector.mqh     # Smart Money Concepts detection
│       ├── PsychologyManager.mqh # Trading psychology implementation
│       ├── RiskManager.mqh     # Risk management system
│       ├── PropFirmManager.mqh # Prop firm compliance
│       ├── TradeManager.mqh    # Trade execution and management
│       ├── NewsManager.mqh     # News event handling
│       └── PerformanceTracker.mqh # Performance analysis
├── docs/
│   └── USER_MANUAL.md          # Comprehensive user guide
├── tests/
│   └── BacktestExample.mq5     # Validation framework
└── README.md                   # This file
```

## 🚀 Quick Start

### 1. Installation
```bash
# Clone the repository
git clone https://github.com/your-username/PsyTradeAI.git

# Copy files to MetaTrader directory
cp -r src/* /path/to/MetaTrader/MQL5/
```

### 2. Compilation
1. Open MetaEditor (F4 in MetaTrader)
2. Open `PsyTradeAI_EA.mq5`
3. Compile (F7)
4. Ensure no errors

### 3. Basic Configuration
```cpp
// Risk Management
Risk per trade: 1.0%
Max daily drawdown: 5.0%
Max overall drawdown: 10.0%

// SMC Settings
Order Block lookback: 20
Multi-timeframe analysis: true
Minimum risk-reward: 2.0

// Psychology Settings
Confidence threshold: 0.7
Cooling off period: 30 minutes
Max consecutive losses: 3
```

### 4. Prop Firm Setup
```cpp
// For FTMO
Prop firm type: PROP_FIRM_FTMO
Daily DD limit: 5.0%
Overall DD limit: 10.0%
Weekend trading: false

// For FundedNext
Prop firm type: PROP_FIRM_FUNDEDNEXT
Daily DD limit: 5.0%
Overall DD limit: 12.0%
Weekend trading: false
```

## 📈 Performance Targets

### Backtesting Requirements
- **Minimum Return**: 50% annually
- **Maximum Drawdown**: <10%
- **Win Rate**: >70%
- **Profit Factor**: >1.5
- **Sharpe Ratio**: >1.0

### Live Trading Expectations
- **Consistency**: Steady monthly returns
- **Risk Control**: Strict adherence to drawdown limits
- **Psychology**: Disciplined execution following Mark Douglas principles
- **Compliance**: 100% prop firm rule adherence

## 🧪 Testing & Validation

### Backtesting Process
1. **Historical Data**: Minimum 2 years tick data
2. **Multiple Conditions**: Trending, ranging, volatile markets
3. **Cross-Validation**: Different currency pairs and timeframes
4. **Monte Carlo**: Robustness testing

### Demo Testing
1. **Duration**: Minimum 1 month
2. **Monitoring**: Daily performance review
3. **Validation**: All functions working correctly
4. **Psychology**: Emotional response testing

### Live Deployment
1. **Start Small**: Minimum position sizes
2. **Monitor Closely**: First week intensive monitoring
3. **Scale Gradually**: Increase risk as confidence builds
4. **Document Everything**: Detailed performance records

## 🎯 Mark Douglas Psychology Implementation

### Core Principles

#### 1. Probabilistic Thinking
```cpp
// Each trade is independent
if(setupConfidence >= threshold) {
    // Execute without considering previous outcomes
    executeTrade(setup);
}
```

#### 2. Emotional Detachment
```cpp
// Cooling-off after losses
if(consecutiveLosses >= maxLosses) {
    enterCoolingOffPeriod();
    reducePositionSize();
}
```

#### 3. Acceptance of Uncertainty
```cpp
// Don't force trades
if(marketUncertainty > threshold) {
    waitForClarity();
    return; // No trade
}
```

#### 4. Disciplined Execution
```cpp
// Follow rules systematically
if(allCriteriaMet(setup)) {
    executeWithDiscipline(setup);
} else {
    waitForProperSetup();
}
```

### Psychological States
- **NEUTRAL**: Normal trading state
- **COOLING_OFF**: Post-loss waiting period
- **REDUCED_SIZE**: After consecutive losses
- **EMERGENCY_STOP**: Circuit breaker activated
- **CONFIDENT**: Controlled confidence after wins

## 🔧 Configuration Examples

### Small Account ($100-$1,000)
```cpp
Risk per trade: 2.0%
Max open trades: 1-2
Focus pairs: EURUSD, GBPUSD
Lot size: Micro lots (0.01)
Approach: Aggressive growth
```

### Medium Account ($1,000-$10,000)
```cpp
Risk per trade: 1.0%
Max open trades: 3-5
Focus pairs: Major pairs
Lot size: Mini/Standard lots
Approach: Balanced growth
```

### Large Account ($10,000+)
```cpp
Risk per trade: 0.5-1.0%
Max open trades: 5-10
Focus pairs: Diversified portfolio
Lot size: Standard lots
Approach: Capital preservation
```

### Prop Firm Accounts
```cpp
Risk per trade: 0.5-1.0%
Strict drawdown limits: Enabled
Weekend trading: Disabled
News filtering: Enabled
Compliance monitoring: Active
```

## 📊 Performance Monitoring

### Real-Time Metrics
- Current drawdown levels
- Open position performance
- Risk exposure analysis
- Psychological state monitoring

### Daily Reports
- Trade summary
- P&L analysis
- Risk metrics update
- Compliance status

### Monthly Analysis
- Performance vs targets
- Strategy effectiveness
- Market condition adaptation
- Psychology rule adherence

## 🛠️ Troubleshooting

### Common Issues

#### EA Not Trading
- Check psychological state (cooling-off period?)
- Verify risk limits (drawdown exceeded?)
- Confirm news filter status
- Validate SMC setup criteria

#### Poor Performance
- Review confidence threshold settings
- Check multi-timeframe alignment
- Verify SMC detection parameters
- Analyze market conditions

#### Prop Firm Violations
- Confirm correct firm selection
- Check weekend trading settings
- Verify holding time compliance
- Review lot size limits

### Log Analysis
Monitor logs for:
- Trade decision factors
- Psychological reminders
- Risk management actions
- Compliance violations

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Follow coding standards
4. Add comprehensive tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

- **Documentation**: Check the `docs/` folder
- **Issues**: Use GitHub Issues
- **Discussions**: GitHub Discussions
- **Email**: support@psytradeai.com

## ⚠️ Disclaimer

Trading involves substantial risk of loss. Past performance does not guarantee future results. This EA is a tool to implement disciplined trading strategies based on Mark Douglas's principles and Smart Money Concepts. Users are responsible for:

- Proper configuration and testing
- Risk management and position sizing
- Compliance with broker and regulatory requirements
- Understanding that losses are part of trading

## 🎓 Educational Resources

### Recommended Reading
- "Trading in the Zone" by Mark Douglas
- "The Disciplined Trader" by Mark Douglas
- Smart Money Concepts educational materials
- Risk management principles

### Video Resources
- @SmartRisk YouTube channel for SMC education
- Mark Douglas trading psychology seminars
- Risk management tutorials

## 🔮 Future Enhancements

### Planned Features
- Machine learning pattern recognition
- Advanced correlation analysis
- Enhanced news integration
- Mobile app connectivity
- Cloud-based performance analytics

### Community Requests
- Additional prop firm support
- Custom indicator integration
- Advanced backtesting features
- Social trading capabilities

---

## 💡 Remember Mark Douglas's Wisdom

*"The goal is to learn to think in probabilities and to completely accept the uncertainty of each edge's outcome, while simultaneously keeping the possibility of an unlimited reward constantly available."*

**Trade with discipline. Accept uncertainty. Execute systematically.**

---

**PsyTradeAI - Where Psychology Meets Technology** �