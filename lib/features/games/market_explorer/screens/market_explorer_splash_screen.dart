import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketExplorerSplashScreen extends StatelessWidget {
  const MarketExplorerSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF022E17), Color(0xFF9BAD50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0), // Reduced horizontal padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center align all texts
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFF6EDA3), size: 30),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
                const Spacer(),
                // Main Heading
                Transform.translate(
                  offset: const Offset(0, -75), // Pushed further up by 30 pixels
                  child: Text(
                    'Market Explorer',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF6EDA3),
                    ),
                  ),
                ),
                const SizedBox(height: 5), // Spacing after main heading
                // Sub Heading
                Transform.translate(
                  offset: const Offset(0, -45), // Pushed up by 30 pixels
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Invest wisely and watch your portfolio grow over 5 years',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: const Color(0xFFF6EDA3).withAlpha((0.8 * 255).round()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Difficulty Heading
                Text(
                  'Select Difficulty',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF6EDA3),
                  ),
                ),
                const SizedBox(height: 30), // Increased height to shift boxes down
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDifficultyBox(context, 'Easy', '15000'),
                    _buildDifficultyBox(context, 'Medium', '10000'),
                    _buildDifficultyBox(context, 'Hard', '8000'),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBox(BuildContext context, String difficulty, String rupees) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to Market Explorer game with selected difficulty
          context.push('/game/market-explorer/allocation', extra: {'difficulty': difficulty, 'initialInvestment': int.parse(rupees)});
        },
        child: SizedBox(
          height: 150.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF393027).withAlpha((0.5 * 255).round()),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFF6EDA3).withAlpha((0.3 * 255).round()), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  difficulty,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF6EDA3),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$rupees Rupees',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFB6CFE4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
