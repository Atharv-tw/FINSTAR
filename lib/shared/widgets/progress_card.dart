import 'dart:math' as math; // Import math library

import 'package:flutter/material.dart';
import '../../providers/user_provider.dart';

class ProgressCard extends StatelessWidget {
  final UserProfile user;

  const ProgressCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = _badgeLabelForStreak(user.streakDays);
    final maskedId = _maskedId(user.id);
    return AspectRatio(
      aspectRatio: 85.60 / 53.98, // Credit card aspect ratio
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8DB5D6), Color(0xFF7CAFD9)], // New blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack( // Use a Stack to layer decorative elements
          children: [
            // Decorative elements
            Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: math.pi / 4, // Tilted vertically
                child: Container(
                  width: 250, // width
                  height: 50, // height
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.9), // Further increased vertical offset
              child: Transform.rotate(
                angle: math.pi / 4, // Tilted vertically
                child: Container(
                  width: 350, // width
                  height: 70, // height
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Card content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Row for Chip and Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip
                    Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFADD8E6).withValues(alpha: 0.8), // Light blue chip
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Logo
                    const Text(
                      'FINSTAR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                // Card Number
                Text(
                  'ID •••• $maskedId',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
                // Row for Cardholder Name and Valid Thru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cardholder Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BADGE',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          badgeLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Balance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BALANCE',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${user.coins} COINS',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _badgeLabelForStreak(int streakDays) {
    if (streakDays >= 90) {
      return 'FINANCE PRO';
    }
    if (streakDays >= 60) {
      return 'MONEY MASTER';
    }
    if (streakDays >= 30) {
      return 'BUDGET BOSS';
    }
    if (streakDays >= 14) {
      return 'SAVINGS STAR';
    }
    if (streakDays >= 7) {
      return 'SMART SPENDER';
    }
    if (streakDays >= 3) {
      return 'ROOKIE EARNER';
    }
    return 'BEGINNER';
  }

  String _maskedId(String id) {
    if (id.isEmpty) return '0000';
    final tail = id.length >= 4 ? id.substring(id.length - 4) : id;
    return tail.toUpperCase();
  }
}
