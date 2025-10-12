import 'package:flutter/material.dart';
import '../models/learning_module.dart';
import '../core/design_tokens.dart';

/// Sample data for all learning modules
class LearningModulesData {
  static final List<LearningModule> allModules = [
    _moneyBasicsModule,
    _earningCareerModule,
    _bankingModule,
    _investingModule,
  ];

  static LearningModule getModuleById(String id) {
    return allModules.firstWhere((module) => module.id == id);
  }

  // Money Basics Module
  static final LearningModule _moneyBasicsModule = LearningModule(
    id: 'money_basics',
    title: 'Money Basics',
    description: 'Learn the fundamental concepts of money, budgeting, and financial planning',
    iconPath: 'assets/images/money_basics_icon.png',
    gradientColors: [DesignTokens.primaryStart, DesignTokens.primaryEnd],
    totalXp: 500,
    lessons: [
      Lesson(
        id: 'mb_01',
        title: 'What is Money?',
        description: 'Understanding the concept and purpose of money in our lives',
        xpReward: 50,
        estimatedMinutes: 5,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Money is a medium of exchange that allows us to trade goods and services. It has three main functions: a medium of exchange, a store of value, and a unit of account.',
          ),
          LessonContent(
            type: ContentType.tip,
            data: 'Money itself has no value - its value comes from what we can exchange it for!',
          ),
          LessonContent(
            type: ContentType.text,
            data: 'Throughout history, humans have used many forms of money - from shells and beads to gold coins and paper currency. Today, we even use digital money!',
          ),
        ],
      ),
      Lesson(
        id: 'mb_02',
        title: 'Needs vs Wants',
        description: 'Learn to distinguish between essential needs and desires',
        xpReward: 50,
        estimatedMinutes: 5,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Needs are things essential for survival - food, water, shelter, clothing, and healthcare. Wants are things that make life more enjoyable but aren\'t essential.',
          ),
          LessonContent(
            type: ContentType.example,
            data: 'Need: Nutritious food to stay healthy\nWant: Eating at expensive restaurants every day',
          ),
          LessonContent(
            type: ContentType.tip,
            data: 'Before buying something, ask yourself: "Do I need this, or do I just want it?" This simple question can save you a lot of money!',
          ),
        ],
      ),
      Lesson(
        id: 'mb_03',
        title: 'Making a Budget',
        description: 'Create your first simple budget plan',
        xpReward: 75,
        estimatedMinutes: 8,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'A budget is a plan for your money. It helps you track income (money coming in) and expenses (money going out).',
          ),
          LessonContent(
            type: ContentType.text,
            data: 'The 50/30/20 rule is a simple budgeting method:\n• 50% for needs\n• 30% for wants\n• 20% for savings',
          ),
          LessonContent(
            type: ContentType.example,
            data: 'If you get \$100 allowance:\n• \$50 for needs (lunch, supplies)\n• \$30 for wants (games, snacks)\n• \$20 for savings',
          ),
        ],
      ),
      Lesson(
        id: 'mb_04',
        title: 'The Power of Saving',
        description: 'Why saving money is important and how to start',
        xpReward: 75,
        estimatedMinutes: 6,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Saving means setting aside money for future use. It helps you prepare for emergencies and achieve your goals.',
          ),
          LessonContent(
            type: ContentType.tip,
            data: 'Start small! Even saving \$1 a day adds up to \$365 in a year.',
          ),
        ],
      ),
      Lesson(
        id: 'mb_05',
        title: 'Smart Spending',
        description: 'How to make wise purchasing decisions',
        xpReward: 100,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Smart spending means getting the best value for your money. Compare prices, look for deals, and avoid impulse purchases.',
          ),
          LessonContent(
            type: ContentType.tip,
            data: 'Wait 24 hours before making a big purchase. This helps you avoid buying things you don\'t really need!',
          ),
        ],
      ),
    ],
  );

  // Earning & Career Module
  static final LearningModule _earningCareerModule = LearningModule(
    id: 'earning_career',
    title: 'Earning & Career',
    description: 'Discover different ways to earn money and build a successful career',
    iconPath: 'assets/images/earning_career_icon.png',
    gradientColors: [DesignTokens.secondaryStart, DesignTokens.secondaryEnd],
    totalXp: 600,
    lessons: [
      Lesson(
        id: 'ec_01',
        title: 'Ways to Earn Money',
        description: 'Explore different sources of income',
        xpReward: 50,
        estimatedMinutes: 6,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'There are many ways to earn money: jobs, freelancing, starting a business, investing, and more!',
          ),
          LessonContent(
            type: ContentType.example,
            data: 'As a student, you can earn by:\n• Tutoring classmates\n• Doing chores\n• Selling crafts online\n• Pet sitting',
          ),
        ],
      ),
      Lesson(
        id: 'ec_02',
        title: 'Building Skills',
        description: 'Why skills are important for your future career',
        xpReward: 75,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Skills make you valuable in the job market. The more skills you have, the more opportunities you\'ll get!',
          ),
        ],
      ),
    ],
  );

  // Banking & Institutes Module
  static final LearningModule _bankingModule = LearningModule(
    id: 'banking',
    title: 'Banking & Institutes',
    description: 'Learn about banks, financial institutions, and how they work',
    iconPath: 'assets/images/banking_icon.png',
    gradientColors: [DesignTokens.accentStart, DesignTokens.accentEnd],
    totalXp: 550,
    lessons: [
      Lesson(
        id: 'b_01',
        title: 'What is a Bank?',
        description: 'Understanding banks and their role in society',
        xpReward: 50,
        estimatedMinutes: 6,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'A bank is a financial institution that keeps your money safe and helps it grow through interest.',
          ),
          LessonContent(
            type: ContentType.text,
            data: 'Banks provide services like savings accounts, loans, debit cards, and online banking.',
          ),
        ],
      ),
      Lesson(
        id: 'b_02',
        title: 'Types of Accounts',
        description: 'Learn about savings and checking accounts',
        xpReward: 75,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Savings accounts help your money grow with interest. Checking accounts are for daily transactions.',
          ),
        ],
      ),
    ],
  );

  // Investing & Growth Module
  static final LearningModule _investingModule = LearningModule(
    id: 'investing',
    title: 'Investing & Growth',
    description: 'Introduction to investing and growing your wealth over time',
    iconPath: 'assets/images/investing_icon.png',
    gradientColors: [const Color(0xFFFF6B9D), const Color(0xFFC06C84)],
    totalXp: 700,
    lessons: [
      Lesson(
        id: 'i_01',
        title: 'What is Investing?',
        description: 'Learn the basics of making your money grow',
        xpReward: 75,
        estimatedMinutes: 8,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Investing means putting your money to work to earn more money over time. It\'s different from saving - you\'re taking calculated risks for higher rewards.',
          ),
          LessonContent(
            type: ContentType.tip,
            data: 'The earlier you start investing, the more time your money has to grow!',
          ),
        ],
      ),
      Lesson(
        id: 'i_02',
        title: 'Types of Investments',
        description: 'Stocks, bonds, and other investment options',
        xpReward: 100,
        estimatedMinutes: 10,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: 'Common investments include stocks (owning part of a company), bonds (lending money), and mutual funds (pooled investments).',
          ),
        ],
      ),
    ],
  );
}
