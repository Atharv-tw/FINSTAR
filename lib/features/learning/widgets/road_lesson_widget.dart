import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/learning_module.dart';
import '../learning_theme.dart';

class RoadLessonWidget extends StatefulWidget {
  final LearningModule module;
  final ValueNotifier<double> scrollProgress;
  final ValueChanged<double>? onHeightCalculated; // Corrected: this needs to be a field of StatefulWidget

  const RoadLessonWidget({
    super.key,
    required this.module,
    required this.scrollProgress,
    this.onHeightCalculated, // New callback
  });

  @override
  State<RoadLessonWidget> createState() => _RoadLessonWidgetState();
}

class _RoadLessonWidgetState extends State<RoadLessonWidget> {
  // ... existing code ...

  @override
  void initState() {
    super.initState();
    widget.scrollProgress.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollProgress.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final points = _getLessonPoints(constraints.biggest, widget.module.lessons.length);
        
        // Report height if callback is provided
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.onHeightCalculated != null) {
            final double contentHeight = points.last.dy + 50 + 20; // Last point Y + half trophy height + padding
            widget.onHeightCalculated!(contentHeight);
          }
        });

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RoadPainter(points: points, lessonCount: widget.module.lessons.length),
              ),
            ),
            Positioned(
              left: points.last.dx - 40, // Center the 80x80 node
              top: points.last.dy - 40, // Center the 80x80 node
              child: _buildEndNode(),
            ),

            ...List.generate(widget.module.lessons.length, (index) {
              final lesson = widget.module.lessons[index];
              final position = points[index + 1];
              final isLeft = (index % 2 != 0);

              final bool isLocked = (index == 0) ? false : !widget.module.lessons[index - 1].isCompleted;
              
              final lessonIcon = _buildLessonIcon(lesson, isLocked);
              final lessonText = _buildLessonText(lesson, widget.module.gradientColors[0], isLeft);

              return Positioned(
                top: position.dy - 55, // Center vertically
                left: 0, // Span full width of screen
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    if (!isLocked) {
                      HapticFeedback.mediumImpact();
                      context.push('/lesson/${widget.module.id}/${lesson.id}');
                    }
                  },
                  child: Container( // Outer container spans full width
                    height: 110,
                    // color: Colors.blue.withOpacity(0.1), // Debugging
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!isLeft) ...[
                          SizedBox(width: math.max(20, position.dx - 30 - 15 - (60 + 5))), // Empty space on left, ensure min 20
                          lessonIcon,
                          const SizedBox(width: 15), // Spacing
                          Expanded( // Text will be in this expanded area
                            child: Align(
                              alignment: Alignment.center, // Center the text within this remaining space
                              child: lessonText, // lessonText is shrink-wrapped
                            ),
                          ),
                        ] else ...[
                          Expanded( // Text will be in this expanded area
                            child: Align(
                              alignment: Alignment.center, // Center the text within this remaining space
                              child: lessonText, // lessonText is shrink-wrapped
                            ),
                          ),
                          const SizedBox(width: 15), // Spacing
                          lessonIcon,
                          SizedBox(width: math.max(20, constraints.maxWidth - (position.dx + 30 + 15 + (60 + 5)))), // Empty space on right, ensure min 20
                        ]
                      ],
                    ),
                  ),
                ),
              );

            }),
          ],
        );
      },
    );
  }

  List<Offset> _getLessonPoints(Size size, int lessonCount) {
    final double width = size.width;
    final double height = size.height;
    final points = <Offset>[];
    const double startY = 40.0;

    points.add(Offset(width / 2, startY));

    for (int i = 0; i < lessonCount; i++) {
      final double fraction = (i + 0.8) / (lessonCount * 1.25);
      final double y = startY + height * fraction;
      
      double x = (i % 2 != 0) ? width * 0.8 : width * 0.2;
      points.add(Offset(x, y));
    }
    // Add an extra point to extend the road further and center it for the end node
    final double lastY = points.last.dy;
    const double extendedDistance = 150.0; // Increase extension distance
    points.add(Offset(width / 2, lastY + extendedDistance)); // Extend and center horizontally
    return points;
  }

  String _formatTitle(String title) {
    final words = title.split(' ');
    if (words.length <= 2) return title;
    if (words.length == 3 && words[2].length <= 2) return title;

    // Special handling for "Set & Smash Financial Goals"
    if (title == "Set & Smash Financial Goals") {
      return "Set & Smash\nFinancial Goals";
    }

    final firstLine = words.sublist(0, 2).join(' ');
    final secondLine = words.sublist(2).join(' ');
    return '$firstLine\n$secondLine';
  }

  Widget _buildLessonText(Lesson lesson, Color color, bool isLeft) {
    return ClipPath(
      clipper: _LessonLabelClipper(isLeft: isLeft),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: LearningTheme.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          _formatTitle(lesson.title),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: LearningTheme.vanDyke,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLessonIcon(Lesson lesson, bool isLocked) {
    return Container(
      width: 60, 
      height: 60, 
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked ? const Color(0xFF757575) : const Color(0xFF4CAF50), 
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isLocked ? Icons.lock_outline : (lesson.isCompleted ? Icons.check_circle_outline : Icons.play_circle_outline),
        color: Colors.white,
        size: 32, 
      ),
    );
  }

  Widget _buildEndNode() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Wrap content tightly
      children: [
        Container( // Trophy cup
          width: 70, // Slightly smaller cup
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.yellow.shade400, Colors.amber.shade800],
              center: Alignment.topLeft,
              radius: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 4,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.emoji_events,
              color: Colors.white.withOpacity(0.95),
              size: 48, // Adjusted size
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 2,
                  offset: Offset(0.5, 0.5),
                ),
              ],
            ),
          ),
        ),
        Container( // Trophy base
          width: 90, // Wider base
          height: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Rounded corners for capsule look
            gradient: LinearGradient(
              colors: [Colors.brown.shade700, Colors.grey.shade800], // Darker, metallic look
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
} // Closing brace for _RoadLessonWidgetState

class _LessonLabelClipper extends CustomClipper<Path> {
  final bool isLeft;
  _LessonLabelClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double radius = 15;
    const double pointerSize = 10;

    if (!isLeft) { // Points right
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius - pointerSize, 0);
      path.quadraticBezierTo(size.width - pointerSize, 0, size.width - pointerSize, radius);
      path.lineTo(size.width - pointerSize, size.height / 2 - pointerSize / 2);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - pointerSize, size.height / 2 + pointerSize / 2);
      path.lineTo(size.width - pointerSize, size.height - radius);
      path.quadraticBezierTo(size.width - pointerSize, size.height, size.width - radius - pointerSize, size.height);
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    } else { // Points left
      path.moveTo(pointerSize + radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
      path.lineTo(pointerSize + radius, size.height);
      path.quadraticBezierTo(pointerSize, size.height, pointerSize, size.height - radius);
      path.lineTo(pointerSize, size.height / 2 + pointerSize / 2);
      path.lineTo(0, size.height / 2);
      path.lineTo(pointerSize, size.height / 2 - pointerSize / 2);
      path.lineTo(pointerSize, radius);
      path.quadraticBezierTo(pointerSize, 0, pointerSize + radius, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RoadPainter extends CustomPainter {
  final List<Offset> points;
  final int lessonCount;

  _RoadPainter({required this.points, required this.lessonCount});

  Path _createPathThroughPoints() { // Return a single Path
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i+1];
      
      final double cp1x = p1.dx;
      final double cp1y = p1.dy + (p2.dy - p1.dy) * 0.6;
      final double cp2x = p2.dx;
      final double cp2y = p2.dy - (p2.dy - p1.dy) * 0.6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy); // Add to the single path
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Path roadPath = _createPathThroughPoints(); // Now gets a single Path

    // Constant road properties
    const double roadWidth = 50.0;
    const Color roadColor = Color(0xFF6D4C41);
    const Color borderColor = Color(0xFF4E342E);
    const double shadowWidth = 60.0;
    const double dashedLineStrokeWidth = 2.0;
    const double dashLen = 15.0;
    const double dashGap = 15.0;

    // Shadow Paint
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = shadowWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(roadPath, shadowPaint); // Draw the single path

    // Border Paint
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth + 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, borderPaint); // Draw the single path

    // Road Paint
    final roadPaint = Paint()
      ..color = roadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, roadPaint); // Draw the single path

    // Dashed Line Paint
    final dashedPaint = Paint()
      ..color = const Color(0xFFBCAAA4).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = dashedLineStrokeWidth;

    // Draw dashed lines on the single path
    final pathMetrics = roadPath.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 20.0;
      while (distance < metric.length) {
        if (distance + dashLen > metric.length) break;

        canvas.drawPath(
          metric.extractPath(distance, distance + dashLen),
          dashedPaint,
        );
        distance += dashLen + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lessonCount != lessonCount;
  }
}