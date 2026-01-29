import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/learning_modules_data.dart';
import '../../models/learning_module.dart';

// Provided color palette
const Color mossGreen = Color(0xFF8D9F37);
const Color powderBlue = Color(0xFFA2C1DF);
const Color forest = Color(0xFF0F190C);
const Color vanDyke = Color(0xFF393027);
const Color offWhite = Color(0xFFF8F5F2);

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = LearningModulesData.allModules;

    return Scaffold(
      backgroundColor: forest,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  // Cycle through a few predefined card styles
                  final styleIndex = index % 3;
                  return _ModuleCard(module: module, styleIndex: styleIndex);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: offWhite, size: 28),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 10),
          Text(
            'Choose Your Adventure',
            style: GoogleFonts.luckiestGuy(
              fontSize: 26,
              color: offWhite,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final LearningModule module;
  final int styleIndex;

  const _ModuleCard({required this.module, required this.styleIndex});

  @override
  Widget build(BuildContext context) {
    final cardData = _getCardStyle(styleIndex);

    return GestureDetector(
      onTap: () => context.go('/module/${module.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardData['background'],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: cardData['borderColor'], width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
            BoxShadow(
              color: cardData['background'].withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: -5,
              offset: const Offset(-4, -4),
            )
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              module.iconPath,
              width: 70,
              height: 70,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.school, size: 70, color: offWhite),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title.split(' ').last, // "Basics", "Banking", etc.
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 28,
                      color: cardData['titleColor'],
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    module.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: cardData['textColor'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCardStyle(int index) {
    switch (index) {
      case 0:
        return {
          'background': mossGreen,
          'borderColor': Color.alphaBlend(Colors.white.withValues(alpha: 0.3), mossGreen),
          'titleColor': forest,
          'textColor': vanDyke.withValues(alpha: 0.8),
        };
      case 1:
        return {
          'background': powderBlue,
          'borderColor': Color.alphaBlend(Colors.white.withValues(alpha: 0.3), powderBlue),
          'titleColor': forest,
          'textColor': vanDyke.withValues(alpha: 0.8),
        };
      case 2:
      default:
        return {
          'background': vanDyke,
          'borderColor': Color.alphaBlend(Colors.white.withValues(alpha: 0.2), vanDyke),
          'titleColor': offWhite,
          'textColor': offWhite.withValues(alpha: 0.7),
        };
    }
  }
}
