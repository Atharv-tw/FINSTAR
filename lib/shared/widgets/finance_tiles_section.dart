import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/learning_progress_provider.dart';

class FinanceTilesSection extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  FinanceTilesSection({super.key, this.scrollController});

  @override
  ConsumerState<FinanceTilesSection> createState() => _FinanceTilesSectionState();
}

class _FinanceTilesSectionState extends ConsumerState<FinanceTilesSection> with TickerProviderStateMixin {
  late AnimationController _controller;
  double _scrollProgress = 0.0;
  final GlobalKey _sectionKey = GlobalKey();

  // Define the modules data
  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Money\nBasics',
      'moduleId': 'money_basics',
      'color': const Color(0xFFB3E5FC), // Light Blue
      'image': 'assets/images/money_basics_panda.png',
      'isLeft': true,
    },
    {
      'title': 'Earning &\nCareer',
      'moduleId': 'earning_career',
      'color': const Color(0xFFA9FF68), // Green
      'image': 'assets/images/earning_career_latest.png',
      'isLeft': false,
    },
    {
      'title': 'Investing &\nGrowth',
      'moduleId': 'investing',
      'color': const Color(0xFF00E5FF), // Teal (Updated for premium theme)
      'image': 'assets/images/investing_growth_floating.png',
      'isLeft': true,
    },
    {
      'title': 'Banking &\nInstitutes',
      'moduleId': 'banking',
      'color': const Color(0xFF536DFE), // Indigo (Updated for premium theme)
      'image': 'assets/images/bankkk.png',
      'isLeft': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    widget.scrollController?.addListener(_onScroll);

    // Initialize scroll position after first frame to ensure car starts at beginning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  double? _initialScrollOffset;

  void _onScroll() {
    if (!mounted || widget.scrollController == null) return;

    final RenderBox? box = _sectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final position = box.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.of(context).size.height;
    final sectionTop = position.dy;
    final sectionHeight = box.size.height;

    // Store the initial offset when first called (to handle pre-scrolled state)
    _initialScrollOffset ??= sectionTop;

    // Calculate how much we've scrolled SINCE the initial state
    final scrolledSinceStart = _initialScrollOffset! - sectionTop;

    // Total scrollable distance for car to complete the journey
    final totalScrollDistance = sectionHeight * 0.75;

    double progress = scrolledSinceStart / totalScrollDistance;

    setState(() {
      _scrollProgress = progress.clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get real progress to determine current module
    final progressAsync = ref.watch(learningProgressProvider);
    int currentModuleIndex = 0;

    progressAsync.whenData((progressMap) {
      for (int i = 0; i < modules.length; i++) {
        final mid = modules[i]['moduleId'];
        // Assume 5 lessons per module for now as per provider logic
        bool moduleCompleted = true;
        for (int l = 1; l <= 5; l++) {
          if (!(progressMap['${mid}_lesson$l']?.completed ?? false)) {
            moduleCompleted = false;
            break;
          }
        }
        if (!moduleCompleted) {
          currentModuleIndex = i;
          break;
        }
        // If all modules completed, last one stays active or none
        if (i == modules.length - 1) currentModuleIndex = i;
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // COMPACT LAYOUT: Reduced spacing between modules
        final double rowHeight = width * 0.6;
        final double startOffset = 80.0;
        // Precisely calculated height to stop scrolling exactly after the trophy
        // Spacing is now equal: Distance between modules = rowHeight, Distance to trophy = rowHeight
        final double sectionHeight = (modules.length + 0.5) * rowHeight + startOffset + 180;

        final List<Offset> pathPoints = [];
        for (int i = 0; i < modules.length; i++) {
          final isEven = i % 2 == 0;
          
          // Accounting for the 20px total horizontal padding in _ModuleSectionBanner
          final contentWidth = width - 20; 
          double x;
          
          if (isEven) {
            // Image on left (flex 46) starts after 4px left padding.
            // Right edge of image = 4 + contentWidth * 0.46.
            final imageRightEdge = 4 + (contentWidth * 0.46);
            x = imageRightEdge + 14; // Center x to touch edge
          } else {
            // Image on right. Text(44) and Spacer(10) come after 16px left padding.
            // Left edge of image = 16 + contentWidth * 0.54.
            final imageLeftEdge = 16 + (contentWidth * 0.54);
            x = imageLeftEdge - 14; // Center x to touch edge
          }
          
          final y = (i * rowHeight) + (rowHeight / 2) + startOffset; 
          pathPoints.add(Offset(x, y));
        }

        return Container(
          key: _sectionKey,
          padding: const EdgeInsets.symmetric(vertical: 20),
          height: sectionHeight,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 0. Background Decorative Elements
              _buildBackgroundDecorations(width, rowHeight),

              // 1. Refined Road Route Line
              CustomPaint(
                size: Size(width, sectionHeight),
                painter: _RoadPathPainter(
                  points: pathPoints,
                  animationValue: _controller,
                  currentIndex: currentModuleIndex,
                  scrollProgress: _scrollProgress,
                  rowHeight: rowHeight,
                ),
              ),

              // 2. Module Rows
              Column(
                children: [
                  SizedBox(height: startOffset),
                  ...modules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final module = entry.value;
                    final isEven = index % 2 == 0;
                    final isCurrent = index == currentModuleIndex;
                    
                    return SizedBox(
                      height: rowHeight,
                      child: _ModuleSectionBanner(
                        module: module,
                        isImageLeft: isEven, 
                        onTap: () => context.push('/module/${module['moduleId']}'),
                        animationController: _controller,
                        index: index,
                        isCurrent: isCurrent,
                      ),
                    );
                  }),
                ],
              ),

              // 1.5. Road Markers (Moved to top for visibility)
              _buildRoadMarkers(pathPoints, currentModuleIndex, width, rowHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoadMarkers(List<Offset> points, int currentIndex, double width, double rowHeight) {
    // Play button at center (matching road start)
    final startPoint = Offset(width * 0.5, 30);
    
    return Stack(
      children: [
        // Actual Play Button at the Start of the Road
        Positioned(
          left: startPoint.dx - 30, // Center 60px button
          top: startPoint.dy - 30,  // Pull up by half height (30-30=0) to align top
          child: _buildStartPlayButton(),
        ),

        ...points.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          final isCompleted = index < currentIndex;
          final isLeft = index % 2 != 0;

          return Stack(
            children: [
              // Faint connection line to module (Thinner, more subtle)
              _buildConnectionLine(point, isLeft),

              // Pixel Trophy at the very end
              if (index == points.length - 1)
                Positioned(
                  left: width / 2 - 100, // Adjusted centering for the new image size
                  top: point.dy + rowHeight - 45, // Equal spacing (1.0 * rowHeight)
                  child: Image.asset(
                    'assets/images/trophy_pixel.png', 
                    width: 200, 
                    height: 200, 
                    fit: BoxFit.contain,
                  ),
                ),

              // Small Marker on the road for each module
              Positioned(
                left: point.dx - 14, 
                top: point.dy - 14,
                child: _buildSimpleRoadDot(index, isCompleted, index == currentIndex),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStartPlayButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.05).abs();
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF9100)]),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleRoadDot(int index, bool isCompleted, bool isCurrent) {
    List<Color> colors;
    Color glowColor;
    final bool isShiny = index == 0;

    switch (index) {
      case 0: // Money Basics - Brown
        colors = [
          const Color(0xFF8D6E63).withValues(alpha: 0.8), 
          const Color(0xFF6D4C41).withValues(alpha: 0.9)
        ];
        glowColor = const Color(0xFF5D4037);
        break;
      case 1: // Earning - Simple Green
        colors = [const Color(0xFF4CAF50), const Color(0xFF4CAF50)];
        glowColor = const Color(0xFF4CAF50);
        break;
      case 2: // Investing - Simple Cyan
        colors = [const Color(0xFF00ACC1), const Color(0xFF00ACC1)];
        glowColor = const Color(0xFF00ACC1);
        break;
      case 3: // Banking - Simple Indigo
        colors = [const Color(0xFF3F51B5), const Color(0xFF3F51B5)];
        glowColor = const Color(0xFF3F51B5);
        break;
      default:
        colors = [const Color(0xFF2C3E50), const Color(0xFF2C3E50)];
        glowColor = const Color(0xFF2C3E50);
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: !isShiny ? colors[0] : null,
        gradient: isShiny ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ) : null,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: isShiny ? 0.45 : 0.3), // Reduced from 0.6
            blurRadius: isShiny ? 9 : 6, // Reduced from 12
            spreadRadius: 1,
          ),
          if (isShiny)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.25), // Reduced from 0.4
              blurRadius: 3, // Reduced from 4
              offset: const Offset(-1.5, -1.5), // Softened offset
            ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8, 
          height: 8, 
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85), // Slightly reduced from 0.9
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }



  Widget _buildConnectionLine(Offset point, bool isLeft) {
    return Positioned(
      left: isLeft ? point.dx - 120 : point.dx + 20,
      top: point.dy - 1,
      child: Container(
        width: 100,
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.0),
            ],
            begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          ),
        ),
      ),
    );
  }









  Widget _buildBackgroundDecorations(double width, double rowHeight) {
    return Stack(
      children: [
        // 1. Terrain & Water (New Layers)
        Positioned(
          left: width * 0.6,
          top: rowHeight * 1.8,
          child: Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.elliptical(120, 80)),
            ),
          ),
        ),
        Positioned(
          left: width * 0.65,
          top: rowHeight * 1.9,
          child: Icon(Icons.waves_rounded, color: Colors.blue.withValues(alpha: 0.2), size: 30),
        ),

        // Tiny Trees
        Positioned(
          left: width * 0.1,
          top: rowHeight * 0.5,
          child: Icon(Icons.park_rounded, color: Colors.green.withValues(alpha: 0.3), size: 24),
        ),
        Positioned(
          right: width * 0.15,
          top: rowHeight * 1.5,
          child: Icon(Icons.park_rounded, color: Colors.teal.withValues(alpha: 0.3), size: 28),
        ),
        Positioned(
          left: width * 0.12,
          top: rowHeight * 2.8,
          child: Icon(Icons.park_rounded, color: Colors.greenAccent.withValues(alpha: 0.3), size: 22),
        ),

        // Character Shadows (Grounding)
        Positioned(left: width * 0.1, top: rowHeight * 0.8 + 28, child: _buildShadow(20)),
        Positioned(left: width * 0.15, top: rowHeight * 2.5 + 32, child: _buildShadow(25)),
        Positioned(right: width * 0.2, top: rowHeight * 3.1 + 25, child: _buildShadow(18)),

        // Flowers & Terrain (New)
        Positioned(
          left: width * 0.25,
          top: rowHeight * 0.7,
          child: Icon(Icons.local_florist_rounded, color: Colors.pink.withValues(alpha: 0.2), size: 14),
        ),
        Positioned(
          right: width * 0.25,
          top: rowHeight * 2.3,
          child: Icon(Icons.local_florist_rounded, color: Colors.orange.withValues(alpha: 0.2), size: 16),
        ),
        Positioned(
          left: width * 0.05,
          top: rowHeight * 1.2,
          child: Icon(Icons.terrain_rounded, color: Colors.brown.withValues(alpha: 0.15), size: 30),
        ),

        // Clouds
        Positioned(
          right: width * 0.05,
          top: rowHeight * 0.2,
          child: Icon(Icons.cloud_rounded, color: Colors.white.withValues(alpha: 0.15), size: 40),
        ),
        Positioned(
          left: width * 0.05,
          top: rowHeight * 2.2,
          child: Icon(Icons.cloud_rounded, color: Colors.white.withValues(alpha: 0.1), size: 36),
        ),
        // Extra Cloud
        Positioned(
          right: width * 0.1,
          top: rowHeight * 3.5,
          child: Icon(Icons.cloud_rounded, color: Colors.white.withValues(alpha: 0.12), size: 32),
        ),

        // Coins
        Positioned(
          right: width * 0.25,
          top: rowHeight * 1.1,
          child: Icon(Icons.monetization_on_rounded, color: Colors.amber.withValues(alpha: 0.4), size: 18),
        ),
        Positioned(
          left: width * 0.3,
          top: rowHeight * 3.2,
          child: Icon(Icons.monetization_on_rounded, color: Colors.amber.withValues(alpha: 0.3), size: 20),
        ),
        // Extra Coin
        Positioned(
          left: width * 0.8,
          top: rowHeight * 0.3,
          child: Icon(Icons.monetization_on_rounded, color: Colors.amber.withValues(alpha: 0.25), size: 16),
        ),

        // Characters (Variety)
        Positioned(
          left: width * 0.15,
          top: rowHeight * 2.5,
          child: Transform.scale(
            scaleX: -1,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/panda1.png', width: 35, height: 35),
            ),
          ),
        ),
        // Penguin (New - Placeholder Icon)
        Positioned(
          left: width * 0.08,
          top: rowHeight * 3.4,
          child: Icon(Icons.pets_rounded, color: Colors.blueGrey.withValues(alpha: 0.3), size: 22),
        ),
        // Tiny Rabbit (Icon)
        Positioned(
          left: width * 0.8,
          top: rowHeight * 1.8,
          child: Icon(Icons.cruelty_free_rounded, color: Colors.white.withValues(alpha: 0.2), size: 20),
        ),
        // Tiny Bird (Icon)
        Positioned(
          left: width * 0.2,
          top: rowHeight * 0.4,
          child: Icon(Icons.flutter_dash_rounded, color: Colors.white.withValues(alpha: 0.15), size: 18),
        ),
      ],
    );
  }



  Widget _buildShadow(double width) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.elliptical(20, 4)),
      ),
    );
  }
}

class _RoadPathPainter extends CustomPainter {
  final List<Offset> points;
  final Animation<double> animationValue;
  final int currentIndex;
  final double scrollProgress;
  final double rowHeight;

  _RoadPathPainter({
    required this.points,
    required this.animationValue,
    required this.currentIndex,
    required this.scrollProgress,
    required this.rowHeight,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    final startX = size.width * 0.5; // Start from center
    final startY = 30.0;
    path.moveTo(startX, startY);

    // ============================================
    // SNAKE-LIKE ROAD WITH DRAMATIC S-CURVES
    // ============================================

    final p0 = points[0];
    final double initVDist = p0.dy - startY;

    // First curve: dramatic swing from center to left side
    // Control points create a smooth S that swings wide right before going left
    path.cubicTo(
      startX + size.width * 0.35, startY + (initVDist * 0.30), // Swing far right
      startX + size.width * 0.15, p0.dy - (initVDist * 0.25),  // Then curve left
      p0.dx, p0.dy
    );

    // Module-to-module curves with dramatic snake pattern
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final double vDist = curr.dy - prev.dy;

      // Large horizontal swing creates snake-like weaving
      // Swing amount proportional to screen width for responsive design
      final double swingAmount = size.width * 0.47; // 35% of screen width swing!

      // Alternate swing direction: even indices swing right, odd swing left
      final double swingDirection = (i % 2 == 0) ? 1.0 : -1.0;
      final double midX = (prev.dx + curr.dx) / 2;
      final double swingX = midX + (swingAmount * swingDirection);

      // Create dramatic S-curve between points
      path.cubicTo(
        swingX, prev.dy + (vDist * 0.3), // Control point 1: swing out
        swingX, curr.dy - (vDist * 0.3), // Control point 2: swing back
        curr.dx, curr.dy
      );
    }

    // Final curve to trophy - same pattern as other modules
    final last = points.last;
    final endPoint = Offset(size.width / 2, last.dy + rowHeight);
    final vDistEnd = endPoint.dy - last.dy;

    // Trophy is effectively index 4 (even), so swing right like other even indices
    final double trophySwingAmount = size.width * 0.47;
    final double trophyMidX = (last.dx + endPoint.dx) / 2;
    final double trophySwingX = trophyMidX + trophySwingAmount; // Even = swing right

    path.cubicTo(
      trophySwingX, last.dy + (vDistEnd * 0.3),
      trophySwingX, endPoint.dy - (vDistEnd * 0.3),
      endPoint.dx, endPoint.dy
    );

    // --- ROAD STYLE ROUTE ---

    // 1. Road Base (Asphalt)
    final roadBasePaint = Paint()
      ..color = const Color(0xFF37474F) // Lighter Slate Grey for better contrast
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48.0 
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, roadBasePaint);

    // 2. Road Border (Defined edge)
    final roadBorderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6) // Darker, more defined border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 54.0 
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(path, roadBorderPaint);

    // 3. Dashed White Lines (Brighter & Consistent)
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8; 
    
    // Define exclusion zones for text to avoid overlap
    final List<Rect> textZones = [];
    for (int i = 0; i < points.length; i++) {
        final point = points[i];
        final double zoneHeight = 120.0; // Approx text height
        final double top = point.dy - zoneHeight / 2;
        final double bottom = point.dy + zoneHeight / 2;
        
        if (i % 2 == 0) {
            // Even index: Image Left, Text Right
            // Text occupies approx right 45%
            textZones.add(Rect.fromLTRB(size.width * 0.55, top, size.width, bottom));
        } else {
            // Odd index: Image Right, Text Left
            // Text occupies approx left 45%
            textZones.add(Rect.fromLTRB(0, top, size.width * 0.45, bottom));
        }
    }

    final metrics = path.computeMetrics().toList();
    for (var metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        const double dashLength = 20.0; 
        const double gapLength = 24.0;  
        final extractPath = metric.extractPath(distance, distance + dashLength);
        
        // Check if this dash overlaps any text zone
        final dashBounds = extractPath.getBounds();
        
        // EXCEPTION: Allow a dash below the 1st section image (index 0) 
        // but before it hits the Earning & Career text zone (index 1)
        final p0 = points[0];
        final p1 = points[1];
        bool inForcedVisibilityZone = 
            dashBounds.top > p0.dy + 30 && 
            dashBounds.bottom < p1.dy - 30 && 
            dashBounds.center.dx < size.width * 0.6; 

        // EXCLUSION: Hide dash directly overlapping Investing photo (index 2) 
        // or Banking text (index 3) but ALLOW one in the gap between them.
        final p2 = points[2]; // Investing
        final p3 = points[3]; // Banking
        
        // Targeted overlap check for the photo area
        bool inInvestingPhotoOverlap = 
            dashBounds.top > p2.dy + 15 &&
            dashBounds.bottom < p2.dy + 55 &&
            dashBounds.center.dx < size.width * 0.4;

        if (inInvestingPhotoOverlap) {
             distance += dashLength + gapLength;
             continue; 
        }

        // Specific inclusion for the gap between Investing photo and Banking text
        // Adjusted: Moved down (+110) to strictly clear the Investing photo
        bool inSafeGapBetweenM2AndM3 = 
            dashBounds.top > p2.dy + 110 && 
            dashBounds.bottom < p3.dy - 50 && 
            dashBounds.center.dx < size.width * 0.6; 

        if (inSafeGapBetweenM2AndM3) {
             canvas.drawPath(extractPath, dashPaint);
             distance += dashLength + gapLength;
             continue; 
        }

        if (inForcedVisibilityZone) {
             canvas.drawPath(extractPath, dashPaint);
             distance += dashLength + gapLength;
             continue; // Skip the overlap check
        }

    // Final End Segment Logic
    // Ensure smooth dash continuity by not applying exclusions to the very end of the road
    final pLast = points.last;
    bool isEndSegment = dashBounds.top > pLast.dy + 20;

    if (isEndSegment) {
         canvas.drawPath(extractPath, dashPaint);
         distance += dashLength + gapLength;
         continue; 
    }

    // Standard Exclusion Logic
    bool overlaps = false;
    for (final zone in textZones) {
        if (dashBounds.overlaps(zone)) {
            overlaps = true;
            break;
        }
    }

        if (!overlaps) {
            canvas.drawPath(extractPath, dashPaint);
        }
        
        distance += dashLength + gapLength;
      }
    }

    // 4. DRAW THE CAR ON THE ROAD (Perfectly synced)
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      // Car position on path: 0 = start (play button), 1 = end (trophy)
      final tangent = metric.getTangentForOffset(metric.length * scrollProgress);
      if (tangent != null) {
        canvas.save();
        canvas.translate(tangent.position.dx, tangent.position.dy);
        // Correct rotation: Car faces FORWARD along the path
        canvas.rotate(tangent.angle + (math.pi / 2));

        // Draw the car
        _drawRealisticCar(canvas, const Size(41, 48));

        canvas.restore();
      }
    }

    _drawConnectionKnots(canvas, points);
  }

  void _drawRealisticCar(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final centerOffset = Offset(-w/2, -h/2);

    // 1. Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(centerOffset.dx + 5, centerOffset.dy + 3, w, h), const Radius.circular(8)), 
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
    );

    // 2. Car Body (Oriented DOWN)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)], // Deeper Crimson
      ).createShader(centerOffset & size);
    
    final bodyPath = Path()
      ..moveTo(centerOffset.dx + w * 0.15, centerOffset.dy + h * 0.1)
      ..lineTo(centerOffset.dx + w * 0.15, centerOffset.dy + h * 0.9)
      ..quadraticBezierTo(centerOffset.dx + w * 0.15, centerOffset.dy + h, centerOffset.dx + w * 0.5, centerOffset.dy + h)
      ..quadraticBezierTo(centerOffset.dx + w * 0.85, centerOffset.dy + h, centerOffset.dx + w * 0.85, centerOffset.dy + h * 0.9)
      ..lineTo(centerOffset.dx + w * 0.85, centerOffset.dy + h * 0.1)
      ..quadraticBezierTo(centerOffset.dx + w * 0.85, centerOffset.dy, centerOffset.dx + w * 0.5, centerOffset.dy)
      ..quadraticBezierTo(centerOffset.dx + w * 0.15, centerOffset.dy, centerOffset.dx + w * 0.15, centerOffset.dy + h * 0.1)
      ..close();
    
    canvas.drawPath(bodyPath, bodyPaint);

    // 3. Roof & Windows (Glassy)
    final windowPaint = Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.7);
    
    // Main windshield (Front - Bottom)
    final windshield = Path()
      ..moveTo(centerOffset.dx + w * 0.25, centerOffset.dy + h * 0.8)
      ..lineTo(centerOffset.dx + w * 0.75, centerOffset.dy + h * 0.8)
      ..lineTo(centerOffset.dx + w * 0.8, centerOffset.dy + h * 0.6)
      ..lineTo(centerOffset.dx + w * 0.2, centerOffset.dy + h * 0.6)
      ..close();
    canvas.drawPath(windshield, windowPaint);

    // Rear window (Top)
    final rearWindow = Path()
      ..moveTo(centerOffset.dx + w * 0.3, centerOffset.dy + h * 0.25)
      ..lineTo(centerOffset.dx + w * 0.7, centerOffset.dy + h * 0.25)
      ..lineTo(centerOffset.dx + w * 0.65, centerOffset.dy + h * 0.35)
      ..lineTo(centerOffset.dx + w * 0.35, centerOffset.dy + h * 0.35)
      ..close();
    canvas.drawPath(rearWindow, windowPaint);

    // 4. Headlights (Bright Yellow)
    final lightPaint = Paint()..color = Colors.yellowAccent;
    canvas.drawOval(Rect.fromLTWH(centerOffset.dx + w * 0.2, centerOffset.dy + h * 0.94, w * 0.2, h * 0.04), lightPaint);
    canvas.drawOval(Rect.fromLTWH(centerOffset.dx + w * 0.6, centerOffset.dy + h * 0.94, w * 0.2, h * 0.04), lightPaint);

    // 5. Tail lights (Soft Red)
    final tailPaint = Paint()..color = Colors.redAccent.withValues(alpha: 0.8);
    canvas.drawRect(Rect.fromLTWH(centerOffset.dx + w * 0.2, centerOffset.dy + h * 0.02, w * 0.15, h * 0.03), tailPaint);
    canvas.drawRect(Rect.fromLTWH(centerOffset.dx + w * 0.65, centerOffset.dy + h * 0.02, w * 0.15, h * 0.03), tailPaint);
  }

  void _drawConnectionKnots(Canvas canvas, List<Offset> points) {
    // Draws clean connection dots for the road
    final dotPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;
      
    final dotBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final point in points) {
        canvas.drawCircle(point, 7, dotPaint);
        canvas.drawCircle(point, 7, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPathPainter oldDelegate) => true; // Always repaint for smooth car animation
}

class _RightEdgeShinePainter extends CustomPainter {
  final Color color;
  final double opacityMultiplier;

  _RightEdgeShinePainter({
    required this.color,
    this.opacityMultiplier = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = 20.0;
    
    // Path: Starts slightly below top-right, down edge, around corner, halfway across bottom
    final Path path = Path();
    path.moveTo(size.width, radius + 15); // Start slightly below top-right curve
    path.lineTo(size.width, size.height - radius); // Right edge
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
      clockwise: true,
    ); // Bottom-right corner
    path.lineTo(size.width / 2, size.height); // Halfway across bottom

    final Rect bounds = path.getBounds();

    // Gradient that fades at both ends of this specific path
    final gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.white.withValues(alpha: 0.0), 
        Colors.white.withValues(alpha: 0.8 * opacityMultiplier), // Scaled opacity
        Colors.white.withValues(alpha: 0.8 * opacityMultiplier), // Scaled opacity
        Colors.white.withValues(alpha: 0.0), 
      ],
      stops: const [0.0, 0.2, 0.6, 1.0],
    ).createShader(bounds);

    final glowGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.6 * opacityMultiplier), // Scaled opacity
        color.withValues(alpha: 0.6 * opacityMultiplier), // Scaled opacity
        color.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.2, 0.6, 1.0],
    ).createShader(bounds);

    // 1. Primary Shine (Thin line)
    final Paint shinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..shader = gradient;

    canvas.drawPath(path, shinePaint);

    // 2. Soft Glow
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..shader = glowGradient;

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(_RightEdgeShinePainter oldDelegate) => oldDelegate.color != color;
}

class _ModuleSectionBanner extends StatelessWidget {
  final Map<String, dynamic> module;
  final bool isImageLeft;
  final VoidCallback onTap;
  final AnimationController animationController;
  final int index;
  final bool isCurrent;

  const _ModuleSectionBanner({
    required this.module,
    required this.isImageLeft,
    required this.onTap,
    required this.animationController,
    required this.index,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = module['color'] as Color;
    final title = module['title'] as String;
    final imagePath = module['image'] as String;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Floating Offset Calculation for Text ONLY (Lower intensity for subtle speed)
        final intensity = isCurrent ? 4.0 : 2.0;
        final double floatingOffset = math.sin((animationController.value * 2 * math.pi) + (index * 1.0)) * intensity;
        
        // Shift Banking text up slightly as requested
        final double manualShift = index == 3 ? -12.0 : 0.0;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: isImageLeft ? 4 : 16, 
              right: isImageLeft ? 16 : 4, 
              top: 8, 
              bottom: 8
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: isImageLeft 
                  ? [
                      // Image Side (Left) - STATIC
                      Expanded(
                        flex: 46, 
                        child: _buildImageCard(imagePath, color, isCurrent, index),
                      ),
                      // CENTER SPACER FOR ROAD
                      const Spacer(flex: 10), 
                      // Text Side (Right) - FLOATING
                      Expanded(
                        flex: 44,
                        child: Transform.translate(
                          offset: Offset(0, floatingOffset + manualShift),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0), 
                            child: _buildTextArea(title, color, index),
                          ),
                        ),
                      ),
                    ]
                  : [
                      // Text Side (Left) - FLOATING
                      Expanded(
                        flex: 44,
                        child: Transform.translate(
                          offset: Offset(0, floatingOffset + manualShift),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0), 
                            child: _buildTextArea(title, color, index),
                          ),
                        ),
                      ),
                      // CENTER SPACER FOR ROAD
                      const Spacer(flex: 10),
                      // Image Side (Right) - STATIC
                      Expanded(
                        flex: 46,
                        child: _buildImageCard(imagePath, color, isCurrent, index),
                      ),
                    ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildImageCard(String path, Color color, bool isCurrent, int index) {
    // Return the raw image without any container decoration for all modules
    // to allow the characters/icons to float freely.
    return Image.asset(
      path,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildTextArea(String title, Color color, int index) {
    // Refined sizes to prevent overflow for long titles
    double fontSize;
    switch (index) {
      case 0: fontSize = 34; break; // Money Basics
      case 1: fontSize = 30; break; // Earning & Career
      case 2: fontSize = 27; break; // Investing & Growth
      case 3: fontSize = 28; break; // Banking & Institutes (Increased from 24)
      default: fontSize = 27;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'MODULE ${index + 1}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 3, // Allow 3 lines
          softWrap: true,
          style: GoogleFonts.luckiestGuy(
            fontSize: fontSize, 
            fontWeight: FontWeight.w400, 
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.2, // Slightly tighter to "thin out" words
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
