enum ExpenseCategory {
  needs,
  wants,
  savings,
}

class Expense {
  final String name;
  final ExpenseCategory category;
  final String explanation;

  const Expense({
    required this.name,
    required this.category,
    required this.explanation,
  });
}

// All expenses from the original game
final List<Expense> allExpenses = [
  // Needs
  const Expense(
    name: "Rent",
    category: ExpenseCategory.needs,
    explanation: "Housing is a basic need.",
  ),
  const Expense(
    name: "Mortgage Payment",
    category: ExpenseCategory.needs,
    explanation: "Housing is a basic need.",
  ),
  const Expense(
    name: "Electricity Bill",
    category: ExpenseCategory.needs,
    explanation: "Utilities are essential for daily living.",
  ),
  const Expense(
    name: "Water Bill",
    category: ExpenseCategory.needs,
    explanation: "Utilities are essential for daily living.",
  ),
  const Expense(
    name: "Gas Bill",
    category: ExpenseCategory.needs,
    explanation: "Utilities are essential for daily living.",
  ),
  const Expense(
    name: "Groceries",
    category: ExpenseCategory.needs,
    explanation: "Food is a basic necessity.",
  ),
  const Expense(
    name: "Public Transport",
    category: ExpenseCategory.needs,
    explanation: "Transportation for work or essential travel is a need.",
  ),
  const Expense(
    name: "Car Fuel",
    category: ExpenseCategory.needs,
    explanation: "Fuel for essential travel is a need.",
  ),
  const Expense(
    name: "Car Insurance",
    category: ExpenseCategory.needs,
    explanation: "Car insurance is a legal requirement in most places.",
  ),
  const Expense(
    name: "Health Insurance",
    category: ExpenseCategory.needs,
    explanation: "Health insurance is crucial for managing healthcare costs.",
  ),
  const Expense(
    name: "Prescription Medicine",
    category: ExpenseCategory.needs,
    explanation: "Essential medicine is a health need.",
  ),
  const Expense(
    name: "School Fees",
    category: ExpenseCategory.needs,
    explanation: "Education is a need for personal development.",
  ),
  const Expense(
    name: "Childcare",
    category: ExpenseCategory.needs,
    explanation: "Childcare is a need for working parents.",
  ),
  const Expense(
    name: "Internet Bill",
    category: ExpenseCategory.needs,
    explanation: "Internet access is often a need for work or school.",
  ),
  const Expense(
    name: "Phone Bill",
    category: ExpenseCategory.needs,
    explanation: "A phone is often a need for communication and safety.",
  ),
  const Expense(
    name: "Student Loan Repayment",
    category: ExpenseCategory.needs,
    explanation: "Repaying debt is a financial responsibility.",
  ),
  const Expense(
    name: "Home Maintenance",
    category: ExpenseCategory.needs,
    explanation: "Essential home repairs are a need.",
  ),
  const Expense(
    name: "Essential Clothing",
    category: ExpenseCategory.needs,
    explanation: "Basic clothing is a necessity.",
  ),
  const Expense(
    name: "Toiletries",
    category: ExpenseCategory.needs,
    explanation: "Personal hygiene products are a need.",
  ),
  const Expense(
    name: "Pet Food",
    category: ExpenseCategory.needs,
    explanation: "Food for pets is a need for their well-being.",
  ),
  const Expense(
    name: "Bus Fare",
    category: ExpenseCategory.needs,
    explanation: "Transportation for work or essential travel is a need.",
  ),
  const Expense(
    name: "Train Ticket",
    category: ExpenseCategory.needs,
    explanation: "Transportation for work or essential travel is a need.",
  ),
  const Expense(
    name: "Doctor's Visit",
    category: ExpenseCategory.needs,
    explanation: "Healthcare is a fundamental need.",
  ),
  const Expense(
    name: "Dental Check-up",
    category: ExpenseCategory.needs,
    explanation: "Dental care is important for overall health.",
  ),
  const Expense(
    name: "Basic Haircut",
    category: ExpenseCategory.needs,
    explanation: "Basic grooming is a need.",
  ),
  const Expense(
    name: "Work Supplies",
    category: ExpenseCategory.needs,
    explanation: "Supplies required for your job are a need.",
  ),
  const Expense(
    name: "Taxes",
    category: ExpenseCategory.needs,
    explanation: "Paying taxes is a legal obligation.",
  ),
  const Expense(
    name: "Emergency Fund Contribution",
    category: ExpenseCategory.needs,
    explanation: "Building an emergency fund is a critical financial need.",
  ),

  // Wants
  const Expense(
    name: "Pizza",
    category: ExpenseCategory.wants,
    explanation: "Dining out or ordering takeout is a want, not a need.",
  ),
  const Expense(
    name: "Movie Ticket",
    category: ExpenseCategory.wants,
    explanation: "Entertainment is a want.",
  ),
  const Expense(
    name: "Fashion T-shirt",
    category: ExpenseCategory.wants,
    explanation: "Fashion clothing is a want, not a basic need.",
  ),
  const Expense(
    name: "New Smartphone",
    category: ExpenseCategory.wants,
    explanation: "Upgrading your phone is usually a want.",
  ),
  const Expense(
    name: "Concert Tickets",
    category: ExpenseCategory.wants,
    explanation: "Entertainment is a want.",
  ),
  const Expense(
    name: "Dining Out",
    category: ExpenseCategory.wants,
    explanation: "Eating at restaurants is a want.",
  ),
  const Expense(
    name: "Vacation Travel",
    category: ExpenseCategory.wants,
    explanation: "Leisure travel is a want.",
  ),
  const Expense(
    name: "Designer Clothes",
    category: ExpenseCategory.wants,
    explanation: "Luxury items are wants.",
  ),
  const Expense(
    name: "Video Games",
    category: ExpenseCategory.wants,
    explanation: "Entertainment is a want.",
  ),
  const Expense(
    name: "Streaming Service (Netflix)",
    category: ExpenseCategory.wants,
    explanation: "Subscription services for entertainment are wants.",
  ),
  const Expense(
    name: "Music Subscription (Spotify)",
    category: ExpenseCategory.wants,
    explanation: "Subscription services for entertainment are wants.",
  ),
  const Expense(
    name: "Gym Membership (Leisure)",
    category: ExpenseCategory.wants,
    explanation: "A gym membership for leisure is a want.",
  ),
  const Expense(
    name: "Coffee Shop Visit",
    category: ExpenseCategory.wants,
    explanation: "Buying coffee is a want.",
  ),
  const Expense(
    name: "Leisure Books",
    category: ExpenseCategory.wants,
    explanation: "Books for entertainment are a want.",
  ),
  const Expense(
    name: "Hobby Supplies",
    category: ExpenseCategory.wants,
    explanation: "Supplies for hobbies are wants.",
  ),
  const Expense(
    name: "New Gadget",
    category: ExpenseCategory.wants,
    explanation: "New gadgets are typically wants.",
  ),
  const Expense(
    name: "Spa Day",
    category: ExpenseCategory.wants,
    explanation: "Luxury experiences are wants.",
  ),
  const Expense(
    name: "Car Upgrade",
    category: ExpenseCategory.wants,
    explanation: "Upgrading your car is a want.",
  ),
  const Expense(
    name: "Jewelry",
    category: ExpenseCategory.wants,
    explanation: "Jewelry is a luxury item and a want.",
  ),
  const Expense(
    name: "Alcohol",
    category: ExpenseCategory.wants,
    explanation: "Alcohol is a want.",
  ),
  const Expense(
    name: "Tobacco",
    category: ExpenseCategory.wants,
    explanation: "Tobacco is a want.",
  ),
  const Expense(
    name: "Lottery Tickets",
    category: ExpenseCategory.wants,
    explanation: "Gambling is a want.",
  ),
  const Expense(
    name: "Impulse Purchase",
    category: ExpenseCategory.wants,
    explanation: "Impulse buys are wants.",
  ),
  const Expense(
    name: "Luxury Goods",
    category: ExpenseCategory.wants,
    explanation: "Luxury items are wants.",
  ),
  const Expense(
    name: "Takeaway Food",
    category: ExpenseCategory.wants,
    explanation: "Ordering takeaway is a want.",
  ),
  const Expense(
    name: "Fashion Shoes",
    category: ExpenseCategory.wants,
    explanation: "Fashion shoes are a want.",
  ),
  const Expense(
    name: "Magazine Subscription",
    category: ExpenseCategory.wants,
    explanation: "Magazine subscriptions are wants.",
  ),
  const Expense(
    name: "Hair Dye",
    category: ExpenseCategory.wants,
    explanation: "Cosmetic treatments are wants.",
  ),
  const Expense(
    name: "Manicure/Pedicure",
    category: ExpenseCategory.wants,
    explanation: "Cosmetic treatments are wants.",
  ),
  const Expense(
    name: "Laptop Upgrade",
    category: ExpenseCategory.wants,
    explanation: "Upgrading your laptop is usually a want.",
  ),
  const Expense(
    name: "Home Decor",
    category: ExpenseCategory.wants,
    explanation: "Decorative items for your home are wants.",
  ),
  const Expense(
    name: "Gifts (Non-essential)",
    category: ExpenseCategory.wants,
    explanation: "Non-essential gifts are wants.",
  ),

  // Savings
  const Expense(
    name: "Savings Bond",
    category: ExpenseCategory.savings,
    explanation: "Savings bonds are a form of investment.",
  ),
  const Expense(
    name: "Stock Investment",
    category: ExpenseCategory.savings,
    explanation: "Investing in stocks is a way to grow your money.",
  ),
  const Expense(
    name: "Mutual Fund",
    category: ExpenseCategory.savings,
    explanation: "Mutual funds are a type of investment.",
  ),
  const Expense(
    name: "SIP (Systematic Investment Plan)",
    category: ExpenseCategory.savings,
    explanation: "A SIP is a disciplined investment strategy.",
  ),
  const Expense(
    name: "Retirement Fund",
    category: ExpenseCategory.savings,
    explanation: "Saving for retirement is a long-term financial goal.",
  ),
  const Expense(
    name: "College Fund",
    category: ExpenseCategory.savings,
    explanation: "Saving for education is a long-term financial goal.",
  ),
  const Expense(
    name: "Emergency Savings",
    category: ExpenseCategory.savings,
    explanation: "Building an emergency fund is a crucial part of financial planning.",
  ),
  const Expense(
    name: "Fixed Deposit",
    category: ExpenseCategory.savings,
    explanation: "A fixed deposit is a safe investment option.",
  ),
  const Expense(
    name: "Real Estate Investment",
    category: ExpenseCategory.savings,
    explanation: "Investing in real estate is a long-term investment.",
  ),
  const Expense(
    name: "Gold Investment",
    category: ExpenseCategory.savings,
    explanation: "Gold is often considered a safe-haven asset.",
  ),
  const Expense(
    name: "Cryptocurrency Investment",
    category: ExpenseCategory.savings,
    explanation: "Cryptocurrencies are a high-risk, high-reward investment.",
  ),
  const Expense(
    name: "High-Yield Savings Account",
    category: ExpenseCategory.savings,
    explanation: "A high-yield savings account helps your money grow faster.",
  ),
  const Expense(
    name: "Brokerage Account Contribution",
    category: ExpenseCategory.savings,
    explanation: "Contributing to a brokerage account is a form of investment.",
  ),
];
