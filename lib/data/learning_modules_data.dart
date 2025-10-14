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
        ],
      ),
    ],
  );

  // 💼 2. BANKING & INSTITUTIONS MODULE
  static final LearningModule _bankingModule = LearningModule(
    id: 'banking',
    title: '💼 Banking & Institutions',
    description: 'Navigate banks, loans, and financial institutions like a pro',
    iconPath: 'assets/images/banking_icon.png',
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
        ],
      ),
    ],
  );

  // 💰 3. EARNING & CAREER MODULE
  static final LearningModule _earningCareerModule = LearningModule(
    id: 'earning_career',
    title: '💰 Earning & Career',
    description: 'Build wealth through smart career choices and multiple income streams',
    iconPath: 'assets/images/earning_career_icon.png',
    gradientColors: [DesignTokens.secondaryStart, DesignTokens.secondaryEnd],
    totalXp: 700,
    lessons: [
      // Earning
      Lesson(
        id: 'ec_01',
        title: 'Money-Making 101',
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
        ],
      ),
    ],
  );

  // 📈 4. INVESTING & GROWTH MODULE
  static final LearningModule _investingModule = LearningModule(
    id: 'investing',
    title: '📈 Investing & Growth',
    description: 'Make your money work for you and build lasting wealth',
    iconPath: 'assets/images/investing_icon.png',
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
        ],
      ),
    ],
  );

  // 💖 5. SOCIAL & PERSONAL FINANCE MODULE
  static final LearningModule _socialFinanceModule = LearningModule(
    id: 'social_finance',
    title: '💖 Social & Personal Finance',
    description: 'Money with meaning - give back and be financially responsible',
    iconPath: 'assets/images/social_finance_icon.png',
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
        ],
      ),
    ],
  );
}
