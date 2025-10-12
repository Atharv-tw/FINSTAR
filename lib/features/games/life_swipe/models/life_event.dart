class LifeEvent {
  final String id;
  final String title;
  final String description;
  final LifeEventType type;
  final double impact; // Amount of money affected
  final String affectedCategory; // Which jar is affected

  LifeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.affectedCategory,
  });

  // Predefined life events
  static List<LifeEvent> getAllEvents() {
    return [
      // Negative Events
      LifeEvent(
        id: 'laptop_broke',
        title: '💻 Laptop Broke!',
        description: 'Your laptop stopped working and needs repair',
        type: LifeEventType.expense,
        impact: 3000,
        affectedCategory: 'savings',
      ),
      LifeEvent(
        id: 'phone_cracked',
        title: '📱 Phone Screen Cracked',
        description: 'You dropped your phone and the screen cracked',
        type: LifeEventType.expense,
        impact: 1500,
        affectedCategory: 'savings',
      ),
      LifeEvent(
        id: 'medical_emergency',
        title: '🏥 Medical Emergency',
        description: 'Unexpected medical expense',
        type: LifeEventType.expense,
        impact: 2000,
        affectedCategory: 'savings',
      ),
      LifeEvent(
        id: 'book_fair',
        title: '📚 Book Fair',
        description: 'Amazing book fair with your favorite books on sale',
        type: LifeEventType.temptation,
        impact: 1000,
        affectedCategory: 'wants',
      ),
      LifeEvent(
        id: 'concert_tickets',
        title: '🎵 Concert Tickets',
        description: 'Your favorite artist is performing in town',
        type: LifeEventType.temptation,
        impact: 2000,
        affectedCategory: 'wants',
      ),
      LifeEvent(
        id: 'new_game',
        title: '🎮 New Game Release',
        description: 'The game you\'ve been waiting for is finally out!',
        type: LifeEventType.temptation,
        impact: 1500,
        affectedCategory: 'wants',
      ),

      // Positive Events
      LifeEvent(
        id: 'birthday_money',
        title: '🎂 Birthday Gift',
        description: 'You received money as a birthday gift!',
        type: LifeEventType.income,
        impact: 2000,
        affectedCategory: 'bonus',
      ),
      LifeEvent(
        id: 'competition_prize',
        title: '🏆 Competition Prize',
        description: 'You won a school competition!',
        type: LifeEventType.income,
        impact: 1500,
        affectedCategory: 'bonus',
      ),
      LifeEvent(
        id: 'freelance_work',
        title: '💼 Freelance Project',
        description: 'You completed a small freelance project',
        type: LifeEventType.income,
        impact: 1000,
        affectedCategory: 'bonus',
      ),

      // Learning Events
      LifeEvent(
        id: 'investment_opportunity',
        title: '📈 Investment Tip',
        description: 'A friend suggested a good investment opportunity',
        type: LifeEventType.opportunity,
        impact: 500,
        affectedCategory: 'investments',
      ),
      LifeEvent(
        id: 'savings_challenge',
        title: '💰 Savings Challenge',
        description: 'Join a savings challenge with friends',
        type: LifeEventType.opportunity,
        impact: 1000,
        affectedCategory: 'savings',
      ),
    ];
  }

  static LifeEvent getRandomEvent() {
    final events = getAllEvents();
    events.shuffle();
    return events.first;
  }

  // Get events by type
  static List<LifeEvent> getEventsByType(LifeEventType type) {
    return getAllEvents().where((event) => event.type == type).toList();
  }
}

enum LifeEventType {
  expense, // Negative - forces spending
  temptation, // Optional spending - tests willpower
  income, // Positive - bonus money
  opportunity, // Bonus for good planning
}
