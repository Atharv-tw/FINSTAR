import 'dart:math';

enum ScenarioCategory {
  food,
  entertainment,
  social,
  education,
  fashion,
  tech,
  transport,
  emergency,
}

enum ScenarioImpact {
  shortTerm, // Immediate satisfaction
  longTerm, // Future benefits
  social, // Friend relationships
  financial, // Money saved/lost
}

class SpendingScenario {
  final String id;
  final String title;
  final String description;
  final int cost;
  final ScenarioCategory category;
  final String emoji;
  final Map<ScenarioImpact, int> swipeRightImpact; // Accept the spending
  final Map<ScenarioImpact, int> swipeLeftImpact; // Decline the spending
  final String swipeRightLabel;
  final String swipeLeftLabel;
  final String? consequence; // What happens if you accept
  final String? benefit; // What happens if you decline

  SpendingScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.category,
    required this.emoji,
    required this.swipeRightImpact,
    required this.swipeLeftImpact,
    required this.swipeRightLabel,
    required this.swipeLeftLabel,
    this.consequence,
    this.benefit,
  });

  static List<SpendingScenario> getAllScenarios() {
    return [
      // FOOD & DINING
      SpendingScenario(
        id: 'food_1',
        title: 'Late Night Zomato',
        description: 'It\'s 2 AM. You\'re studying and hungry. A biryani costs ₹400 with delivery.',
        cost: 400,
        category: ScenarioCategory.food,
        emoji: '🍛',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 10,
          ScenarioImpact.financial: -400,
        },
        swipeLeftImpact: {
          ScenarioImpact.shortTerm: -5,
          ScenarioImpact.financial: 400,
        },
        swipeRightLabel: 'Order it',
        swipeLeftLabel: 'Cook maggi',
        consequence: 'Satisfied but ₹400 gone',
        benefit: 'Saved money, ate healthy',
      ),

      SpendingScenario(
        id: 'food_2',
        title: 'Weekend Brunch Squad',
        description: 'Your friends are going to a fancy cafe. Split bill will be ₹800 per person.',
        cost: 800,
        category: ScenarioCategory.food,
        emoji: '☕',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 15,
          ScenarioImpact.social: 10,
          ScenarioImpact.financial: -800,
        },
        swipeLeftImpact: {
          ScenarioImpact.social: -8,
          ScenarioImpact.financial: 800,
        },
        swipeRightLabel: 'Join them',
        swipeLeftLabel: 'Skip this time',
        consequence: 'Great vibes, but expensive',
        benefit: 'FOMO avoided, wallet happy',
      ),

      SpendingScenario(
        id: 'food_3',
        title: 'Starbucks Study Session',
        description: 'Need a place to study. Starbucks coffee costs ₹350. Library is free.',
        cost: 350,
        category: ScenarioCategory.food,
        emoji: '☕',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 8,
          ScenarioImpact.financial: -350,
        },
        swipeLeftImpact: {
          ScenarioImpact.financial: 350,
        },
        swipeRightLabel: 'Starbucks',
        swipeLeftLabel: 'Library',
        consequence: 'Aesthetic study spot, costly',
        benefit: 'Saved money, focused better',
      ),

      // ENTERTAINMENT
      SpendingScenario(
        id: 'entertainment_1',
        title: 'Concert Tickets',
        description: 'Your favorite artist is performing. Tickets are ₹2,500. All friends are going.',
        cost: 2500,
        category: ScenarioCategory.entertainment,
        emoji: '🎵',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 25,
          ScenarioImpact.social: 15,
          ScenarioImpact.longTerm: 10,
          ScenarioImpact.financial: -2500,
        },
        swipeLeftImpact: {
          ScenarioImpact.social: -15,
          ScenarioImpact.financial: 2500,
        },
        swipeRightLabel: 'Buy ticket',
        swipeLeftLabel: 'Watch stories',
        consequence: 'Epic memories, broke for a week',
        benefit: 'Massive FOMO, but savings intact',
      ),

      SpendingScenario(
        id: 'entertainment_2',
        title: 'Netflix Premium',
        description: 'Friends want to share Netflix Premium (₹650/month). You currently use free options.',
        cost: 650,
        category: ScenarioCategory.entertainment,
        emoji: '🎬',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 12,
          ScenarioImpact.financial: -650,
        },
        swipeLeftImpact: {
          ScenarioImpact.shortTerm: -3,
          ScenarioImpact.financial: 650,
        },
        swipeRightLabel: 'Subscribe',
        swipeLeftLabel: 'Stay free',
        consequence: '4K streaming, recurring cost',
        benefit: 'Saving ₹7800/year',
      ),

      SpendingScenario(
        id: 'entertainment_3',
        title: 'Gaming Tournament Entry',
        description: 'BGMI tournament entry fee: ₹500. Prize pool is ₹50,000. You\'re decent at the game.',
        cost: 500,
        category: ScenarioCategory.entertainment,
        emoji: '🎮',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 15,
          ScenarioImpact.longTerm: 5,
          ScenarioImpact.financial: -500,
        },
        swipeLeftImpact: {
          ScenarioImpact.shortTerm: -5,
          ScenarioImpact.financial: 500,
        },
        swipeRightLabel: 'Enter',
        swipeLeftLabel: 'Just play casually',
        consequence: 'Fun competition, slim win chance',
        benefit: 'Avoided gambling mindset',
      ),

      // SOCIAL
      SpendingScenario(
        id: 'social_1',
        title: 'Friend\'s Birthday Gift',
        description: 'Close friend\'s birthday. Everyone is pitching in ₹1,200 for a group gift.',
        cost: 1200,
        category: ScenarioCategory.social,
        emoji: '🎁',
        swipeRightImpact: {
          ScenarioImpact.social: 20,
          ScenarioImpact.financial: -1200,
        },
        swipeLeftImpact: {
          ScenarioImpact.social: -18,
          ScenarioImpact.financial: 1200,
        },
        swipeRightLabel: 'Contribute',
        swipeLeftLabel: 'Personal gift',
        consequence: 'Friend happy, you\'re broke',
        benefit: 'Awkward explanation needed',
      ),

      SpendingScenario(
        id: 'social_2',
        title: 'Weekend Trip to Goa',
        description: 'Friends planning 3-day Goa trip. Your share: ₹8,000 including travel, stay, food.',
        cost: 8000,
        category: ScenarioCategory.social,
        emoji: '🏖️',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 30,
          ScenarioImpact.social: 25,
          ScenarioImpact.longTerm: 15,
          ScenarioImpact.financial: -8000,
        },
        swipeLeftImpact: {
          ScenarioImpact.social: -20,
          ScenarioImpact.financial: 8000,
        },
        swipeRightLabel: 'I\'m in!',
        swipeLeftLabel: 'Maybe next time',
        consequence: 'Lifetime memories, empty wallet',
        benefit: 'Huge FOMO but responsible choice',
      ),

      SpendingScenario(
        id: 'social_3',
        title: 'Split Uber to College',
        description: 'Friend offers to split Uber daily (₹150/day). Bus costs ₹30 but takes 1 hour extra.',
        cost: 150,
        category: ScenarioCategory.transport,
        emoji: '🚗',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 10,
          ScenarioImpact.longTerm: 5,
          ScenarioImpact.financial: -150,
        },
        swipeLeftImpact: {
          ScenarioImpact.shortTerm: -8,
          ScenarioImpact.financial: 150,
        },
        swipeRightLabel: 'Split Uber',
        swipeLeftLabel: 'Take bus',
        consequence: 'Save time, ₹3600/month gone',
        benefit: 'Save ₹3600/month, lose 30 hrs',
      ),

      // EDUCATION & SKILLS
      SpendingScenario(
        id: 'education_1',
        title: 'Online Course Deal',
        description: 'Udemy course on Web Dev (₹1,500). Could help you freelance and earn ₹10k/month.',
        cost: 1500,
        category: ScenarioCategory.education,
        emoji: '💻',
        swipeRightImpact: {
          ScenarioImpact.longTerm: 30,
          ScenarioImpact.financial: -1500,
        },
        swipeLeftImpact: {
          ScenarioImpact.longTerm: -15,
          ScenarioImpact.financial: 1500,
        },
        swipeRightLabel: 'Invest',
        swipeLeftLabel: 'Free tutorials',
        consequence: 'Structured learning, upfront cost',
        benefit: 'Free but need self-discipline',
      ),

      SpendingScenario(
        id: 'education_2',
        title: 'Certification Exam',
        description: 'AWS certification exam fee: ₹4,000. Boosts resume but not mandatory for your career.',
        cost: 4000,
        category: ScenarioCategory.education,
        emoji: '📜',
        swipeRightImpact: {
          ScenarioImpact.longTerm: 25,
          ScenarioImpact.financial: -4000,
        },
        swipeLeftImpact: {
          ScenarioImpact.longTerm: -5,
          ScenarioImpact.financial: 4000,
        },
        swipeRightLabel: 'Take exam',
        swipeLeftLabel: 'Skip for now',
        consequence: 'Career boost, expensive bet',
        benefit: 'Focus on free learning first',
      ),

      SpendingScenario(
        id: 'education_3',
        title: 'Books vs. PDFs',
        description: 'Physical books for course: ₹2,000. PDFs available free online (legally gray area).',
        cost: 2000,
        category: ScenarioCategory.education,
        emoji: '📚',
        swipeRightImpact: {
          ScenarioImpact.longTerm: 10,
          ScenarioImpact.financial: -2000,
        },
        swipeLeftImpact: {
          ScenarioImpact.financial: 2000,
        },
        swipeRightLabel: 'Buy books',
        swipeLeftLabel: 'Use PDFs',
        consequence: 'Better focus, supports authors',
        benefit: 'Free but screen strain',
      ),

      // FASHION & APPEARANCE
      SpendingScenario(
        id: 'fashion_1',
        title: 'Sneaker Drop',
        description: 'Limited edition sneakers dropping. ₹6,000. They\'ll look fire but you have 3 pairs already.',
        cost: 6000,
        category: ScenarioCategory.fashion,
        emoji: '👟',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 20,
          ScenarioImpact.financial: -6000,
        },
        swipeLeftImpact: {
          ScenarioImpact.shortTerm: -10,
          ScenarioImpact.financial: 6000,
        },
        swipeRightLabel: 'Cop them',
        swipeLeftLabel: 'Resist',
        consequence: 'Fresh kicks, broke wallet',
        benefit: 'Avoided impulse buy',
      ),

      SpendingScenario(
        id: 'fashion_2',
        title: 'Interview Outfit',
        description: 'Job interview next week. Formal outfit costs ₹3,500. You can manage with existing clothes.',
        cost: 3500,
        category: ScenarioCategory.fashion,
        emoji: '👔',
        swipeRightImpact: {
          ScenarioImpact.longTerm: 15,
          ScenarioImpact.financial: -3500,
        },
        swipeLeftImpact: {
          ScenarioImpact.longTerm: -5,
          ScenarioImpact.financial: 3500,
        },
        swipeRightLabel: 'Buy new',
        swipeLeftLabel: 'Use existing',
        consequence: 'Confidence boost, investment',
        benefit: 'Saved money, slight risk',
      ),

      SpendingScenario(
        id: 'fashion_3',
        title: 'Salon Premium Package',
        description: 'New salon offering premium haircut + styling: ₹1,800. Regular salon costs ₹300.',
        cost: 1800,
        category: ScenarioCategory.fashion,
        emoji: '💇',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 12,
          ScenarioImpact.financial: -1800,
        },
        swipeLeftImpact: {
          ScenarioImpact.financial: 1800,
        },
        swipeRightLabel: 'Premium',
        swipeLeftLabel: 'Regular',
        consequence: 'Great look, 6x price',
        benefit: 'Same result, ₹1500 saved',
      ),

      // TECH & GADGETS
      SpendingScenario(
        id: 'tech_1',
        title: 'New Phone Temptation',
        description: 'iPhone 15 on sale: ₹65,000. Your current phone works fine but is 2 years old.',
        cost: 65000,
        category: ScenarioCategory.tech,
        emoji: '📱',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 25,
          ScenarioImpact.social: 10,
          ScenarioImpact.financial: -65000,
        },
        swipeLeftImpact: {
          ScenarioImpact.shortTerm: -12,
          ScenarioImpact.financial: 65000,
        },
        swipeRightLabel: 'Upgrade',
        swipeLeftLabel: 'Wait 1 year',
        consequence: 'Newest tech, massive expense',
        benefit: 'Saved huge, practice patience',
      ),

      SpendingScenario(
        id: 'tech_2',
        title: 'Mechanical Keyboard',
        description: 'Premium mechanical keyboard for coding: ₹8,000. Current keyboard is membrane type.',
        cost: 8000,
        category: ScenarioCategory.tech,
        emoji: '⌨️',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 15,
          ScenarioImpact.longTerm: 10,
          ScenarioImpact.financial: -8000,
        },
        swipeLeftImpact: {
          ScenarioImpact.financial: 8000,
        },
        swipeRightLabel: 'Buy it',
        swipeLeftLabel: 'Current is fine',
        consequence: 'Better typing, pricey luxury',
        benefit: 'Function over aesthetics',
      ),

      SpendingScenario(
        id: 'tech_3',
        title: 'Gaming Console',
        description: 'PS5 available: ₹50,000. You mostly game on PC anyway.',
        cost: 50000,
        category: ScenarioCategory.tech,
        emoji: '🎮',
        swipeRightImpact: {
          ScenarioImpact.shortTerm: 30,
          ScenarioImpact.financial: -50000,
        },
        swipeLeftImpact: {
          ScenarioImpact.shortTerm: -15,
          ScenarioImpact.financial: 50000,
        },
        swipeRightLabel: 'Get console',
        swipeLeftLabel: 'Stick to PC',
        consequence: 'Exclusive games, huge cost',
        benefit: 'Avoided duplicate expense',
      ),

      // EMERGENCY & UNEXPECTED
      SpendingScenario(
        id: 'emergency_1',
        title: 'Laptop Repair',
        description: 'Laptop screen cracked. Repair costs ₹12,000. Need it for college work.',
        cost: 12000,
        category: ScenarioCategory.emergency,
        emoji: '💻',
        swipeRightImpact: {
          ScenarioImpact.longTerm: 20,
          ScenarioImpact.financial: -12000,
        },
        swipeLeftImpact: {
          ScenarioImpact.longTerm: -25,
          ScenarioImpact.financial: 12000,
        },
        swipeRightLabel: 'Repair it',
        swipeLeftLabel: 'Delay',
        consequence: 'Functional again, unplanned expense',
        benefit: 'Risk college work, saved money',
      ),

      SpendingScenario(
        id: 'emergency_2',
        title: 'Medical Check-up',
        description: 'Persistent headaches. Doctor consultation + tests: ₹3,000. Could be nothing.',
        cost: 3000,
        category: ScenarioCategory.emergency,
        emoji: '🏥',
        swipeRightImpact: {
          ScenarioImpact.longTerm: 25,
          ScenarioImpact.financial: -3000,
        },
        swipeLeftImpact: {
          ScenarioImpact.longTerm: -20,
          ScenarioImpact.financial: 3000,
        },
        swipeRightLabel: 'Get checked',
        swipeLeftLabel: 'Self-medicate',
        consequence: 'Peace of mind, cost involved',
        benefit: 'Risky, might worsen',
      ),

      SpendingScenario(
        id: 'transport_1',
        title: 'Used Bike Purchase',
        description: 'Friend selling bike for ₹35,000. Would save ₹2,000/month on transport long-term.',
        cost: 35000,
        category: ScenarioCategory.transport,
        emoji: '🏍️',
        swipeRightImpact: {
          ScenarioImpact.longTerm: 30,
          ScenarioImpact.financial: -35000,
        },
        swipeLeftImpact: {
          ScenarioImpact.longTerm: -10,
          ScenarioImpact.financial: 35000,
        },
        swipeRightLabel: 'Buy bike',
        swipeLeftLabel: 'Public transport',
        consequence: 'Long-term savings, big upfront',
        benefit: 'No maintenance costs',
      ),
    ];
  }

  static List<SpendingScenario> getRandomScenarios({int count = 15}) {
    final allScenarios = getAllScenarios();
    final shuffled = List<SpendingScenario>.from(allScenarios)..shuffle(Random());
    return shuffled.take(count).toList();
  }
}
