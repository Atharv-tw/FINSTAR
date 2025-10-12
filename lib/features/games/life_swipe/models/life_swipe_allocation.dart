class BudgetAllocation {
  double needs;
  double wants;
  double savings;
  double investments;

  BudgetAllocation({
    this.needs = 0,
    this.wants = 0,
    this.savings = 0,
    this.investments = 0,
  });

  double get total => needs + wants + savings + investments;

  bool isComplete(double totalBudget) => total == totalBudget;

  // Calculate score based on 50/30/20 rule (modified for 4 categories)
  // Ideal: Needs 50%, Wants 30%, Savings 15%, Investments 5%
  int calculateScore(double totalBudget) {
    if (total != totalBudget) return 0;

    final needsPercent = (needs / totalBudget) * 100;
    final wantsPercent = (wants / totalBudget) * 100;
    final savingsPercent = (savings / totalBudget) * 100;
    final investmentsPercent = (investments / totalBudget) * 100;

    // Calculate deviation from ideal percentages
    double needsScore = 100 - ((needsPercent - 50).abs() * 2);
    double wantsScore = 100 - ((wantsPercent - 30).abs() * 2);
    double savingsScore = 100 - ((savingsPercent - 15).abs() * 4);
    double investmentsScore = 100 - ((investmentsPercent - 5).abs() * 4);

    // Weighted average
    double totalScore = (needsScore * 0.4) +
        (wantsScore * 0.3) +
        (savingsScore * 0.2) +
        (investmentsScore * 0.1);

    return totalScore.clamp(0, 100).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'needs': needs,
      'wants': wants,
      'savings': savings,
      'investments': investments,
    };
  }

  factory BudgetAllocation.fromJson(Map<String, dynamic> json) {
    return BudgetAllocation(
      needs: (json['needs'] ?? 0).toDouble(),
      wants: (json['wants'] ?? 0).toDouble(),
      savings: (json['savings'] ?? 0).toDouble(),
      investments: (json['investments'] ?? 0).toDouble(),
    );
  }

  BudgetAllocation copyWith({
    double? needs,
    double? wants,
    double? savings,
    double? investments,
  }) {
    return BudgetAllocation(
      needs: needs ?? this.needs,
      wants: wants ?? this.wants,
      savings: savings ?? this.savings,
      investments: investments ?? this.investments,
    );
  }
}
