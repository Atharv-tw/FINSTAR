import 'package:flutter/material.dart';
import '../models/learning_module.dart';
import '../core/design_tokens.dart';

/// Complete learning modules data for FINSTAR - Teaching Financial Literacy to Teens
class LearningModulesData {
  static final List<LearningModule> allModules = [
    _moneyBasicsModule,
    _bankingModule,
    _earningCareerModule,
    _investingModule,
    _socialFinanceModule,
  ];

  static LearningModule getModuleById(String id) {
    return allModules.firstWhere((module) => module.id == id);
  }

  // 🧠 1. MONEY BASICS MODULE
  static final LearningModule _moneyBasicsModule = LearningModule(
    id: 'money_basics',
    title: '🧠 Money Basics',
    description: 'Master the fundamentals: budgeting, saving, and smart money moves',
    iconPath: 'assets/images/money_basics_icon.png',
    gradientColors: [DesignTokens.primaryStart, DesignTokens.primaryEnd],
    totalXp: 800,
    lessons: [
      // Budgeting
      Lesson(
        id: 'mb_01',
        title: 'Budgeting 101',
        description: 'Your money roadmap - plan where every rupee goes',
        xpReward: 50,
        estimatedMinutes: 5,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '💰 What\'s a Budget?\n\nA budget is like a GPS for your money - it shows you exactly where it\'s going! Think of it as your monthly money plan.',
          ),
          LessonContent(
            type: ContentType.example,
            data: '📱 Real Life: Got ₹5,000 pocket money?\n• Food & transport: ₹2,500\n• Fun stuff: ₹1,500\n• Savings: ₹1,000\n\nThat\'s budgeting!',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '✨ Pro Tip: Apps help! Try tracking your spending for just one week - you\'ll be surprised where your money goes.',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🎯 Why Budget?\n\n• Never run out of money mid-month\n• Achieve goals faster (that gaming console!)\n• Less money stress = more peace',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '', // data is not used for quiz
            quizQuestions: [
              QuizQuestion(
                question: 'What is the main purpose of a budget?',
                options: [
                  'To restrict all your spending',
                  'To track where your money is going',
                  'To earn more money',
                  'To invest in the stock market',
                ],
                correctAnswer: 1,
                explanation: 'A budget is a plan that helps you track your income and expenses. It gives you a clear picture of where your money is going.',
              ),
              QuizQuestion(
                question: 'According to the 50/30/20 rule, what does the 20% represent?',
                options: [
                  'Wants',
                  'Needs',
                  'Savings',
                  'Taxes',
                ],
                correctAnswer: 2,
                explanation: 'The 50/30/20 rule suggests allocating 50% of your income to needs, 30% to wants, and 20% to savings.',
              ),
              QuizQuestion(
                question: 'Which of these is a "want" rather than a "need"?',
                options: [
                  'Groceries',
                  'Rent',
                  'A new video game',
                  'Electricity bill',
                ],
                correctAnswer: 2,
                explanation: 'Wants are things you would like to have but are not essential for survival. A new video game is a want, while groceries, rent, and electricity are needs.',
              ),
            ],
          ),
        ],
      ),

      // Saving
      Lesson(
        id: 'mb_02',
        title: 'The Saving Superpower',
        description: 'Build your money safety net and future fund',
        xpReward: 50,
        estimatedMinutes: 5,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🏦 What is Saving?\n\nSaving = putting money aside for later. It\'s your financial safety net AND your dream-achiever!',
          ),
          LessonContent(
            type: ContentType.example,
            data: '💪 The Coffee Math:\n\n₹50 coffee daily = ₹1,500/month = ₹18,000/year\n\nMake it at home? Save enough for a new phone! 📱',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🚀 Start Small Challenge: Save ₹10 daily. In a year, you\'ll have ₹3,650! Even small amounts add up BIG.',
          ),
          LessonContent(
            type: ContentType.text,
            data: '✨ Benefits:\n• Emergency backup (phone broke? covered!)\n• Makes dreams possible\n• Reduces anxiety\n• Opens opportunities',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the primary benefit of saving money?',
                options: [
                  'To buy more things immediately.',
                  'To create a safety net for emergencies and achieve future goals.',
                  'To show off to friends.',
                  'To get rid of all your money.',
                ],
                correctAnswer: 1,
                explanation: 'Saving helps you prepare for unexpected expenses and work towards your long-term dreams.',
              ),
              QuizQuestion(
                question: 'Based on "The Coffee Math," what does saving a small amount daily help you realize?',
                options: [
                  'That small expenses don\'t matter.',
                  'That daily habits have a big impact on your savings over time.',
                  'That you should never buy coffee.',
                  'That saving is impossible.',
                ],
                correctAnswer: 1,
                explanation: 'The example shows how a small daily expense of ₹50 adds up to a significant amount (₹18,000) over a year, highlighting the power of daily saving habits.',
              ),
              QuizQuestion(
                question: 'What is the key message of the "Start Small Challenge"?',
                options: [
                  'You need a lot of money to start saving.',
                  'Saving small, consistent amounts is ineffective.',
                  'Even saving a small amount like ₹10 daily can lead to a large sum over time.',
                  'You should only save once a year.',
                ],
                correctAnswer: 2,
                explanation: 'The challenge demonstrates that consistency is key. Saving just ₹10 every day results in ₹3,650 in a year, proving that small, regular efforts build substantial savings.',
              ),
            ],
          ),
        ],
      ),

      // Building a Budget
      Lesson(
        id: 'mb_03',
        title: 'Build Your First Budget',
        description: 'Create a budget that actually works for YOU',
        xpReward: 75,
        estimatedMinutes: 7,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '📊 The 50/30/20 Rule\n\nSuper simple formula that works:\n\n50% = Needs (must-haves)\n30% = Wants (nice-to-haves)\n20% = Savings (future you)',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🎮 With ₹10,000 monthly:\n\n• ₹5,000: Needs (lunch, transport, supplies)\n• ₹3,000: Wants (movies, gaming, snacks)\n• ₹2,000: Savings (for that laptop!)',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '💡 Budget Hack: Pay yourself first! Transfer savings the moment you get money - what\'s left is for spending.',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🛠️ Tools to Use:\n• Notebook & pen (classic!)\n• Spreadsheet (Google Sheets)\n• Apps (YNAB, Mint, Walnut)\n\nPick what feels easiest!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'In the 50/30/20 rule, what does the 30% represent?',
                options: [
                  'Needs',
                  'Wants',
                  'Savings',
                  'Gifts',
                ],
                correctAnswer: 1,
                explanation: 'The 30% in the 50/30/20 rule is allocated to "Wants," which are things you\'d like to have but are not essential.',
              ),
              QuizQuestion(
                question: 'What is the "Pay Yourself First" hack?',
                options: [
                  'Spending all your money on yourself first.',
                  'Transferring money to your savings account as soon as you get paid.',
                  'Paying your bills before anything else.',
                  'Buying whatever you want first.',
                ],
                correctAnswer: 1,
                explanation: '"Pay Yourself First" is a saving strategy where you prioritize your savings goals by putting money aside before you start spending on other things.',
              ),
              QuizQuestion(
                question: 'If your monthly income is ₹10,000, how much should you allocate to "Needs" according to the 50/30/20 rule?',
                options: [
                  '₹2,000',
                  '₹3,000',
                  '₹5,000',
                  '₹10,000',
                ],
                correctAnswer: 2,
                explanation: 'According to the rule, 50% of your income should go to "Needs". 50% of ₹10,000 is ₹5,000.',
              ),
            ],
          ),
        ],
      ),

      // Financial Goals
      Lesson(
        id: 'mb_04',
        title: 'Set & Smash Financial Goals',
        description: 'Turn money dreams into reality with SMART goals',
        xpReward: 75,
        estimatedMinutes: 6,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🎯 What are Financial Goals?\n\nThings you want to buy or achieve with money. Having clear goals makes saving 100x easier!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '✨ SMART Goals Formula:\n\nSpecific: "New laptop"\nMeasurable: "₹50,000"\nAchievable: "Save ₹5,000/month"\nRelevant: "For college"\nTime-bound: "In 10 months"',
          ),
          LessonContent(
            type: ContentType.example,
            data: '📝 Goal Types:\n\nShort-term (1-12 months):\n• New phone\n• Concert tickets\n• Gaming console\n\nLong-term (1+ years):\n• College fund\n• First car\n• Starting a business',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🔥 Motivation Trick: Put a pic of your goal as your phone wallpaper. Every time you\'re tempted to spend, you\'ll see what you\'re saving for!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What does the \'M\' in SMART goals stand for?',
                options: [
                  'Money',
                  'Monthly',
                  'Measurable',
                  'Motivational',
                ],
                correctAnswer: 2,
                explanation: 'The \'M\' in SMART goals stands for Measurable, which means you should be able to track your progress.',
              ),
              QuizQuestion(
                question: 'Which of the following is a long-term financial goal?',
                options: [
                  'Buying concert tickets for next month.',
                  'Saving for a new phone over 6 months.',
                  'Building a college fund over 5 years.',
                  'Buying a new video game.',
                ],
                correctAnswer: 2,
                explanation: 'Long-term goals, like a college fund, typically take more than a year to achieve.',
              ),
              QuizQuestion(
                question: 'What is the "Motivation Trick" suggested in the lesson?',
                options: [
                  'Telling all your friends about your goal.',
                  'Putting a picture of your goal as your phone wallpaper.',
                  'Writing your goal down 100 times.',
                  'Never thinking about your goal.',
                ],
                correctAnswer: 1,
                explanation: 'Visualizing your goal, for example, by setting it as your wallpaper, can be a powerful motivator to stay on track with your savings.',
              ),
            ],
          ),
        ],
      ),

      // Managing Debt
      Lesson(
        id: 'mb_05',
        title: 'Managing Debt Like a Boss',
        description: 'Handle borrowed money without getting trapped',
        xpReward: 100,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '⚠️ What is Debt?\n\nDebt = money you borrowed and need to pay back (usually with interest). It\'s like a financial boomerang!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '😈 The Debt Trap:\n\nBorrow ₹10,000 at 18% interest\nOnly pay minimum each month?\nYou\'ll pay ₹3,000+ extra!\n\nTime to repay: 2+ YEARS 😱',
          ),
          LessonContent(
            type: ContentType.example,
            data: '✅ Good Debt vs ❌ Bad Debt\n\nGood:\n• Education loan (increases earning)\n• Business loan (builds wealth)\n\nBad:\n• Credit card shopping sprees\n• Loans for depreciating items',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🛡️ Golden Rules:\n\n1. Borrow only if NECESSARY\n2. Pay more than minimum\n3. High-interest debts first\n4. Never borrow for wants',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is considered "bad debt"?',
                options: [
                  'A loan for a college education.',
                  'A loan to start a business.',
                  'A loan for a shopping spree.',
                  'A loan to buy a house.',
                ],
                correctAnswer: 2,
                explanation: '"Bad debt" is typically used for things that don\'t increase in value or generate income, like a shopping spree.',
              ),
              QuizQuestion(
                question: 'What is one of the "Golden Rules" for managing debt?',
                options: [
                  'Always pay only the minimum amount.',
                  'Borrow for wants, not needs.',
                  'Pay more than the minimum payment.',
                  'Ignore high-interest debts.',
                ],
                correctAnswer: 2,
                explanation: 'Paying more than the minimum helps you pay off your debt faster and save money on interest.',
              ),
              QuizQuestion(
                question: 'What is the "Debt Trap"?',
                options: [
                  'Getting a loan with a very low interest rate.',
                  'Paying off your debt very quickly.',
                  'Only paying the minimum amount and accumulating a lot of interest.',
                  'Never borrowing money.',
                ],
                correctAnswer: 2,
                explanation: 'The "Debt Trap" occurs when you only make minimum payments, which extends the repayment period and significantly increases the total amount of interest you pay.',
              ),
            ],
          ),
        ],
      ),

      // Managing Credit
      Lesson(
        id: 'mb_06',
        title: 'Credit: Your Financial Reputation',
        description: 'Build credit power for your future self',
        xpReward: 100,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '💳 What is Credit?\n\nCredit = borrowing power. It\'s your promise to pay back money you borrow. Handle it well, and doors open!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🌟 Why Credit Matters:\n\n• Easier to get loans\n• Lower interest rates (save thousands!)\n• Rent apartments\n• Get better credit cards\n• Some jobs check it!',
          ),
          LessonContent(
            type: ContentType.example,
            data: '📱 Real Example:\n\nGood credit = ₹5L car loan at 8%\nBad credit = same loan at 14%\n\nDifference? You pay ₹80,000 MORE with bad credit! 💸',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '✨ Credit Card Hack: Use it like a debit card. Buy only what you can afford. Pay FULL bill every month. Free credit building!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is credit?',
                options: [
                  'The amount of money you have in your bank account.',
                  'Your borrowing power and promise to pay back money.',
                  'A type of savings account.',
                  'A government tax.',
                ],
                correctAnswer: 1,
                explanation: 'Credit is your financial reputation and your ability to borrow money with the promise to repay it.',
              ),
              QuizQuestion(
                question: 'Why is having good credit important?',
                options: [
                  'It allows you to spend more money than you have.',
                  'It makes it easier to get loans with lower interest rates.',
                  'It\'s not important for your financial future.',
                  'It automatically makes you rich.',
                ],
                correctAnswer: 1,
                explanation: 'Good credit is crucial for getting favorable loan terms, which can save you a lot of money in the long run.',
              ),
              QuizQuestion(
                question: 'What is the "Credit Card Hack" mentioned in the lesson?',
                options: [
                  'Maxing out your credit card every month.',
                  'Never using your credit card.',
                  'Using your credit card like a debit card and paying the full bill monthly.',
                  'Only paying the minimum amount due on your credit card.',
                ],
                correctAnswer: 2,
                explanation: 'The hack involves using your credit card for purchases you can afford and paying it off in full each month to build credit without paying interest.',
              ),
            ],
          ),
        ],
      ),

      // Credit Score
      Lesson(
        id: 'mb_07',
        title: 'Your Credit Score Explained',
        description: 'The magic number that affects your financial life',
        xpReward: 100,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🔢 What\'s a Credit Score?\n\nA 3-digit number (300-900) that\'s basically your "financial report card". Higher = better!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '📊 Score Ranges:\n\n750-900: Excellent 🌟\n700-749: Good 👍\n650-699: Fair 😐\n600-649: Poor 😟\nBelow 600: Very Poor 🚨',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🎯 What Affects Your Score:\n\n35% - Payment history (pay on time!)\n30% - Amount owed (use <30% of limit)\n15% - Credit history length\n10% - New credit\n10% - Credit mix',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '💪 Build Credit as a Teen:\n\n• Become authorized user on parent\'s card\n• Get secured credit card\n• Pay phone bill on time\n• Check score regularly (it\'s FREE!)',
          ),
          LessonContent(
            type: ContentType.text,
            data: '⚡ Credit Score Hacks:\n\n1. Set autopay for bills\n2. Keep credit usage under 30%\n3. Don\'t close old cards\n4. Limit new credit applications\n5. Check for errors regularly',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the typical range for a credit score?',
                options: [
                  '0-100',
                  '100-500',
                  '300-900',
                  '500-1000',
                ],
                correctAnswer: 2,
                explanation: 'Credit scores in India typically range from 300 to 900.',
              ),
              QuizQuestion(
                question: 'What is the most important factor that affects your credit score?',
                options: [
                  'Credit history length',
                  'Payment history',
                  'New credit',
                  'Credit mix',
                ],
                correctAnswer: 1,
                explanation: 'Payment history is the most significant factor, accounting for 35% of your credit score.',
              ),
              QuizQuestion(
                question: 'Which of the following is a good way to build credit as a teen?',
                options: [
                  'Applying for many credit cards at once.',
                  'Never checking your credit score.',
                  'Becoming an authorized user on a parent\'s credit card.',
                  'Closing old credit cards.',
                ],
                correctAnswer: 2,
                explanation: 'Becoming an authorized user is a great way to start building a positive credit history.',
              ),
            ],
          ),
        ],
      ),

      // Risk Management
      Lesson(
        id: 'mb_08',
        title: 'Risk Management 101',
        description: 'Protect your money from unexpected disasters',
        xpReward: 125,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🛡️ What is Risk Management?\n\nProtecting yourself from financial disasters. Life throws curveballs - be ready!',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🌪️ Real Life Risks:\n\n• Phone breaks (₹20,000)\n• Medical emergency (₹50,000+)\n• Job loss\n• Accidents\n• Natural disasters',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🎯 Protection Strategies:\n\n1. Emergency Fund (3-6 months expenses)\n2. Insurance (health, life, property)\n3. Diversify income sources\n4. Backup important data\n5. Learn valuable skills',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '💰 Emergency Fund Goal:\n\nStart: ₹10,000\nBeginner: ₹50,000\nIdeal: 3-6 months of expenses\n\nBuild it slowly but consistently!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the primary purpose of risk management?',
                options: [
                  'To get rich quick.',
                  'To protect yourself from financial disasters.',
                  'To avoid paying taxes.',
                  'To spend all your money.',
                ],
                correctAnswer: 1,
                explanation: 'Risk management is about creating a safety net to handle unexpected financial shocks.',
              ),
              QuizQuestion(
                question: 'Which of the following is a key protection strategy against financial risk?',
                options: [
                  'Putting all your money in one investment.',
                  'Having an emergency fund.',
                  'Ignoring insurance.',
                  'Spending more than you earn.',
                ],
                correctAnswer: 1,
                explanation: 'An emergency fund is a crucial buffer to cover unexpected costs without going into debt.',
              ),
              QuizQuestion(
                question: 'What is the ideal size of an emergency fund?',
                options: [
                  'One week\'s worth of expenses.',
                  'One month\'s worth of expenses.',
                  '3-6 months\' worth of expenses.',
                  'One year\'s worth of expenses.',
                ],
                correctAnswer: 2,
                explanation: 'A fully-funded emergency fund should ideally cover 3 to 6 months of your essential living expenses.',
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // 💼 2. BANKING & INSTITUTIONS MODULE
  static final LearningModule _bankingModule = LearningModule(
    id: 'banking',
    title: '💼 Banking & Institutions',
    description: 'Navigate banks, loans, and financial institutions like a pro',
    iconPath: 'assets/images/banking_final_v2.jpg',
    gradientColors: [DesignTokens.accentStart, DesignTokens.accentEnd],
    totalXp: 650,
    lessons: [
      // Bank
      Lesson(
        id: 'b_01',
        title: 'Banks: Your Money\'s Safe House',
        description: 'What banks do and why you need them',
        xpReward: 50,
        estimatedMinutes: 6,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🏦 What is a Bank?\n\nA bank is like a super-secure vault that:\n• Keeps your money safe\n• Helps it grow\n• Lets you pay & receive money\n• Lends money when you need it',
          ),
          LessonContent(
            type: ContentType.text,
            data: '✨ Bank Services:\n\n💰 Savings Account - Store money & earn interest\n💳 Debit Card - Spend your money easily\n📱 Mobile Banking - Bank from anywhere\n🏠 Loans - Borrow for big purchases\n💵 Currency Exchange - Travel abroad',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🎯 Real Life:\n\nDeposit ₹10,000 in savings account\nBank pays 4% interest yearly\nAfter 1 year: ₹10,400\n\nFree ₹400! 💰',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🚀 Teen Tip: Open a savings account NOW! Many banks offer zero-balance accounts for students. Start building that financial identity!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is one of the primary functions of a bank?',
                options: [
                  'To give away money for free.',
                  'To keep your money safe and help it grow.',
                  'To print money.',
                  'To only provide loans.',
                ],
                correctAnswer: 1,
                explanation: 'Banks are primarily institutions for securely storing money and facilitating its growth through services like savings accounts.',
              ),
              QuizQuestion(
                question: 'What is a debit card used for?',
                options: [
                  'Borrowing money from the bank.',
                  'Spending your own money from your bank account.',
                  'Getting a discount on all purchases.',
                  'Earning interest.',
                ],
                correctAnswer: 1,
                explanation: 'A debit card is directly linked to your bank account and allows you to spend the money you already have.',
              ),
              QuizQuestion(
                question: 'What does the "Teen Tip" in the lesson recommend?',
                options: [
                  'Waiting until you are 30 to open a bank account.',
                  'Opening a savings account as a student.',
                  'Keeping all your money at home.',
                  'Never using a bank.',
                ],
                correctAnswer: 1,
                explanation: 'The lesson advises teens to open a savings account early to start building their financial identity and habits.',
              ),
            ],
          ),
        ],
      ),

      // Loans
      Lesson(
        id: 'b_02',
        title: 'Loans: Borrowing Smart',
        description: 'How loans work and when to use them',
        xpReward: 75,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '📋 What is a Loan?\n\nMoney borrowed from a bank that you pay back over time + interest. Think of it as renting money!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🎓 Common Loan Types:\n\nEducation Loan - For college\nCar Loan - For vehicle\nHome Loan - For house\nPersonal Loan - For anything\nBusiness Loan - Start a business',
          ),
          LessonContent(
            type: ContentType.example,
            data: '💡 Loan Math:\n\nBorrow: ₹1,00,000\nInterest: 10% yearly\nTime: 2 years\n\nTotal repay: ₹1,20,000\nYour cost: ₹20,000\n\nInterest is the "rent" you pay!',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '⚠️ Before Taking a Loan:\n\n✅ Do I REALLY need it?\n✅ Can I afford monthly payments?\n✅ What\'s the interest rate?\n✅ What if I can\'t pay?\n✅ Are there cheaper options?',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is interest on a loan?',
                options: [
                  'The total amount of money you borrow.',
                  'The extra money you pay to the bank for borrowing money.',
                  'A discount on the loan.',
                  'The principal amount.',
                ],
                correctAnswer: 1,
                explanation: 'Interest is the cost of borrowing money, often referred to as the "rent" you pay for using the bank\'s money.',
              ),
              QuizQuestion(
                question: 'Which of the following is NOT a common type of loan?',
                options: [
                  'Education Loan',
                  'Car Loan',
                  'Vacation Loan',
                  'Personal Loan',
                ],
                correctAnswer: 2,
                explanation: 'While you could use a personal loan for a vacation, a "Vacation Loan" is not a standard category of loan offered by banks.',
              ),
              QuizQuestion(
                question: 'What is an important question to ask yourself before taking a loan?',
                options: [
                  'What will my friends think?',
                  'Can I afford the monthly payments?',
                  'What is the most expensive loan I can get?',
                  'Can I pay it back whenever I want?',
                ],
                correctAnswer: 1,
                explanation: 'Ensuring you can comfortably afford the monthly payments is a critical step to avoid financial trouble.',
              ),
            ],
          ),
        ],
      ),

      // Borrowing
      Lesson(
        id: 'b_03',
        title: 'Borrowing 101',
        description: 'The art of borrowing without drowning in debt',
        xpReward: 75,
        estimatedMinutes: 6,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🤝 What is Borrowing?\n\nGetting money temporarily with a promise to return it. Could be from banks, friends, or family.',
          ),
          LessonContent(
            type: ContentType.text,
            data: '✨ Smart Borrowing Rules:\n\n1. Borrow only for needs/investments\n2. Have a clear repayment plan\n3. Compare interest rates\n4. Read ALL terms & conditions\n5. Never borrow to show off',
          ),
          LessonContent(
            type: ContentType.example,
            data: '😊 Good Reasons:\n• Education that increases income\n• Starting a profitable business\n• Medical emergency\n\n😞 Bad Reasons:\n• Latest iPhone to flex\n• Party at expensive club\n• Impulse shopping',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🎯 Borrowing from Friends/Family?\n\nTreat it MORE seriously than bank loans. Broken promises break relationships! Always:\n• Write it down\n• Set clear terms\n• Pay on time',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'Which of the following is a "Smart Borrowing Rule"?',
                options: [
                  'Borrowing to show off to your friends.',
                  'Having a clear repayment plan.',
                  'Ignoring the terms and conditions.',
                  'Borrowing for impulse shopping.',
                ],
                correctAnswer: 1,
                explanation: 'Having a clear plan to repay the borrowed money is a fundamental rule of smart borrowing.',
              ),
              QuizQuestion(
                question: 'According to the lesson, which of these is a "Good Reason" to borrow money?',
                options: [
                  'To buy the latest iPhone.',
                  'To fund an education that will increase your income.',
                  'To throw a lavish party.',
                  'To go on a vacation.',
                ],
                correctAnswer: 1,
                explanation: 'Borrowing for an education that can improve your earning potential is considered a good investment.',
              ),
              QuizQuestion(
                question: 'What is the lesson\'s advice about borrowing from friends or family?',
                options: [
                  'It\'s less serious than borrowing from a bank.',
                  'You don\'t need to pay it back.',
                  'You should treat it more seriously than a bank loan and have clear terms.',
                  'You should avoid it at all costs.',
                ],
                correctAnswer: 2,
                explanation: 'The lesson emphasizes treating loans from friends and family with extra seriousness to protect your relationships.',
              ),
            ],
          ),
        ],
      ),

      // Banking & Financial Institutions
      Lesson(
        id: 'b_04',
        title: 'Financial Institutions Explained',
        description: 'Different types and what they do',
        xpReward: 100,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🏛️ Types of Financial Institutions:\n\n🏦 Commercial Banks - Regular banking\n🤝 Credit Unions - Member-owned banks\n💰 Investment Banks - Big money moves\n🛡️ Insurance Companies - Risk protection\n📈 NBFCs - Non-bank lenders',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🎯 When to Use What:\n\nDaily banking → Commercial Bank\nLower fees → Credit Union\nInsurance → Insurance Company\nQuick loan → NBFC\nInvesting → Brokerage',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '⚡ Choose Wisely:\n\n• Check fees & charges\n• Read reviews\n• Compare interest rates\n• Look for student benefits\n• Ensure it\'s RBI registered!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '✨ Benefits:\n\n• Professional money management\n• Security & insurance\n• Financial education resources\n• Build credit history\n• Access to expert advice',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'Which type of financial institution is best for daily banking needs?',
                options: [
                  'Investment Bank',
                  'Insurance Company',
                  'Commercial Bank',
                  'NBFC',
                ],
                correctAnswer: 2,
                explanation: 'Commercial banks are the primary institutions for everyday banking services like savings accounts and debit cards.',
              ),
              QuizQuestion(
                question: 'If you are looking for lower fees and a more member-focused experience, which institution might you choose?',
                options: [
                  'Credit Union',
                  'Investment Bank',
                  'Commercial Bank',
                  'Insurance Company',
                ],
                correctAnswer: 0,
                explanation: 'Credit unions are member-owned and often offer lower fees and better rates than commercial banks.',
              ),
              QuizQuestion(
                question: 'What is one of the key things to do when choosing a financial institution?',
                options: [
                  'Choose the one with the fanciest building.',
                  'Pick the one your friend uses without any research.',
                  'Check fees, read reviews, and compare interest rates.',
                  'Select the one with the most complicated website.',
                ],
                correctAnswer: 2,
                explanation: 'It\'s crucial to research and compare different institutions to find the one that best suits your needs and offers the most favorable terms.',
              ),
            ],
          ),
        ],
      ),

      // Credit
      Lesson(
        id: 'b_05',
        title: 'Understanding Credit',
        description: 'Your financial trustworthiness score',
        xpReward: 100,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '💳 Credit = Financial Trust\n\nIt\'s your reputation in the money world. Good credit? Banks trust you. Bad credit? Doors close. 🚪',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🎯 How Credit Works:\n\n1. You borrow money (credit card/loan)\n2. Pay it back on time\n3. Your score goes up 📈\n4. Get better rates next time\n5. Save thousands in interest!',
          ),
          LessonContent(
            type: ContentType.example,
            data: '💰 Credit Card Example:\n\nCard limit: ₹50,000\nYou spend: ₹10,000\nPay full ₹10,000 before due date\n\nResult:\n✅ No interest paid\n✅ Credit score improves\n✅ Build trust with bank',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🚨 Credit Killers:\n\n❌ Late payments\n❌ Using full credit limit\n❌ Applying for too many cards\n❌ Defaulting on loans\n❌ Closing old accounts\n\nAvoid these at all costs!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the best way to use a credit card to build your credit score?',
                options: [
                  'Spend the entire credit limit and pay it back slowly.',
                  'Make a purchase and pay the full balance before the due date.',
                  'Never use the credit card.',
                  'Only make minimum payments.',
                ],
                correctAnswer: 1,
                explanation: 'Paying your balance in full every month is the best way to improve your credit score and avoid interest charges.',
              ),
              QuizQuestion(
                question: 'Which of the following is a "Credit Killer"?',
                options: [
                  'Paying your bills on time.',
                  'Keeping your credit usage low.',
                  'Making late payments.',
                  'Checking your credit report for errors.',
                ],
                correctAnswer: 2,
                explanation: 'Late payments are one of the most damaging things for your credit score.',
              ),
              QuizQuestion(
                question: 'What is the primary benefit of having a good credit score?',
                options: [
                  'You get a lot of free stuff.',
                  'You can get loans with lower interest rates.',
                  'You don\'t have to pay taxes.',
                  'You can ignore your bills.',
                ],
                correctAnswer: 1,
                explanation: 'A good credit score demonstrates your financial responsibility and allows you to access better loan terms, saving you money.',
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // 💰 3. EARNING & CAREER MODULE
  static final LearningModule _earningCareerModule = LearningModule(
    id: 'earning_career',
    title: '💰 Earning & Career',
    description: 'Build wealth through smart career choices and multiple income streams',
    iconPath: 'assets/images/earning_career_3d.jpg',
    gradientColors: [DesignTokens.secondaryStart, DesignTokens.secondaryEnd],
    totalXp: 700,
    lessons: [
      // Earning
      Lesson(
        id: 'ec_01',
        title: 'Money-Making\n101',
        description: 'All the ways to earn and grow wealth',
        xpReward: 50,
        estimatedMinutes: 6,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '💵 What is Earning?\n\nMoney you get in exchange for your time, skills, or investments. The more value you provide, the more you can earn!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🎯 Income Types:\n\nActive Income (trade time for money):\n• Job salary\n• Freelancing\n• Part-time work\n\nPassive Income (money works for you):\n• Investments\n• YouTube channel\n• Selling digital products',
          ),
          LessonContent(
            type: ContentType.example,
            data: '💡 Teen Earning Ideas:\n\n📚 Tutoring: ₹500-1000/hour\n🎨 Graphic design: ₹2000/project\n📱 Content creation: Variable\n🐕 Pet sitting: ₹300/day\n💻 Coding gigs: ₹5000-20000\n📝 Writing: ₹1-3/word',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🚀 Start NOW: Skills you build as a teen can become serious income sources. Learn, practice, monetize!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the difference between active and passive income?',
                options: [
                  'There is no difference.',
                  'Active income is earned from a job, while passive income is from a hobby.',
                  'Active income requires you to trade your time for money, while passive income is when your money works for you.',
                  'Passive income is illegal.',
                ],
                correctAnswer: 2,
                explanation: 'Active income is directly tied to your time and effort, while passive income is generated from assets or systems you\'ve created.',
              ),
              QuizQuestion(
                question: 'Which of the following is an example of passive income?',
                options: [
                  'Your salary from a part-time job.',
                  'Money earned from freelancing.',
                  'Earnings from a YouTube channel.',
                  'Your hourly wage from tutoring.',
                ],
                correctAnswer: 2,
                explanation: 'A YouTube channel can generate ad revenue and other income streams even when you are not actively working on it, making it a form of passive income.',
              ),
              QuizQuestion(
                question: 'What is the main message of the "Start NOW" tip?',
                options: [
                  'You should wait until you are older to start earning money.',
                  'The skills you learn as a teen can become valuable income sources later.',
                  'Earning money as a teen is not important.',
                  'You should only focus on one skill.',
                ],
                correctAnswer: 1,
                explanation: 'The lesson encourages teens to start learning and practicing skills early, as they can be monetized and turned into significant income streams in the future.',
              ),
            ],
          ),
        ],
      ),

      // Career Choice
      Lesson(
        id: 'ec_02',
        title: 'Choosing Your Career Path',
        description: 'Pick a career that pays AND fulfills you',
        xpReward: 75,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🎯 Smart Career Choice = Success + Satisfaction\n\nYour career affects 40+ years of your life. Choose wisely, not hastily!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '💡 Consider These:\n\n1. What do you LOVE doing?\n2. What are you naturally good at?\n3. What problems can you solve?\n4. What\'s the earning potential?\n5. Is there job growth?',
          ),
          LessonContent(
            type: ContentType.example,
            data: '📊 High-Growth Fields (2025+):\n\n• AI & Machine Learning\n• Data Science\n• Digital Marketing\n• Content Creation\n• Cybersecurity\n• Healthcare\n• Green Energy\n• Financial Technology',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '✨ Career Hack: Don\'t just follow money or passion - find where they intersect! That\'s your sweet spot. 🎯',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'According to the lesson, what is the "sweet spot" for choosing a career?',
                options: [
                  'A job that pays a lot of money, even if you don\'t like it.',
                  'A job that you are passionate about, even if it doesn\'t pay well.',
                  'The intersection of what you love, what you\'re good at, and what has good earning potential.',
                  'A job that is easy and doesn\'t require much effort.',
                ],
                correctAnswer: 2,
                explanation: 'The lesson advises finding a career where your passion and skills meet good earning potential.',
              ),
              QuizQuestion(
                question: 'Which of the following is NOT listed as a high-growth field for 2025+?',
                options: [
                  'AI & Machine Learning',
                  'Data Entry',
                  'Digital Marketing',
                  'Cybersecurity',
                ],
                correctAnswer: 1,
                explanation: 'While important, "Data Entry" is not listed as a high-growth field in the same way as AI, Digital Marketing, or Cybersecurity.',
              ),
              QuizQuestion(
                question: 'What is one of the key factors to consider when choosing a career path?',
                options: [
                  'What your friends are doing.',
                  'What your parents want you to do.',
                  'What you are naturally good at.',
                  'The easiest career to get into.',
                ],
                correctAnswer: 2,
                explanation: 'The lesson emphasizes the importance of considering your natural talents and skills when making a career choice.',
              ),
            ],
          ),
        ],
      ),

      // Income Tax
      Lesson(
        id: 'ec_03',
        title: 'Income Tax Made Simple',
        description: 'What it is and why you pay it',
        xpReward: 100,
        estimatedMinutes: 7,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '💸 What is Income Tax?\n\nA percentage of your earnings paid to the government. It funds roads, schools, hospitals, and more!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🇮🇳 Indian Tax Slabs (New Regime):\n\nUp to ₹3L: 0% (No tax!)\n₹3-7L: 5%\n₹7-10L: 10%\n₹10-12L: 15%\n₹12-15L: 20%\nAbove ₹15L: 30%',
          ),
          LessonContent(
            type: ContentType.example,
            data: '💰 Example:\n\nYour income: ₹6,00,000/year\nTax-free: ₹3,00,000\nTaxable: ₹3,00,000\n\nTax = 5% of ₹3L = ₹15,000\nYou keep: ₹5,85,000',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🎯 Tax-Saving Tips:\n\n• Invest in PPF, ELSS\n• Health insurance premiums\n• Education loan interest\n• Home loan interest\n• Keep all receipts!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is income tax?',
                options: [
                  'A fee you pay to your employer.',
                  'A percentage of your earnings paid to the government to fund public services.',
                  'A voluntary donation to charity.',
                  'A type of investment.',
                ],
                correctAnswer: 1,
                explanation: 'Income tax is a mandatory payment to the government that funds public infrastructure and services.',
              ),
              QuizQuestion(
                question: 'Under the new tax regime, what is the tax rate for an income of ₹4,00,000 per year?',
                options: [
                  '0%',
                  '5%',
                  '10%',
                  '15%',
                ],
                correctAnswer: 1,
                explanation: 'For income between ₹3L and ₹7L, the tax rate is 5% under the new regime.',
              ),
              QuizQuestion(
                question: 'Which of the following is a tax-saving tip mentioned in the lesson?',
                options: [
                  'Spending more money on wants.',
                  'Investing in PPF or ELSS.',
                  'Not paying your taxes.',
                  'Keeping your income a secret.',
                ],
                correctAnswer: 1,
                explanation: 'Investing in certain financial instruments like PPF and ELSS can help you reduce your taxable income.',
              ),
            ],
          ),
        ],
      ),

      // Auto (Car-Related Finances)
      Lesson(
        id: 'ec_04',
        title: 'Car Economics 101',
        description: 'Real cost of owning a vehicle',
        xpReward: 100,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🚗 Car = Money Pit?\n\nCars are expensive! Beyond the price tag, there\'s fuel, insurance, maintenance, parking, and more.',
          ),
          LessonContent(
            type: ContentType.text,
            data: '💰 True Cost Breakdown:\n\nCar Price: ₹8,00,000\n+ Loan Interest: ₹2,00,000\n+ Insurance: ₹20,000/year\n+ Fuel: ₹5,000/month\n+ Maintenance: ₹30,000/year\n+ Parking: ₹2,000/month\n\n5-year cost: ₹15+ lakhs! 😱',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🆚 Buy vs Alternatives:\n\nOwn Car: ₹15L over 5 years\nUber/Ola: ₹6-8L over 5 years\nBike: ₹3-4L over 5 years\nPublic Transport: ₹1L over 5 years',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '💡 Smart Move:\n\nDelay buying until you REALLY need it. Invest that money instead - it could grow to 2x-3x! Buy car later with profits. 📈',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the "True Cost" of owning a car?',
                options: [
                  'Just the price of the car.',
                  'The price of the car plus fuel and insurance.',
                  'The price of the car plus all associated costs like fuel, insurance, maintenance, and parking.',
                  'The cost of a car loan.',
                ],
                correctAnswer: 2,
                explanation: 'The "True Cost" includes the purchase price and all the ongoing expenses that come with owning a car.',
              ),
              QuizQuestion(
                question: 'According to the lesson, what is a "Smart Move" regarding car ownership?',
                options: [
                  'Buy the most expensive car you can afford.',
                  'Buy a car as soon as you get your license.',
                  'Delay buying a car until you really need it and invest the money instead.',
                  'Never buy a car.',
                ],
                correctAnswer: 2,
                explanation: 'The lesson suggests that delaying a car purchase and investing the money can be a financially savvy decision.',
              ),
              QuizQuestion(
                question: 'Which of the following is NOT considered a part of the "True Cost" of owning a car?',
                options: [
                  'Fuel',
                  'Insurance',
                  'Maintenance',
                  'The color of the car',
                ],
                correctAnswer: 3,
                explanation: 'While the color might affect the initial price slightly, it\'s not an ongoing cost like fuel, insurance, and maintenance.',
              ),
            ],
          ),
        ],
      ),

      // College (Student Loans & Tuition Planning)
      Lesson(
        id: 'ec_05',
        title: 'College: The Smart Investment',
        description: 'Fund education without drowning in debt',
        xpReward: 125,
        estimatedMinutes: 9,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🎓 College Costs Reality:\n\nGood college = ₹5-25 lakhs\nTop IITs/NITs = Lower\nPrivate colleges = Higher\nAbroad = ₹50L-1Cr+\n\nPlan NOW, stress less later!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '💰 Funding Options:\n\n1. Savings (start early!)\n2. Scholarships (FREE money!)\n3. Education Loans (4-12% interest)\n4. Part-time work\n5. Skill-based income\n6. Family support',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🎯 Student Loan Math:\n\nLoan: ₹10,00,000 @ 10%\nRepay: 10 years\nMonthly EMI: ₹13,215\nTotal paid: ₹15,85,800\n\nYour cost: ₹5.86L extra! 😰',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🔥 Scholarship Hunting:\n\n• Start in Class 11\n• Apply to 20-30 scholarships\n• Maintain good grades\n• Build strong profile\n• Write compelling essays\n\nCan save lakhs! 💰',
          ),
          LessonContent(
            type: ContentType.text,
            data: '✨ Smart College Strategy:\n\n1. Choose ROI-positive field\n2. Government colleges (if possible)\n3. Exhaust scholarships first\n4. Minimal loans\n5. Work part-time\n6. Graduate with <₹5L debt',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is a "Smart College Strategy"?',
                options: [
                  'Choosing the most expensive college.',
                  'Taking out the largest possible student loan.',
                  'Choosing a field with good return on investment (ROI) and minimizing debt.',
                  'Not going to college.',
                ],
                correctAnswer: 2,
                explanation: 'A smart strategy involves making choices that will lead to a good career and manageable debt after graduation.',
              ),
              QuizQuestion(
                question: 'What is one of the best ways to fund your college education?',
                options: [
                  'Relying solely on your parents.',
                  'Taking out multiple high-interest loans.',
                  'Actively hunting for and applying to scholarships.',
                  'Using a credit card.',
                ],
                correctAnswer: 2,
                explanation: 'Scholarships are essentially free money for your education, making them a top funding option.',
              ),
              QuizQuestion(
                question: 'According to the "Student Loan Math" example, what is the extra cost of a ₹10,00,000 loan over 10 years?',
                options: [
                  '₹1,00,000',
                  '₹2,50,000',
                  '₹5,86,000',
                  '₹10,00,000',
                ],
                correctAnswer: 2,
                explanation: 'The example shows that the interest paid on the loan amounts to an extra ₹5.86 lakhs over the loan\'s duration.',
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // 📈 4. INVESTING & GROWTH MODULE
  static final LearningModule _investingModule = LearningModule(
    id: 'investing',
    title: '📈 Investing & Growth',
    description: 'Make your money work for you and build lasting wealth',
    iconPath: 'assets/images/investing_3d.webp',
    gradientColors: [const Color(0xFFFF6B9D), const Color(0xFFC06C84)],
    totalXp: 800,
    lessons: [
      // Investing
      Lesson(
        id: 'i_01',
        title: 'Investing: Money Making Money',
        description: 'Turn savings into wealth-building machines',
        xpReward: 75,
        estimatedMinutes: 8,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '📈 What is Investing?\n\nPutting money into something that grows in value over time. It\'s how rich people stay rich!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '💡 Saving vs Investing:\n\nSaving:\n• Bank account (4% return)\n• Safe but slow\n• Good for short-term\n\nInvesting:\n• Stocks/Mutual Funds (12-15%)\n• Riskier but grows faster\n• Best for long-term',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🚀 The Power of Investing:\n\n₹10,000 invested monthly:\n\nSavings (4%): ₹36L in 20 years\nInvesting (12%): ₹99L in 20 years\n\nDifference: ₹63 LAKHS! 💰',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '⚡ Teen Advantage: Time! Start with ₹500/month now. By 40, you could have CRORES. That\'s compound interest magic! ✨',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the main difference between saving and investing?',
                options: [
                  'There is no difference.',
                  'Saving is for the long-term, and investing is for the short-term.',
                  'Saving is safe but slow, while investing is riskier but has the potential for faster growth.',
                  'Investing is only for rich people.',
                ],
                correctAnswer: 2,
                explanation: 'The lesson highlights that saving is a low-risk, low-return strategy, while investing offers higher potential returns with higher risk.',
              ),
              QuizQuestion(
                question: 'According to the "Power of Investing" example, what is the significant advantage of investing over saving?',
                options: [
                  'There is no advantage.',
                  'Investing is less risky than saving.',
                  'Investing can lead to significantly higher returns over the long term.',
                  'Saving is always better than investing.',
                ],
                correctAnswer: 2,
                explanation: 'The example shows that investing can generate much greater wealth over time due to the power of compounding.',
              ),
              QuizQuestion(
                question: 'What is the "Teen Advantage" in investing?',
                options: [
                  'Teens have more money to invest.',
                  'Teens have more time for their investments to grow.',
                  'Teens are better at picking stocks.',
                  'There is no advantage for teens.',
                ],
                correctAnswer: 1,
                explanation: 'The lesson emphasizes that starting to invest early, even with small amounts, can lead to substantial wealth due to the long time horizon for compounding.',
              ),
            ],
          ),
        ],
      ),

      // Financial Planning
      Lesson(
        id: 'i_02',
        title: 'Financial Planning 101',
        description: 'Create your complete money roadmap',
        xpReward: 100,
        estimatedMinutes: 9,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🗺️ What is Financial Planning?\n\nA complete roadmap for your money - today, tomorrow, and 30 years from now. It\'s your financial GPS!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🎯 Financial Planning Steps:\n\n1. Set clear goals (house, car, retirement)\n2. Calculate how much needed\n3. Create income plan\n4. Build savings habit\n5. Start investing\n6. Get insurance\n7. Review & adjust yearly',
          ),
          LessonContent(
            type: ContentType.example,
            data: '📊 Life Stages Planning:\n\n20s: Build emergency fund, invest 20%\n30s: Buy home, increase investments\n40s: Peak earnings, max retirement savings\n50s: Preserve wealth, reduce risk\n60s+: Enjoy retirement! 🏖️',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '✨ Start NOW:\n\nEvery 5 years you delay investing costs you LAKHS in potential gains. The best time was yesterday. Second best? TODAY!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is financial planning?',
                options: [
                  'A way to get rich quick.',
                  'A complete roadmap for your money.',
                  'A type of savings account.',
                  'A government program.',
                ],
                correctAnswer: 1,
                explanation: 'Financial planning is the process of creating a comprehensive plan to manage your finances and achieve your financial goals.',
              ),
              QuizQuestion(
                question: 'Which of the following is the first step in financial planning?',
                options: [
                  'Start investing.',
                  'Set clear goals.',
                  'Get insurance.',
                  'Create an income plan.',
                ],
                correctAnswer: 1,
                explanation: 'Setting clear financial goals is the foundational step of any financial plan.',
              ),
              QuizQuestion(
                question: 'What is the main message of the "Start NOW" tip?',
                options: [
                  'It\'s okay to delay investing for a few years.',
                  'The best time to start investing is today.',
                  'Investing is only for older people.',
                  'You should wait until you have a lot of money to invest.',
                ],
                correctAnswer: 1,
                explanation: 'The lesson stresses the importance of starting to invest as early as possible to take advantage of compounding.',
              ),
            ],
          ),
        ],
      ),

      // Retirement
      Lesson(
        id: 'i_03',
        title: 'Retirement: Your Future Freedom',
        description: 'Plan now, relax later (seriously!)',
        xpReward: 125,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🏖️ What is Retirement?\n\nWhen you stop working but still need money to live. Good planning = chill retirement. No planning = financial stress at 65.',
          ),
          LessonContent(
            type: ContentType.text,
            data: '💰 How Much Do You Need?\n\nRule of thumb: 25x your yearly expenses\n\nIf you need ₹10L/year:\nRetirement fund needed = ₹2.5 CRORE\n\nSounds scary? Start early, reach easily! 📈',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🎯 Starting Early vs Late:\n\nStart at 20, invest ₹5K/month:\nAt 60: ₹5.9 Crores! 💰\n\nStart at 40, invest ₹5K/month:\nAt 60: ₹51 Lakhs only 😰\n\nSame effort, 10X difference!',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🚀 Retirement Investing:\n\n• Start with ₹500-1000/month\n• PPF (tax-free returns)\n• NPS (government pension)\n• Mutual Funds (SIP)\n• Never touch retirement savings!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the "Rule of thumb" for calculating how much you need for retirement?',
                options: [
                  '10x your yearly expenses.',
                  '25x your yearly expenses.',
                  '50x your yearly expenses.',
                  '100x your yearly expenses.',
                ],
                correctAnswer: 1,
                explanation: 'The lesson suggests a rule of thumb of saving 25 times your annual expenses for retirement.',
              ),
              QuizQuestion(
                question: 'Why is it so important to start investing for retirement early?',
                options: [
                  'It\'s not important, you can start anytime.',
                  'Because you will have more money to invest when you are older.',
                  'To take advantage of compounding over a longer period.',
                  'Because it\'s easier to pick stocks when you are young.',
                ],
                correctAnswer: 2,
                explanation: 'Starting early allows your investments to grow exponentially over time due to the power of compounding.',
              ),
              QuizQuestion(
                question: 'Which of the following is NOT a recommended retirement investment option in the lesson?',
                options: [
                  'PPF (Public Provident Fund)',
                  'NPS (National Pension System)',
                  'Lottery tickets',
                  'Mutual Funds (SIP)',
                ],
                correctAnswer: 2,
                explanation: 'The lesson recommends stable, long-term investment options like PPF, NPS, and Mutual Funds, not speculative gambles like lottery tickets.',
              ),
            ],
          ),
        ],
      ),

      // Insurance
      Lesson(
        id: 'i_04',
        title: 'Insurance: Your Financial Shield',
        description: 'Protect yourself from life\'s financial bombs',
        xpReward: 100,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🛡️ What is Insurance?\n\nYou pay small amount regularly. Insurance company pays HUGE amount if disaster strikes. It\'s financial protection!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '📋 Types You Need:\n\nHealth Insurance (MUST HAVE):\n• Covers medical bills\n• ₹5-10L coverage minimum\n\nLife Insurance (if family depends on you):\n• Term insurance only\n• 10-15x your annual income\n\nVehicle Insurance (legally required):\n• Comprehensive coverage',
          ),
          LessonContent(
            type: ContentType.example,
            data: '💊 Why Health Insurance?\n\nMedical emergency: ₹3L bill\n\nWith insurance:\nYou pay: ₹1-2K deductible\nInsurance pays: ₹2.98L ✅\n\nWithout insurance:\nYou pay: Full ₹3L 😱\nSavings = wiped out!',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '⚡ Insurance Rules:\n\n1. Buy young (cheaper premiums!)\n2. Term insurance > Investment insurance\n3. Don\'t skip even in good times\n4. Read what\'s NOT covered\n5. Family floater plans save money',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is the main purpose of insurance?',
                options: [
                  'To make a lot of money.',
                  'To provide financial protection against disasters.',
                  'To get a discount on your taxes.',
                  'To get a loan from the bank.',
                ],
                correctAnswer: 1,
                explanation: 'Insurance is a way to protect yourself financially from large, unexpected expenses.',
              ),
              QuizQuestion(
                question: 'Which type of insurance is described as a "MUST HAVE" in the lesson?',
                options: [
                  'Vehicle Insurance',
                  'Life Insurance',
                  'Health Insurance',
                  'Travel Insurance',
                ],
                correctAnswer: 2,
                explanation: 'The lesson emphasizes that health insurance is essential for everyone to cover potentially high medical costs.',
              ),
              QuizQuestion(
                question: 'What is one of the "Insurance Rules" mentioned in the lesson?',
                options: [
                  'Buy insurance when you are old.',
                  'Investment insurance is better than term insurance.',
                  'It\'s okay to skip insurance if you are healthy.',
                  'Buy insurance when you are young to get cheaper premiums.',
                ],
                correctAnswer: 3,
                explanation: 'Buying insurance at a younger age usually results in lower premium payments.',
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // 💖 5. SOCIAL & PERSONAL FINANCE MODULE
  static final LearningModule _socialFinanceModule = LearningModule(
    id: 'social_finance',
    title: '💖 Social & Personal Finance',
    description: 'Money with meaning - give back and be financially responsible',
    iconPath: 'assets/images/money_basics_icon.png', // Using existing icon as placeholder
    gradientColors: [const Color(0xFFFF6B9D), const Color(0xFFFFB347)],
    totalXp: 300,
    lessons: [
      // Charitable Giving
      Lesson(
        id: 'sf_01',
        title: 'Giving Back: Money with Meaning',
        description: 'How to donate smartly and create impact',
        xpReward: 100,
        estimatedMinutes: 7,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '💝 What is Charitable Giving?\n\nDonating money, time, or resources to help others. It feels AMAZING and builds a better world!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '✨ Benefits of Giving:\n\n• Helps those in need\n• Builds empathy & gratitude\n• Tax deductions (save money!)\n• Feel-good factor\n• Creates positive change\n• Teaches you values',
          ),
          LessonContent(
            type: ContentType.example,
            data: '🎯 How to Give (Even as Teen):\n\n• Donate 1-5% of pocket money\n• Volunteer time (it\'s valuable!)\n• Organize fundraisers\n• Donate old stuff\n• Share skills (teach for free)\n• Raise awareness online',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '⚠️ Donate Smartly:\n\n✅ Research the charity (legitimate?)\n✅ Check where money goes\n✅ Prefer direct impact orgs\n✅ Get tax receipts\n✅ Regular small > One-time big',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🌟 Trusted Charities in India:\n\n• GiveIndia\n• Akshaya Patra\n• CRY (Child Rights)\n• HelpAge India\n• Pratham Education\n• Smile Foundation\n\nAlways verify before donating!',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is charitable giving?',
                options: [
                  'A way to become famous.',
                  'Donating money, time, or resources to help others.',
                  'A type of investment.',
                  'A way to avoid taxes.',
                ],
                correctAnswer: 1,
                explanation: 'Charitable giving is the act of giving to those in need, whether it\'s through money, time, or other resources.',
              ),
              QuizQuestion(
                question: 'Which of the following is a way for teens to give back?',
                options: [
                  'Donating millions of rupees.',
                  'Volunteering their time.',
                  'Ignoring the needs of others.',
                  'Keeping all their money for themselves.',
                ],
                correctAnswer: 1,
                explanation: 'The lesson suggests that even without a lot of money, teens can contribute by volunteering their time and skills.',
              ),
              QuizQuestion(
                question: 'What is an important step to take before donating to a charity?',
                options: [
                  'Donate to the first charity you see.',
                  'Research the charity to ensure it is legitimate.',
                  'Never ask for a tax receipt.',
                  'Donate to charities that are not registered.',
                ],
                correctAnswer: 1,
                explanation: 'It\'s crucial to research a charity to ensure your donation will be used effectively and for its intended purpose.',
              ),
            ],
          ),
        ],
      ),

      // Financial Responsibility
      Lesson(
        id: 'sf_02',
        title: 'Financial Responsibility',
        description: 'Be the boss of your money, not its slave',
        xpReward: 150,
        estimatedMinutes: 8,
        isLocked: true,
        content: [
          LessonContent(
            type: ContentType.text,
            data: '🎯 What is Financial Responsibility?\n\nBeing smart, careful, and ethical with money. It\'s making choices your future self will thank you for!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '💪 Financially Responsible Person:\n\n✅ Lives below means\n✅ Saves before spending\n✅ Avoids unnecessary debt\n✅ Pays bills on time\n✅ Has emergency fund\n✅ Invests for future\n✅ Has insurance\n✅ Tracks spending',
          ),
          LessonContent(
            type: ContentType.example,
            data: '😊 Responsible Choice:\n\nEarn ₹50K/month\nSpend ₹35K\nSave ₹10K\nInvest ₹5K\n\nResult: Growing wealth! 📈\n\n😰 Irresponsible Choice:\n\nEarn ₹50K/month\nSpend ₹55K (credit card!)\nSave ₹0\n\nResult: Debt spiral! 📉',
          ),
          LessonContent(
            type: ContentType.tip,
            data: '🎯 Want vs Need Filter:\n\nBefore ANY purchase ask:\n\n1. Do I NEED this?\n2. Can I afford it?\n3. Have I compared prices?\n4. Will I use it regularly?\n5. Can I wait 24 hours?\n\nNo to 2+ = Don\'t buy!',
          ),
          LessonContent(
            type: ContentType.text,
            data: '🌟 Build These Habits NOW:\n\n1. Track every rupee spent\n2. Save 20% minimum\n3. Think before buying\n4. Learn continuously\n5. Avoid lifestyle inflation\n6. Help others\n7. Stay humble with money\n\nYour future self will be grateful! 🙏',
          ),
          LessonContent(
            type: ContentType.quiz,
            data: '',
            quizQuestions: [
              QuizQuestion(
                question: 'What is a key characteristic of a financially responsible person?',
                options: [
                  'Spending more than they earn.',
                  'Living below their means.',
                  'Never saving money.',
                  'Avoiding investments.',
                ],
                correctAnswer: 1,
                explanation: 'Living below your means (spending less than you earn) is a fundamental principle of financial responsibility.',
              ),
              QuizQuestion(
                question: 'What is the "Want vs Need Filter"?',
                options: [
                  'A tool to help you buy more wants.',
                  'A set of questions to ask yourself before making a purchase to avoid impulse buying.',
                  'A way to get discounts on your purchases.',
                  'A type of credit card.',
                ],
                correctAnswer: 1,
                explanation: 'The "Want vs Need Filter" is a mental checklist to help you differentiate between essential needs and non-essential wants, leading to smarter spending decisions.',
              ),
              QuizQuestion(
                question: 'Which of the following is a habit of a financially responsible person?',
                options: [
                  'Avoiding tracking your spending.',
                  'Saving at least 20% of your income.',
                  'Making impulse purchases regularly.',
                  'Never helping others.',
                ],
                correctAnswer: 1,
                explanation: 'The lesson recommends saving a minimum of 20% of your income as a key habit for building financial security.',
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
