import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/learning_progress_provider.dart';
import '../../core/design_tokens.dart';

class FinanceTilesSection extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  FinanceTilesSection({super.key, this.scrollController});

  @override
  ConsumerState<FinanceTilesSection> createState() => _FinanceTilesSectionState();
}

class _FinanceTilesSectionState extends ConsumerState<FinanceTilesSection> {
  // Define the modules data
  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Money Basics',
      'moduleId': 'money_basics',
      'color': const Color(0xFF9BAD50), // Brand Green
      'icon': Icons.savings_rounded,
    },
    {
      'title': 'Earning & Career',
      'moduleId': 'earning_career',
      'color': const Color(0xFFB6CFE4), // Periwinkle
      'icon': Icons.work_rounded,
    },
    {
      'title': 'Investing & Growth',
      'moduleId': 'investing',
      'color': const Color(0xFFE8D4BA), // Warm Beige
      'icon': Icons.trending_up_rounded,
    },
    {
      'title': 'Banking & Institutes',
      'moduleId': 'banking',
      'color': const Color(0xFF393027), // Dark Cocoa
      'icon': Icons.account_balance_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get real progress to determine current module (not strictly used for layout but good for state)
    // We can use this to visually highlight completed vs locked if needed later.
    // For now, we just display the grid.
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional Header if needed, otherwise just the grid
          
          // 2x2 Grid with connector
          Stack(
            children: [
              // 1. Connector Line (Behind the tiles)
              Positioned.fill(
                child: CustomPaint(
                  painter: _ConnectorPathPainter(
                    itemCount: modules.length,
                    columns: 2,
                  ),
                ),
              ),

              // 2. The Grid of Tiles
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Square tiles
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return _ModuleSquareTile(
                    module: module,
                    index: index,
                    onTap: () => context.push('/module/${module['moduleId']}'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleSquareTile extends StatefulWidget {
  final Map<String, dynamic> module;
  final int index;
  final VoidCallback onTap;

  const _ModuleSquareTile({
    required this.module,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ModuleSquareTile> createState() => _ModuleSquareTileState();
}

class _ModuleSquareTileState extends State<_ModuleSquareTile> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.module['color'] as Color;
    final title = widget.module['title'] as String;
    final iconData = widget.module['icon'] as IconData;
    
    // Determine text color based on background luminance or specific design choice
    // For our palette: 
    // Matcha Green (Light) -> Dark text
    // Periwinkle (Light) -> Dark text
    // Beige (Light) -> Dark text
    // Cocoa (Dark) -> White text
    final isDarkBg = color.computeLuminance() < 0.5;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF393027);

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon / Image
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Icon(
                          iconData,
                          size: 48,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Expanded(
                      flex: 2,
                      child: Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 18, // Reduced slightly to fit square
                          color: textColor,
                          height: 1.1,
                          letterSpacing: 0.5,
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
    );
  }
}

class _ConnectorPathPainter extends CustomPainter {
  final int itemCount;
  final int columns;

  _ConnectorPathPainter({
    required this.itemCount,
    required this.columns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount <= 1) return;

    final paint = Paint()
      ..color = const Color(0xFF393027).withValues(alpha: 0.15) // Subtle dark connector
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final dashPath = Path();
    
    // We assume a regular grid where we know the rough center of each item
    // itemWidth = (totalWidth - spacing) / 2
    // itemHeight = itemWidth (since aspect ratio is 1)
    
    final double spacing = 16.0;
    final double itemWidth = (size.width - spacing) / 2;
    final double itemHeight = itemWidth; // Square tiles

    // Helper to get center of item at index
    Offset getCenter(int index) {
      final int row = index ~/ columns;
      final int col = index % columns;
      
      final double x = col * (itemWidth + spacing) + itemWidth / 2;
      final double y = row * (itemHeight + spacing) + itemHeight / 2;
      return Offset(x, y);
    }

    // Draw lines connecting 0->1, 1->2, 2->3
    for (int i = 0; i < itemCount - 1; i++) {
      final p1 = getCenter(i);
      final p2 = getCenter(i + 1);
      
      // Simple direct connection? Or curvy?
      // 0 -> 1 is horizontal.
      // 1 -> 2 is diagonal (down-left).
      // 2 -> 3 is horizontal.
      
      if (i == 1) {
        // Diagonal connection 1 -> 2 (Zig-zag)
        // Let's make it a nice 'S' curve or direct diagonal
        final path = Path();
        path.moveTo(p1.dx, p1.dy);
        
        // Control points for a smooth 'S' curve down
        final double cp1x = p1.dx;
        final double cp1y = (p1.dy + p2.dy) / 2;
        final double cp2x = p2.dx;
        final double cp2y = (p1.dy + p2.dy) / 2;
        
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
        dashPath.addPath(path, Offset.zero);
      } else {
        // Horizontal connection (0->1, 2->3)
        dashPath.moveTo(p1.dx, p1.dy);
        dashPath.lineTo(p2.dx, p2.dy);
      }
    }

    // Draw dashed line
    // We create a dashed effect manually or use a helper
    // Simple manual dash:
    final PathMetrics metrics = dashPath.computeMetrics();
    for (PathMetric metric in metrics) {
      double distance = 0.0;
      const double dashLength = 10.0;
      const double gapLength = 8.0;
      
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}