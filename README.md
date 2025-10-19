# Finstar - Financial Literacy Gaming App

A gamified financial literacy mobile application built with Flutter that makes learning about personal finance fun and engaging for teenagers and young adults.

## Overview

Finstar combines education with entertainment through interactive games, challenges, and a social learning environment. Users can build financial knowledge while competing with friends, earning rewards, and tracking their progress.

## Features

### Core Features
- **Interactive Learning Modules**: Comprehensive lessons on budgeting, saving, investing, and financial planning
- **Gamified Experience**: Level up, earn XP, and unlock achievements
- **Daily Streaks**: Build consistent learning habits with daily challenges
- **Social Features**: Connect with friends, compare progress, and compete on leaderboards

### Games
1. **Budget Blitz**: Fast-paced expense management game teaching budgeting skills
2. **Life Swipe**: Decision-based game simulating real-life financial scenarios
3. **Market Explorer**: Stock market simulation with portfolio allocation and trading
4. **Quiz Battle**: Test financial knowledge through timed quiz challenges

### Progress Tracking
- XP and level progression system
- Detailed statistics and analytics
- Achievement badges and rewards
- Streak tracking and milestones

## Tech Stack

- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI Components**: Material Design 3
- **Fonts**: Google Fonts
- **Animations**: Lottie, Rive
- **Charts**: FL Chart
- **Additional Libraries**: Shimmer, Cached Network Image

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Atharv-tw/FINSTAR.git
cd FINSTAR
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

**Android**:
```bash
flutter build apk --release
```

**iOS**:
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── app/                    # App-level configuration
│   └── router.dart        # Navigation routes
├── core/                  # Core utilities and themes
│   ├── app_theme.dart
│   ├── design_tokens.dart
│   └── motion_tokens.dart
├── data/                  # Data models and mock data
│   ├── learning_modules_data.dart
│   └── user_data.dart
├── features/              # Feature modules
│   ├── friends/          # Social features
│   ├── games/            # Game implementations
│   │   ├── budget_blitz/
│   │   ├── life_swipe/
│   │   ├── market_explorer/
│   │   └── quiz_battle/
│   ├── home/             # Home screen
│   ├── leaderboard/      # Rankings
│   ├── learn/            # Learning section
│   ├── learning/         # Module details
│   ├── profile/          # User profile
│   └── rewards/          # Achievements
├── models/                # Data models
│   ├── game_progress_model.dart
│   ├── learning_module.dart
│   └── user_profile.dart
├── services/              # Business logic services
│   ├── local_storage_service.dart
│   └── mascot_service.dart
├── shared/                # Shared components
│   ├── layouts/
│   └── widgets/
└── main.dart             # App entry point
```

## Key Features Detail

### Learning System
- Modular content covering essential financial topics
- Progressive difficulty levels
- Interactive lessons with real-world examples
- Quiz assessments for knowledge validation

### Gamification
- XP-based progression system
- Daily login streaks and bonuses
- Achievement system with badges
- Leaderboards for competitive learning

### Games Overview

**Budget Blitz**: Players manage a virtual budget, making quick decisions about expenses while balancing needs vs wants under time pressure.

**Life Swipe**: Swipe-based decision game presenting financial scenarios where users choose between different financial paths and see immediate consequences.

**Market Explorer**: Hands-on stock market simulation where users learn about diversification, risk management, and investment strategies.

**Quiz Battle**: Competitive quiz format testing financial knowledge with immediate feedback and score tracking.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Development Roadmap

- [ ] User authentication and profiles
- [ ] Cloud data synchronization
- [ ] More game modes
- [ ] Parental controls
- [ ] Achievement sharing
- [ ] Real-world reward partnerships
- [ ] AI-powered financial advisor

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors and testers
- Financial education resources that inspired the content

## Contact

For questions or feedback, please open an issue on GitHub.

---

Made with Flutter
