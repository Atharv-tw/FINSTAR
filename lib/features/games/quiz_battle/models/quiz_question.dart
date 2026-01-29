import 'dart:math';

enum QuizDifficulty {
  easy,
  medium,
  hard,
}

enum QuizCategory {
  budgeting,
  saving,
  investing,
  banking,
  taxes,
  credit,
  insurance,
  general,
}

enum AnswerOutcome {
  correct,
  wrong,
  skipped,
  timeout,
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final QuizDifficulty difficulty;
  final QuizCategory category;
  final String explanation;
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    required this.category,
    required this.explanation,
    required this.points,
  });

  String get correctAnswer => options[correctAnswerIndex];

  QuizQuestion shuffledOptions({Random? rng}) {
    final random = rng ?? Random();
    final indexed = List.generate(
      options.length,
      (index) => MapEntry(index, options[index]),
    );
    indexed.shuffle(random);

    final newOptions = indexed.map((e) => e.value).toList();
    final newCorrectIndex =
        indexed.indexWhere((e) => e.key == correctAnswerIndex);

    return QuizQuestion(
      id: id,
      question: question,
      options: newOptions,
      correctAnswerIndex: newCorrectIndex,
      difficulty: difficulty,
      category: category,
      explanation: explanation,
      points: points,
    );
  }

  static List<QuizQuestion> getAllQuestions() {
    return [
      // BUDGETING - Easy
      QuizQuestion(
        id: 'budget_1',
        question: 'What is the 50/30/20 budgeting rule?',
        options: [
          '50% needs, 30% wants, 20% savings',
          '50% savings, 30% needs, 20% wants',
          '50% wants, 30% needs, 20% savings',
          '50% needs, 30% savings, 20% wants',
        ],
        correctAnswerIndex: 0,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.budgeting,
        explanation: 'The 50/30/20 rule suggests 50% for needs (rent, food), 30% for wants (entertainment), and 20% for savings/investments.',
        points: 10,
      ),

      QuizQuestion(
        id: 'budget_2',
        question: 'Which of these is a "need" and NOT a "want"?',
        options: [
          'Netflix subscription',
          'Electricity bill',
          'New iPhone',
          'Concert tickets',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.budgeting,
        explanation: 'Needs are essential expenses required for survival and basic living. Electricity is necessary, while entertainment and luxury items are wants.',
        points: 10,
      ),

      QuizQuestion(
        id: 'budget_3',
        question: 'What should you do FIRST when creating a budget?',
        options: [
          'Start investing in stocks',
          'Track your income and expenses',
          'Buy insurance',
          'Open a savings account',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.budgeting,
        explanation: 'Before making any financial decisions, you need to know how much money is coming in and going out. Track everything for at least a month.',
        points: 10,
      ),

      // SAVING - Easy
      QuizQuestion(
        id: 'saving_1',
        question: 'What is an emergency fund?',
        options: [
          'Money for vacation trips',
          'Savings for unexpected expenses',
          'Investment in stocks',
          'Money for shopping',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.saving,
        explanation: 'An emergency fund is savings set aside for unexpected expenses like medical emergencies, job loss, or urgent repairs.',
        points: 10,
      ),

      QuizQuestion(
        id: 'saving_2',
        question: 'How many months of expenses should you save in an emergency fund?',
        options: [
          '1-2 months',
          '3-6 months',
          '12 months',
          'No specific amount needed',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.saving,
        explanation: 'Financial experts recommend saving 3-6 months of living expenses in an emergency fund to handle job loss or major unexpected costs.',
        points: 15,
      ),

      QuizQuestion(
        id: 'saving_3',
        question: 'Which savings strategy is most effective?',
        options: [
          'Save whatever is left at month-end',
          'Pay yourself first (save before spending)',
          'Save only during bonus months',
          'Save when you feel like it',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.saving,
        explanation: '"Pay yourself first" means setting aside savings as soon as you receive income, before spending on anything else. This builds consistent saving habits.',
        points: 10,
      ),

      // INVESTING - Medium
      QuizQuestion(
        id: 'invest_1',
        question: 'What does SIP stand for in investing?',
        options: [
          'Systematic Investment Plan',
          'Simple Interest Payment',
          'Stock Investment Portfolio',
          'Savings Interest Program',
        ],
        correctAnswerIndex: 0,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.investing,
        explanation: 'SIP (Systematic Investment Plan) allows you to invest a fixed amount regularly in mutual funds, helping build wealth through rupee cost averaging.',
        points: 10,
      ),

      QuizQuestion(
        id: 'invest_2',
        question: 'What is the relationship between risk and return in investing?',
        options: [
          'Higher risk = Lower return',
          'Higher risk = Higher potential return',
          'Risk and return are unrelated',
          'Lower risk = Higher return',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.investing,
        explanation: 'In investing, higher risk investments (like stocks) offer higher potential returns, while safer investments (like FDs) offer lower but more stable returns.',
        points: 15,
      ),

      QuizQuestion(
        id: 'invest_3',
        question: 'What is diversification in investing?',
        options: [
          'Investing all money in one stock',
          'Spreading investments across different assets',
          'Only investing in gold',
          'Keeping all money in savings account',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.investing,
        explanation: 'Diversification means spreading your money across different types of investments (stocks, bonds, gold, etc.) to reduce risk.',
        points: 15,
      ),

      QuizQuestion(
        id: 'invest_4',
        question: 'At what age can you start investing in India?',
        options: [
          '25 years',
          '21 years',
          '18 years',
          '16 years',
        ],
        correctAnswerIndex: 2,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.investing,
        explanation: 'In India, you can start investing in stocks, mutual funds, and other financial instruments once you turn 18 and are legally an adult.',
        points: 10,
      ),

      // BANKING - Easy
      QuizQuestion(
        id: 'bank_1',
        question: 'What is the difference between a Savings Account and Current Account?',
        options: [
          'No difference',
          'Savings earns interest, Current is for business',
          'Current earns more interest',
          'Savings is only for students',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.banking,
        explanation: 'Savings accounts earn interest and are for personal use. Current accounts are for businesses, have no interest, but allow unlimited transactions.',
        points: 15,
      ),

      QuizQuestion(
        id: 'bank_2',
        question: 'What does KYC stand for in banking?',
        options: [
          'Know Your Customer',
          'Keep Your Cash',
          'Key Yearly Calculation',
          'Kind Young Citizen',
        ],
        correctAnswerIndex: 0,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.banking,
        explanation: 'KYC (Know Your Customer) is a verification process banks use to confirm the identity of their customers to prevent fraud and money laundering.',
        points: 10,
      ),

      QuizQuestion(
        id: 'bank_3',
        question: 'What is a Fixed Deposit (FD)?',
        options: [
          'Money you can withdraw anytime',
          'Investment locked for fixed period with guaranteed returns',
          'A type of loan',
          'Free money from bank',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.banking,
        explanation: 'Fixed Deposit is a savings scheme where you deposit money for a fixed period (months/years) and earn guaranteed interest, higher than regular savings.',
        points: 10,
      ),

      // CREDIT & LOANS - Medium
      QuizQuestion(
        id: 'credit_1',
        question: 'What is a credit score?',
        options: [
          'Your bank balance',
          'Number measuring your creditworthiness (750-850 is good)',
          'Amount of credit cards you have',
          'Your monthly income',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.credit,
        explanation: 'Credit score (300-900 in India) reflects your creditworthiness. 750+ is excellent. It affects loan approvals and interest rates.',
        points: 15,
      ),

      QuizQuestion(
        id: 'credit_2',
        question: 'What happens if you only pay the minimum amount on your credit card?',
        options: [
          'You save money',
          'No consequences',
          'You pay high interest on remaining balance',
          'Your credit score improves',
        ],
        correctAnswerIndex: 2,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.credit,
        explanation: 'Paying only the minimum keeps you in debt longer and accumulates high interest (30-40% annually). Always pay full amount if possible.',
        points: 15,
      ),

      QuizQuestion(
        id: 'credit_3',
        question: 'What is EMI?',
        options: [
          'Extra Money Income',
          'Equated Monthly Installment',
          'Electronic Money Indicator',
          'Emergency Money Insurance',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.credit,
        explanation: 'EMI (Equated Monthly Installment) is a fixed payment you make every month to repay a loan, including both principal and interest.',
        points: 10,
      ),

      // TAXES - Hard
      QuizQuestion(
        id: 'tax_1',
        question: 'What is the income tax exemption limit for individuals in India (2024)?',
        options: [
          '₹2.5 lakh',
          '₹3 lakh',
          '₹5 lakh',
          '₹7 lakh',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.hard,
        category: QuizCategory.taxes,
        explanation: 'Under the new tax regime (2024), income up to ₹3 lakh is tax-free. Old regime offers ₹2.5 lakh exemption but with deductions.',
        points: 20,
      ),

      QuizQuestion(
        id: 'tax_2',
        question: 'What is TDS?',
        options: [
          'Total Debt System',
          'Tax Deducted at Source',
          'Time Deposit Savings',
          'Transaction Deduction Service',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.taxes,
        explanation: 'TDS (Tax Deducted at Source) means the payer deducts tax before paying you. Common in salaries, interest income, and freelance payments.',
        points: 15,
      ),

      QuizQuestion(
        id: 'tax_3',
        question: 'Which investment offers tax deduction under Section 80C?',
        options: [
          'Regular savings account',
          'PPF (Public Provident Fund)',
          'Cryptocurrency',
          'Gold jewelry',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.hard,
        category: QuizCategory.taxes,
        explanation: 'Section 80C allows tax deductions up to ₹1.5 lakh on investments like PPF, ELSS, life insurance, and home loan principal.',
        points: 20,
      ),

      // INSURANCE - Medium
      QuizQuestion(
        id: 'insurance_1',
        question: 'What is the primary purpose of health insurance?',
        options: [
          'To earn returns on investment',
          'To cover medical expenses',
          'To get tax benefits only',
          'To save money',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.insurance,
        explanation: 'Health insurance protects you from high medical costs. While it offers tax benefits, its main purpose is financial protection during illness.',
        points: 10,
      ),

      QuizQuestion(
        id: 'insurance_2',
        question: 'What is a premium in insurance?',
        options: [
          'The claim you make',
          'Amount you pay for insurance coverage',
          'Your age',
          'Bonus from insurance company',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.insurance,
        explanation: 'Premium is the amount you pay (monthly/yearly) to the insurance company to keep your insurance policy active.',
        points: 10,
      ),

      QuizQuestion(
        id: 'insurance_3',
        question: 'What is term life insurance?',
        options: [
          'Insurance with investment component',
          'Pure protection for a fixed term',
          'Health insurance',
          'Car insurance',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.insurance,
        explanation: 'Term insurance provides pure life cover for a specific period. If you die during the term, your family gets the sum assured. No maturity benefit.',
        points: 15,
      ),

      // GENERAL FINANCE - Mixed
      QuizQuestion(
        id: 'general_1',
        question: 'What is inflation?',
        options: [
          'When prices decrease',
          'When prices increase over time',
          'Interest on savings',
          'Stock market crash',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.general,
        explanation: 'Inflation is the rate at which prices of goods and services increase over time, reducing the purchasing power of money.',
        points: 10,
      ),

      QuizQuestion(
        id: 'general_2',
        question: 'What is compound interest?',
        options: [
          'Simple interest only',
          'Interest calculated on principal + accumulated interest',
          'Interest on loans',
          'Bank fees',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.general,
        explanation: 'Compound interest is "interest on interest." Your money grows faster because you earn interest on both your principal and previous interest.',
        points: 15,
      ),

      QuizQuestion(
        id: 'general_3',
        question: 'What does ROI stand for?',
        options: [
          'Rate of Income',
          'Return on Investment',
          'Risk or Interest',
          'Rapid Online Investment',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.general,
        explanation: 'ROI (Return on Investment) measures how much profit or loss you make on an investment relative to the amount invested.',
        points: 10,
      ),

      QuizQuestion(
        id: 'general_4',
        question: 'Which payment method offers buyer protection?',
        options: [
          'Cash',
          'Credit card',
          'Cryptocurrency',
          'Gold',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.medium,
        category: QuizCategory.general,
        explanation: 'Credit cards offer buyer protection, fraud protection, and chargeback options if products are defective or transactions are fraudulent.',
        points: 15,
      ),

      QuizQuestion(
        id: 'general_5',
        question: 'What is the Rule of 72?',
        options: [
          'Retirement age',
          'Formula to estimate investment doubling time',
          'Tax calculation method',
          'Credit score formula',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.hard,
        category: QuizCategory.general,
        explanation: 'Rule of 72: Divide 72 by your annual return rate to estimate how many years it takes to double your money. (72/8% = 9 years)',
        points: 20,
      ),

      QuizQuestion(
        id: 'general_6',
        question: 'What is liquidity in finance?',
        options: [
          'Amount of water in investments',
          'How easily an asset can be converted to cash',
          'Profit margin',
          'Stock market volatility',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.hard,
        category: QuizCategory.general,
        explanation: 'Liquidity refers to how quickly you can convert an asset to cash without losing value. Cash is most liquid; real estate is less liquid.',
        points: 20,
      ),

      QuizQuestion(
        id: 'invest_5',
        question: 'What is a mutual fund?',
        options: [
          'Direct stock purchase',
          'Pooled money from investors managed professionally',
          'Government savings scheme',
          'Fixed deposit',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.investing,
        explanation: 'A mutual fund pools money from many investors and is managed by professionals who invest in stocks, bonds, and other securities.',
        points: 10,
      ),

      QuizQuestion(
        id: 'invest_6',
        question: 'What is the stock market index that tracks top Indian companies?',
        options: [
          'DOW JONES',
          'NIFTY 50',
          'NASDAQ',
          'S&P 500',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.easy,
        category: QuizCategory.investing,
        explanation: 'NIFTY 50 is India\'s benchmark stock index tracking the top 50 companies on NSE. SENSEX tracks 30 companies on BSE.',
        points: 10,
      ),

      QuizQuestion(
        id: 'budget_4',
        question: 'What is lifestyle inflation?',
        options: [
          'Government increasing prices',
          'Spending more as income increases',
          'Saving more money',
          'Price of luxury goods rising',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.hard,
        category: QuizCategory.budgeting,
        explanation: 'Lifestyle inflation (lifestyle creep) happens when you increase spending as your income grows, preventing wealth accumulation.',
        points: 20,
      ),

      QuizQuestion(
        id: 'credit_4',
        question: 'What is a good debt-to-income ratio?',
        options: [
          '80% or higher',
          'Below 36%',
          '50-60%',
          'Above 100%',
        ],
        correctAnswerIndex: 1,
        difficulty: QuizDifficulty.hard,
        category: QuizCategory.credit,
        explanation: 'Debt-to-income ratio below 36% is healthy. It means your total monthly debt payments are less than 36% of your gross monthly income.',
        points: 20,
      ),
    ];
  }

  static final List<String> _recentQuestionIds = [];

  static List<QuizQuestion> getRandomQuestions({
    int count = 10,
    QuizDifficulty? difficulty,
    QuizCategory? category,
  }) {
    final random = Random();
    var questions = getAllQuestions();

    // Filter by difficulty if specified
    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }

    // Filter by category if specified
    if (category != null) {
      questions = questions.where((q) => q.category == category).toList();
    }

    // Shuffle and take requested count
    questions.shuffle(random);
    return questions
        .take(count)
        .map((q) => q.shuffledOptions(rng: random))
        .toList();
  }

  static List<QuizQuestion> getMixedDifficultyQuiz({int count = 10}) {
    final random = Random();
    var questions = getAllQuestions();
    questions.shuffle(random);

    // Avoid immediate repeats if possible
    final filtered = questions.where((q) => !_recentQuestionIds.contains(q.id)).toList();
    if (filtered.length >= count) {
      questions = filtered;
    }

    int easyCount = (count * 0.3).round();
    int hardCount = (count * 0.2).round();
    if (easyCount < 2) easyCount = 2;
    if (hardCount < 2) hardCount = 2;
    int mediumCount = count - easyCount - hardCount;
    if (mediumCount < 0) {
      mediumCount = 0;
      easyCount = count - hardCount;
    }

    final easy = questions
      .where((q) => q.difficulty == QuizDifficulty.easy)
      .toList()
      ..shuffle(random);
    final medium = questions
      .where((q) => q.difficulty == QuizDifficulty.medium)
      .toList()
      ..shuffle(random);
    final hard = questions
      .where((q) => q.difficulty == QuizDifficulty.hard)
      .toList()
      ..shuffle(random);

    final mixed = [
      ...easy.take(easyCount),
      ...medium.take(mediumCount),
      ...hard.take(hardCount),
    ];

    // Progression: easy -> medium -> hard
    final ordered = [...mixed];
    final result = ordered
        .take(count)
        .map((q) => q.shuffledOptions(rng: random))
        .toList();

    _recentQuestionIds.addAll(result.map((q) => q.id));
    if (_recentQuestionIds.length > 20) {
      _recentQuestionIds.removeRange(0, _recentQuestionIds.length - 20);
    }

    return result;
  }
}
