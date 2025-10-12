import 'dart:math';

/// Represents different asset types available for investment
enum AssetType {
  fixedDeposit,
  sip,
  stocks,
  crypto,
}

extension AssetTypeExtension on AssetType {
  String get name {
    switch (this) {
      case AssetType.fixedDeposit:
        return 'Fixed Deposit';
      case AssetType.sip:
        return 'SIP';
      case AssetType.stocks:
        return 'Stocks';
      case AssetType.crypto:
        return 'Crypto';
    }
  }

  String get emoji {
    switch (this) {
      case AssetType.fixedDeposit:
        return '🏦';
      case AssetType.sip:
        return '📈';
      case AssetType.stocks:
        return '💹';
      case AssetType.crypto:
        return '₿';
    }
  }

  String get description {
    switch (this) {
      case AssetType.fixedDeposit:
        return 'Low risk, stable returns. Best for safety.';
      case AssetType.sip:
        return 'Systematic Investment Plan. Medium risk, steady growth.';
      case AssetType.stocks:
        return 'High potential returns but volatile. Invest wisely!';
      case AssetType.crypto:
        return 'Very high risk & reward. Only for risk-takers.';
    }
  }

  // Base annual return rates (will be modified by market conditions)
  double get baseReturnRate {
    switch (this) {
      case AssetType.fixedDeposit:
        return 0.07; // 7%
      case AssetType.sip:
        return 0.12; // 12%
      case AssetType.stocks:
        return 0.15; // 15%
      case AssetType.crypto:
        return 0.20; // 20%
    }
  }

  // Volatility factor (how much returns can vary)
  double get volatility {
    switch (this) {
      case AssetType.fixedDeposit:
        return 0.02; // ±2%
      case AssetType.sip:
        return 0.08; // ±8%
      case AssetType.stocks:
        return 0.25; // ±25%
      case AssetType.crypto:
        return 0.50; // ±50%
    }
  }
}

/// Game difficulty levels
enum DifficultyLevel {
  easy,
  medium,
  hard,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get name {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Stable markets, fewer events';
      case DifficultyLevel.medium:
        return 'Normal market conditions';
      case DifficultyLevel.hard:
        return 'Volatile markets, frequent events';
    }
  }

  // Frequency of market events
  double get eventFrequency {
    switch (this) {
      case DifficultyLevel.easy:
        return 0.1; // 10% chance per year
      case DifficultyLevel.medium:
        return 0.25; // 25% chance per year
      case DifficultyLevel.hard:
        return 0.4; // 40% chance per year
    }
  }

  // Initial capital
  int get startingCapital {
    switch (this) {
      case DifficultyLevel.easy:
        return 15000;
      case DifficultyLevel.medium:
        return 10000;
      case DifficultyLevel.hard:
        return 8000;
    }
  }
}

/// Market events that can occur during simulation
class MarketEvent {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Map<AssetType, double> impactMultipliers; // Multiplier for returns
  final int duration; // How many years the effect lasts

  MarketEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.impactMultipliers,
    this.duration = 1,
  });

  static List<MarketEvent> getAllEvents() {
    return [
      // Positive Events
      MarketEvent(
        id: 'bull_run',
        name: 'Bull Run',
        description: 'Markets are soaring! Stocks and crypto surge.',
        emoji: '🚀',
        impactMultipliers: {
          AssetType.fixedDeposit: 1.0,
          AssetType.sip: 1.3,
          AssetType.stocks: 1.5,
          AssetType.crypto: 2.0,
        },
        duration: 2,
      ),
      MarketEvent(
        id: 'tech_boom',
        name: 'Tech Boom',
        description: 'Technology sector explodes! SIP and stocks benefit.',
        emoji: '💻',
        impactMultipliers: {
          AssetType.fixedDeposit: 1.0,
          AssetType.sip: 1.4,
          AssetType.stocks: 1.4,
          AssetType.crypto: 1.2,
        },
      ),
      MarketEvent(
        id: 'rate_cut',
        name: 'Interest Rate Cut',
        description: 'Central bank cuts rates. FD returns drop, markets rise.',
        emoji: '📉',
        impactMultipliers: {
          AssetType.fixedDeposit: 0.7,
          AssetType.sip: 1.2,
          AssetType.stocks: 1.3,
          AssetType.crypto: 1.1,
        },
      ),

      // Negative Events
      MarketEvent(
        id: 'market_crash',
        name: 'Market Crash',
        description: 'Markets plummet! Stocks and crypto hit hard.',
        emoji: '💥',
        impactMultipliers: {
          AssetType.fixedDeposit: 1.0,
          AssetType.sip: 0.6,
          AssetType.stocks: 0.4,
          AssetType.crypto: 0.3,
        },
        duration: 2,
      ),
      MarketEvent(
        id: 'crypto_winter',
        name: 'Crypto Winter',
        description: 'Crypto market freezes. Bitcoin drops 70%.',
        emoji: '❄️',
        impactMultipliers: {
          AssetType.fixedDeposit: 1.0,
          AssetType.sip: 0.95,
          AssetType.stocks: 0.9,
          AssetType.crypto: 0.2,
        },
        duration: 2,
      ),
      MarketEvent(
        id: 'recession',
        name: 'Economic Recession',
        description: 'Economy slows. All investments affected.',
        emoji: '📊',
        impactMultipliers: {
          AssetType.fixedDeposit: 0.9,
          AssetType.sip: 0.7,
          AssetType.stocks: 0.6,
          AssetType.crypto: 0.5,
        },
        duration: 2,
      ),

      // Neutral/Mixed Events
      MarketEvent(
        id: 'regulation',
        name: 'New Regulations',
        description: 'Government introduces new financial rules.',
        emoji: '⚖️',
        impactMultipliers: {
          AssetType.fixedDeposit: 1.1,
          AssetType.sip: 1.0,
          AssetType.stocks: 0.9,
          AssetType.crypto: 0.7,
        },
      ),
      MarketEvent(
        id: 'inflation_surge',
        name: 'Inflation Surge',
        description: 'Prices rising fast! Fixed deposits lose value.',
        emoji: '💸',
        impactMultipliers: {
          AssetType.fixedDeposit: 0.6,
          AssetType.sip: 0.9,
          AssetType.stocks: 1.1,
          AssetType.crypto: 1.3,
        },
      ),
    ];
  }

  static MarketEvent? getRandomEvent(DifficultyLevel difficulty, Random random) {
    final shouldTrigger = random.nextDouble() < difficulty.eventFrequency;
    if (!shouldTrigger) return null;

    final events = getAllEvents();
    return events[random.nextInt(events.length)];
  }
}

/// Represents a single asset allocation
class Asset {
  final AssetType type;
  double allocatedAmount;
  double currentValue;
  final List<double> valueHistory; // Track value over time

  Asset({
    required this.type,
    required this.allocatedAmount,
  })  : currentValue = allocatedAmount,
        valueHistory = [allocatedAmount];

  double get totalReturn => currentValue - allocatedAmount;
  double get returnPercentage =>
      allocatedAmount > 0 ? (totalReturn / allocatedAmount) * 100 : 0;

  void updateValue(double newValue) {
    currentValue = newValue;
    valueHistory.add(newValue);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'allocatedAmount': allocatedAmount,
      'currentValue': currentValue,
      'valueHistory': valueHistory,
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      type: AssetType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AssetType.fixedDeposit,
      ),
      allocatedAmount: json['allocatedAmount'] ?? 0.0,
    )
      ..currentValue = json['currentValue'] ?? 0.0
      ..valueHistory.addAll(
          (json['valueHistory'] as List?)?.cast<double>() ?? []);
  }
}

/// Represents the entire investment portfolio
class Portfolio {
  final Map<AssetType, Asset> assets;
  final int totalCapital;
  final int simulationYears;
  int currentYear;
  final DifficultyLevel difficulty;
  final List<MarketEvent> eventsOccurred;
  final List<double> totalValueHistory;

  Portfolio({
    required this.totalCapital,
    required this.simulationYears,
    required this.difficulty,
    Map<AssetType, double>? initialAllocations,
  })  : assets = {},
        currentYear = 0,
        eventsOccurred = [],
        totalValueHistory = [totalCapital.toDouble()] {
    // Initialize assets with allocations
    if (initialAllocations != null) {
      for (var entry in initialAllocations.entries) {
        if (entry.value > 0) {
          assets[entry.key] = Asset(
            type: entry.key,
            allocatedAmount: entry.value,
          );
        }
      }
    }
  }

  double get totalValue =>
      assets.values.fold(0.0, (sum, asset) => sum + asset.currentValue);

  double get totalReturn => totalValue - totalCapital;

  double get returnPercentage =>
      totalCapital > 0 ? (totalReturn / totalCapital) * 100 : 0;

  double get allocatedAmount =>
      assets.values.fold(0.0, (sum, asset) => sum + asset.allocatedAmount);

  double get unallocatedAmount => totalCapital - allocatedAmount;

  // Calculate risk score (0-100, higher = riskier)
  double get riskScore {
    if (assets.isEmpty) return 0;

    double weightedRisk = 0;
    for (var asset in assets.values) {
      final weight = asset.allocatedAmount / totalCapital;
      final assetRisk = asset.type.volatility * 100;
      weightedRisk += weight * assetRisk;
    }
    return weightedRisk.clamp(0, 100);
  }

  // Calculate diversification score (0-100, higher = better)
  double get diversificationScore {
    if (assets.isEmpty) return 0;
    if (assets.length == 1) return 25;

    // Calculate entropy-based diversification
    double entropy = 0;
    for (var asset in assets.values) {
      final proportion = asset.allocatedAmount / totalCapital;
      if (proportion > 0) {
        entropy -= proportion * (log(proportion) / ln2);
      }
    }

    // Normalize to 0-100 (max entropy for 4 assets is 2)
    return (entropy / 2) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCapital': totalCapital,
      'simulationYears': simulationYears,
      'currentYear': currentYear,
      'difficulty': difficulty.toString(),
      'assets': assets.map((key, value) => MapEntry(key.toString(), value.toJson())),
      'eventsOccurred': eventsOccurred.map((e) => e.id).toList(),
      'totalValueHistory': totalValueHistory,
    };
  }
}

/// Represents the final simulation result
class SimulationResult {
  final Portfolio portfolio;
  final int score;
  final int coinsEarned;
  final int xpEarned;
  final String performanceRating; // 'Excellent', 'Good', 'Average', 'Poor'
  final List<String> insights;

  SimulationResult({
    required this.portfolio,
    required this.score,
    required this.coinsEarned,
    required this.xpEarned,
    required this.performanceRating,
    required this.insights,
  });

  factory SimulationResult.calculate(Portfolio portfolio) {
    final returnPct = portfolio.returnPercentage;
    final riskScore = portfolio.riskScore;
    final diversification = portfolio.diversificationScore;

    // Calculate score (0-100)
    int score = 0;

    // Return component (50 points)
    if (returnPct > 80) {
      score += 50;
    } else if (returnPct > 50) {
      score += 40;
    } else if (returnPct > 30) {
      score += 30;
    } else if (returnPct > 15) {
      score += 20;
    } else if (returnPct > 0) {
      score += 10;
    }

    // Diversification component (30 points)
    score += (diversification * 0.3).toInt();

    // Risk management component (20 points)
    // Penalize extreme risk or zero risk
    if (riskScore > 20 && riskScore < 50) {
      score += 20; // Good balance
    } else if (riskScore >= 10 && riskScore <= 60) {
      score += 15;
    } else {
      score += 5;
    }

    score = score.clamp(0, 100);

    // Calculate rewards based on score
    int coinsEarned = 50 + (score ~/ 2); // 50-100 coins
    int xpEarned = 30 + score; // 30-130 XP

    // Determine performance rating
    String rating;
    if (score >= 80) {
      rating = 'Excellent';
      coinsEarned += 50; // Bonus
      xpEarned += 50;
    } else if (score >= 60) {
      rating = 'Good';
      coinsEarned += 25;
      xpEarned += 25;
    } else if (score >= 40) {
      rating = 'Average';
    } else {
      rating = 'Poor';
    }

    // Generate insights
    List<String> insights = [];

    if (returnPct > 50) {
      insights.add('Outstanding returns! Your portfolio grew significantly.');
    } else if (returnPct < 10) {
      insights.add('Returns were low. Consider riskier assets for better growth.');
    }

    if (diversification > 70) {
      insights.add('Excellent diversification! Risk is well-spread.');
    } else if (diversification < 30) {
      insights.add('Poor diversification. Spread investments across assets.');
    }

    if (riskScore > 60) {
      insights.add('Very risky portfolio! Consider safer investments.');
    } else if (riskScore < 15) {
      insights.add('Too conservative. Some risk can boost returns.');
    }

    if (portfolio.eventsOccurred.isNotEmpty) {
      insights.add('You faced ${portfolio.eventsOccurred.length} market event(s).');
    }

    return SimulationResult(
      portfolio: portfolio,
      score: score,
      coinsEarned: coinsEarned,
      xpEarned: xpEarned,
      performanceRating: rating,
      insights: insights,
    );
  }
}
