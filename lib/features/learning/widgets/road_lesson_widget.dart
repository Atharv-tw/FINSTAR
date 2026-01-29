import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/learning_module.dart';

class RoadLessonWidget extends StatefulWidget {
  final LearningModule module;
  final ValueNotifier<double> scrollProgress;

  const RoadLessonWidget({
    super.key,
    required this.module,
    required this.scrollProgress,
  });

  @override
  State<RoadLessonWidget> createState() => _RoadLessonWidgetState();
}

class _RoadLessonWidgetState extends State<RoadLessonWidget> {
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
        final path = _createPathThroughPoints(points, constraints.biggest);
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RoadPainter(path: path),
              ),
            ),
            Positioned(
              left: points.first.dx - 30,
              top: points.first.dy - 30,
              child: _buildFlag(),
            ),
            ...List.generate(widget.module.lessons.length, (index) {
              final lesson = widget.module.lessons[index];
              final position = points[index + 1];
              final isLeft = (index % 2 != 0);

              final bool isLocked = (index == 0) ? false : !widget.module.lessons[index - 1].isCompleted;
              
              final lessonIcon = _buildLessonIcon(lesson, isLocked);
              final lessonText = _buildLessonText(lesson, widget.module.gradientColors[0]);

              Widget lessonRow;
              if (isLeft) {
                lessonRow = Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: lessonText),
                    const SizedBox(width: 5),
                    lessonIcon,
                  ],
                );
              } else {
                lessonRow = Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    lessonIcon,
                    const SizedBox(width: 5),
                    Expanded(child: lessonText),
                  ],
                );
              }

              return Positioned(
                top: position.dy - 55,
                height: 110,
                left: isLeft ? 0 : position.dx + 5,
                right: isLeft ? constraints.maxWidth - position.dx - 5 : 0,
                child: GestureDetector(
                  onTap: () {
                    if (!isLocked) {
                      HapticFeedback.mediumImpact();
                      context.push('/lesson/${widget.module.id}/${lesson.id}');
                    }
                  },
                  child: lessonRow,
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
    return points;
  }

  Path _createPathThroughPoints(List<Offset> points, Size size) {
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

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }
    return path;
  }

  String _formatTitle(String title) {
    final words = title.split(' ');
    if (words.length <= 2) return title;
    if (words.length == 3 && words[2].length <= 2) return title;
    final firstLine = words.sublist(0, 2).join(' ');
    final secondLine = words.sublist(2).join(' ');
    return '$firstLine\n$secondLine';
  }

  Widget _buildFlag() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.flag, color: Colors.white, size: 30),
    );
  }

  Widget _buildLessonText(Lesson lesson, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _TextBackgroundPainter(color: color.withValues(alpha: 0.8)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _formatTitle(lesson.title),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
              shadows: [
                const Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonIcon(Lesson lesson, bool isLocked) {
    return Container(
      width: 60, 
      height: 60, 
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked ? const Color(0xFF757575) : const Color(0xFF4CAF50), 
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
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
}

class _TextBackgroundPainter extends CustomPainter {
  final Color color;
  _TextBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    Path path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.2);
    path.quadraticBezierTo(size.width * -0.1, size.height * 0.5, size.width * 0.15, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.3, size.height * 1.1, size.width * 0.6, size.height * 0.9);
    path.quadraticBezierTo(size.width * 1.1, size.height * 0.8, size.width * 0.9, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.8, size.height * -0.1, size.width * 0.4, size.height * 0.1);
    path.close();

    final matrix = Matrix4.identity()
      ..multiply(Matrix4.translationValues(size.width / 2, size.height / 2, 0))
      ..multiply(Matrix4.rotationZ(0.1))
      ..multiply(Matrix4.translationValues(-size.width / 2, -size.height / 2, 0));
    final finalPath = path.transform(matrix.storage);
    
    final shadowPath = finalPath.shift(const Offset(4, 4));
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant _TextBackgroundPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RoadPainter extends CustomPainter {
  final Path path;

  _RoadPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, shadowPaint);
    
    final roadPaint = Paint()
      ..color = const Color(0xFF6D4C41) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50.0
      ..strokeCap = StrokeCap.round;

    final borderPaint = Paint()
      ..color = const Color(0xFF4E342E) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 56.0
      ..strokeCap = StrokeCap.round;

    final dashedPaint = Paint()
      ..color = const Color(0xFFBCAAA4).withValues(alpha: 0.8) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, roadPaint);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 20.0; 
      while (distance < metric.length) {
        const double len = 15.0;
        if (distance + len > metric.length) break;
        
        canvas.drawPath(
          metric.extractPath(distance, distance + len),
          dashedPaint,
        );
        distance += len + 15.0; 
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) {
    return oldDelegate.path != oldDelegate.path;
  }
}
