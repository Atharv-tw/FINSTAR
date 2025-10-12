import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../shared/widgets/blur_dock.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                          'Profile',
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
                        'Profile\nComing Soon',
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
                  NavItem(icon: Icons.videogame_asset_rounded, label: 'Play Games', route: '/game'),
                  NavItem(icon: Icons.leaderboard_rounded, label: 'Leaderboard', route: '/rewards'),
                  NavItem(icon: Icons.person_rounded, label: 'Profile', route: '/profile'),
                ],
                selectedIndex: 3,
                showFab: false,
                onItemTap: (index) {
                  final routes = ['/', '/game', '/rewards', '/profile'];
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
