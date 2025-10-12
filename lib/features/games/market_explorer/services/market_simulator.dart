import 'dart:math';
import '../models/market_explorer_models.dart';

/// Market simulation engine that handles portfolio growth over time
class MarketSimulator {
  final Random _random;
  final DifficultyLevel difficulty;

  MarketSimulator({
    required this.difficulty,
    int? seed,
  }) : _random = Random(seed);

  /// Simulate one year of market activity for the portfolio
  SimulationYearResult simulateYear(
    Portfolio portfolio, {
    MarketEvent? forcedEvent,
  }) {
    portfolio.currentYear++;

    // Check for market event
    MarketEvent? event = forcedEvent ??
        MarketEvent.getRandomEvent(difficulty, _random);

    if (event != null) {
      portfolio.eventsOccurred.add(event);
    }

    // Update each asset
    Map<AssetType, double> yearReturns = {};

    for (var asset in portfolio.assets.values) {
      final returnRate = _calculateAssetReturn(
        asset.type,
        event,
      );

      final newValue = asset.currentValue * (1 + returnRate);
      asset.updateValue(newValue);
      yearReturns[asset.type] = returnRate * 100; // Convert to percentage
    }

    // Update portfolio history
    portfolio.totalValueHistory.add(portfolio.totalValue);

    return SimulationYearResult(
      year: portfolio.currentYear,
      event: event,
      assetReturns: yearReturns,
      portfolioValue: portfolio.totalValue,
      totalReturn: portfolio.returnPercentage,
    );
  }

  /// Calculate return for a specific asset type considering volatility and events
  double _calculateAssetReturn(
    AssetType assetType,
    MarketEvent? event,
  ) {
    // Start with base return rate
    double returnRate = assetType.baseReturnRate;

    // Apply random volatility (normal distribution)
    final volatilityFactor = _generateNormalRandom() * assetType.volatility;
    returnRate += volatilityFactor;

    // Apply market event impact if any
    if (event != null) {
      final eventMultiplier = event.impactMultipliers[assetType] ?? 1.0;
      returnRate *= eventMultiplier;
    }

    // Add difficulty-based variance
    final difficultyVariance = _getDifficultyVariance();
    returnRate += difficultyVariance;

    return returnRate;
  }

  /// Generate a random number following normal distribution (mean=0, std=1)
  double _generateNormalRandom() {
    // Box-Muller transform
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  /// Get difficulty-based variance
  double _getDifficultyVariance() {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 0.01 * (_random.nextDouble() - 0.5); // ±0.5%
      case DifficultyLevel.medium:
        return 0.02 * (_random.nextDouble() - 0.5); // ±1%
      case DifficultyLevel.hard:
        return 0.04 * (_random.nextDouble() - 0.5); // ±2%
    }
  }

  /// Simulate the entire investment period at once
  List<SimulationYearResult> simulateFull(Portfolio portfolio) {
    List<SimulationYearResult> results = [];

    for (int year = 1; year <= portfolio.simulationYears; year++) {
      final yearResult = simulateYear(portfolio);
      results.add(yearResult);
    }

    return results;
  }

  /// Rebalance portfolio by selling/buying assets
  RebalanceResult rebalancePortfolio(
    Portfolio portfolio,
    Map<AssetType, double> newAllocations,
  ) {
    // Calculate current asset percentages
    Map<AssetType, double> currentPercentages = {};
    for (var entry in portfolio.assets.entries) {
      currentPercentages[entry.key] =
          (entry.value.currentValue / portfolio.totalValue) * 100;
    }

    // Calculate what needs to be moved
    Map<AssetType, double> changes = {};
    double totalValue = portfolio.totalValue;

    for (var entry in newAllocations.entries) {
      final targetAmount = totalValue * (entry.value / 100);
      final currentAmount = portfolio.assets[entry.key]?.currentValue ?? 0;
      final change = targetAmount - currentAmount;

      if (change.abs() > 0.01) { // Ignore negligible changes
        changes[entry.key] = change;
      }
    }

    // Apply changes
    for (var entry in changes.entries) {
      if (entry.value > 0) {
        // Buying more of this asset
        if (portfolio.assets.containsKey(entry.key)) {
          portfolio.assets[entry.key]!.currentValue += entry.value;
          portfolio.assets[entry.key]!.allocatedAmount += entry.value;
        } else {
          portfolio.assets[entry.key] = Asset(
            type: entry.key,
            allocatedAmount: entry.value,
          );
        }
      } else {
        // Selling this asset
        if (portfolio.assets.containsKey(entry.key)) {
          portfolio.assets[entry.key]!.currentValue += entry.value; // entry.value is negative
          portfolio.assets[entry.key]!.allocatedAmount += entry.value;
        }
      }
    }

    return RebalanceResult(
      changes: changes,
      newPercentages: newAllocations,
      oldPercentages: currentPercentages,
    );
  }

  /// Generate market forecast hint (educational feature)
  MarketForecast generateForecast(AssetType assetType) {
    final baseReturn = assetType.baseReturnRate * 100;
    final volatility = assetType.volatility * 100;

    String outlook;
    String recommendation;

    // Generate semi-random outlook based on current "market conditions"
    final sentiment = _random.nextDouble();

    if (sentiment > 0.6) {
      outlook = 'Bullish';
      recommendation = 'Good time to invest in ${assetType.name}.';
    } else if (sentiment > 0.3) {
      outlook = 'Neutral';
      recommendation = 'Stable outlook for ${assetType.name}.';
    } else {
      outlook = 'Bearish';
      recommendation = 'Consider waiting or diversifying.';
    }

    return MarketForecast(
      assetType: assetType,
      expectedReturn: baseReturn,
      volatility: volatility,
      outlook: outlook,
      recommendation: recommendation,
    );
  }
}

/// Result of simulating one year
class SimulationYearResult {
  final int year;
  final MarketEvent? event;
  final Map<AssetType, double> assetReturns; // Percentage returns
  final double portfolioValue;
  final double totalReturn; // Total return since start

  SimulationYearResult({
    required this.year,
    this.event,
    required this.assetReturns,
    required this.portfolioValue,
    required this.totalReturn,
  });

  bool get hasEvent => event != null;

  String get eventDescription => event?.description ?? '';
}

/// Result of rebalancing portfolio
class RebalanceResult {
  final Map<AssetType, double> changes; // Amount changed for each asset
  final Map<AssetType, double> newPercentages;
  final Map<AssetType, double> oldPercentages;

  RebalanceResult({
    required this.changes,
    required this.newPercentages,
    required this.oldPercentages,
  });

  bool get hasChanges => changes.isNotEmpty;

  int get changesCount => changes.length;
}

/// Market forecast information
class MarketForecast {
  final AssetType assetType;
  final double expectedReturn; // Percentage
  final double volatility; // Percentage
  final String outlook; // 'Bullish', 'Bearish', 'Neutral'
  final String recommendation;

  MarketForecast({
    required this.assetType,
    required this.expectedReturn,
    required this.volatility,
    required this.outlook,
    required this.recommendation,
  });

  String get riskLevel {
    if (volatility < 10) return 'Low Risk';
    if (volatility < 30) return 'Medium Risk';
    return 'High Risk';
  }
}
