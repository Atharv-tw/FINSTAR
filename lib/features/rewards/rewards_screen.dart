import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../shared/widgets/blur_dock.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.backgroundGradient,
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.spacingLG),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.go('/'),
                        ),
                        const Text(
                          'Rewards & Badges',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Rewards & Badges\nComing Soon',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlurDock(
                items: const [
                  NavItem(icon: Icons.home_rounded, label: 'Home', route: '/'),
                  NavItem(icon: Icons.school_rounded, label: 'Learn', route: '/learn'),
                  NavItem(icon: Icons.people_rounded, label: 'Friends', route: '/friends'),
                  NavItem(icon: Icons.person_rounded, label: 'Profile', route: '/profile'),
                ],
                selectedIndex: 0,
                onItemTap: (index) {
                  final routes = ['/', '/learn', '/friends', '/profile'];
                  context.go(routes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
