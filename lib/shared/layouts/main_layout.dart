import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/fixed_bottom_nav.dart';

/// Main layout wrapper with shared bottom navigation bar
class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Navigation routes mapping
  final List<String> _routes = [
    '/',           // Home
    '/game',       // Play Games
    '/rewards',    // Leaderboard
    '/profile',    // Profile
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _routes.length; i++) {
      if (location == _routes[i]) {
        if (_currentIndex != i) {
          setState(() {
            _currentIndex = i;
          });
        }
        break;
      }
    }
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      context.go(_routes[index]);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: FixedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
