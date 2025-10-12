import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../models/spending_scenario.dart';
import 'life_swipe_result_screen.dart';

class LifeSwipeGameScreen extends StatefulWidget {
  const LifeSwipeGameScreen({super.key});

  @override
  State<LifeSwipeGameScreen> createState() => _LifeSwipeGameScreenState();
}

class _LifeSwipeGameScreenState extends State<LifeSwipeGameScreen>
    with TickerProviderStateMixin {
  List<SpendingScenario> scenarios = [];
  int currentIndex = 0;
  double dragDistance = 0;
  double dragAngle = 0;
  bool isDragging = false;
  bool hasStarted = false;

  // Game state
  int totalBudget = 20000; // Starting monthly budget
  int currentBudget = 20000;
  int savedMoney = 0;
  int spentMoney = 0;
  int happinessScore = 50;
  int disciplineScore = 50;
  int socialScore = 50;
  int futureScore = 50;

  List<Map<String, dynamic>> decisions = [];

  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      scenarios = SpendingScenario.getRandomScenarios(count: 15);
      hasStarted = true;
      currentIndex = 0;
      currentBudget = totalBudget;
      savedMoney = 0;
      spentMoney = 0;
      happinessScore = 50;
      disciplineScore = 50;
      socialScore = 50;
      futureScore = 50;
      decisions.clear();
    });
  }

  void _handleSwipe(bool swipedRight) {
    if (currentIndex >= scenarios.length) return;

    final scenario = scenarios[currentIndex];
    final impact = swipedRight ? scenario.swipeRightImpact : scenario.swipeLeftImpact;

    // Update scores
    setState(() {
      if (swipedRight) {
        spentMoney += scenario.cost;
        currentBudget -= scenario.cost;
      } else {
        savedMoney += scenario.cost;
      }

      // Update individual scores based on impact
      happinessScore = (happinessScore + (impact[ScenarioImpact.shortTerm] ?? 0))
          .clamp(0, 100);
      disciplineScore = swipedRight
          ? (disciplineScore - 5).clamp(0, 100)
          : (disciplineScore + 5).clamp(0, 100);
      socialScore = (socialScore + (impact[ScenarioImpact.social] ?? 0))
          .clamp(0, 100);
      futureScore = (futureScore + (impact[ScenarioImpact.longTerm] ?? 0))
          .clamp(0, 100);

      decisions.add({
        'scenario': scenario,
        'accepted': swipedRight,
        'budgetAfter': currentBudget,
      });
    });

    // Animate card away
    _cardAnimationController.forward(from: 0).then((_) {
      setState(() {
        currentIndex++;
        dragDistance = 0;
        dragAngle = 0;

        if (currentIndex >= scenarios.length) {
          _showResults();
        }
      });
    });
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LifeSwipeResultScreen(
          totalBudget: totalBudget,
          remainingBudget: currentBudget,
          spentMoney: spentMoney,
          savedMoney: savedMoney,
          happinessScore: happinessScore,
          disciplineScore: disciplineScore,
          socialScore: socialScore,
          futureScore: futureScore,
          decisions: decisions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: hasStarted ? _buildGameScreen() : _buildInstructionsScreen(),
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Life Swipe',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Real choices. Real consequences.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentYellow.withOpacity(0.2),
                        AppTheme.warningColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentYellow.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '₹20,000',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.accentYellow,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Monthly Budget',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pocket money + internship earnings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // How to play
                Text(
                  'How It Works',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                _buildInstructionItem(
                  icon: Icons.swipe_right,
                  title: 'Swipe Right = Spend',
                  description: 'Accept the expense. Enjoy now, pay later.',
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  icon: Icons.swipe_left,
                  title: 'Swipe Left = Save',
                  description: 'Skip the expense. Be disciplined, build wealth.',
                  color: AppTheme.successColor,
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  icon: Icons.trending_up,
                  title: 'Track Your Stats',
                  description: 'Every choice affects happiness, discipline, social life & future.',
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 32),

                // Warning box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These are REAL scenarios Indian teens face. Choose wisely!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Start button
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Swiping',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.swipe, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    if (currentIndex >= scenarios.length) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildGameHeader(),
        _buildProgressBar(),
        Expanded(
          child: _buildCardStack(),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                '₹${currentBudget.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentBudget < 5000
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                    ),
              ),
              Text(
                'Budget Left',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentIndex + 1}/${scenarios.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentIndex + 1) / scenarios.length;
    return Container(
      height: 4,
      color: Colors.grey[200],
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Next card preview
            if (currentIndex + 1 < scenarios.length)
              Transform.scale(
                scale: 0.9,
                child: Opacity(
                  opacity: 0.5,
                  child: _buildCard(scenarios[currentIndex + 1], false),
                ),
              ),
            // Current card
            _buildDraggableCard(scenarios[currentIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableCard(SpendingScenario scenario) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          isDragging = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          dragDistance += details.delta.dx;
          dragAngle = dragDistance / 1000;
        });
      },
      onPanEnd: (details) {
        setState(() {
          isDragging = false;
          if (dragDistance.abs() > 100) {
            _handleSwipe(dragDistance > 0);
          }
          dragDistance = 0;
          dragAngle = 0;
        });
      },
      child: Transform.translate(
        offset: Offset(dragDistance, 0),
        child: Transform.rotate(
          angle: dragAngle,
          child: _buildCard(scenario, true),
        ),
      ),
    );
  }

  Widget _buildCard(SpendingScenario scenario, bool showOverlay) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(scenario.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getCategoryName(scenario.category),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(scenario.category),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      scenario.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scenario content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        scenario.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        scenario.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),

                // Cost
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${scenario.cost.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Swipe overlays
          if (showOverlay && dragDistance.abs() > 50)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: (dragDistance > 0
                          ? AppTheme.errorColor
                          : AppTheme.successColor)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: dragDistance > 0 ? -0.3 : 0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dragDistance > 0
                              ? AppTheme.errorColor
                              : AppTheme.successColor,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dragDistance > 0 ? 'SPEND' : 'SAVE',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: dragDistance > 0
                                  ? AppTheme.errorColor
                                  : AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Save button
          _buildActionButton(
            icon: Icons.close,
            color: AppTheme.successColor,
            onPressed: () => _handleSwipe(false),
          ),
          // Spend button
          _buildActionButton(
            icon: Icons.favorite,
            color: AppTheme.errorColor,
            onPressed: () => _handleSwipe(true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(35),
          child: Center(
            child: Icon(icon, color: color, size: 32),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ScenarioCategory category) {
    switch (category) {
      case ScenarioCategory.food:
        return const Color(0xFFFF6B6B);
      case ScenarioCategory.entertainment:
        return const Color(0xFF9B59B6);
      case ScenarioCategory.social:
        return const Color(0xFF3498DB);
      case ScenarioCategory.education:
        return const Color(0xFF2ECC71);
      case ScenarioCategory.fashion:
        return const Color(0xFFE91E63);
      case ScenarioCategory.tech:
        return const Color(0xFF607D8B);
      case ScenarioCategory.transport:
        return const Color(0xFFF39C12);
      case ScenarioCategory.emergency:
        return const Color(0xFFE74C3C);
    }
  }

  String _getCategoryName(ScenarioCategory category) {
    switch (category) {
      case ScenarioCategory.food:
        return 'Food & Dining';
      case ScenarioCategory.entertainment:
        return 'Entertainment';
      case ScenarioCategory.social:
        return 'Social';
      case ScenarioCategory.education:
        return 'Education';
      case ScenarioCategory.fashion:
        return 'Fashion';
      case ScenarioCategory.tech:
        return 'Tech';
      case ScenarioCategory.transport:
        return 'Transport';
      case ScenarioCategory.emergency:
        return 'Emergency';
    }
  }
}
