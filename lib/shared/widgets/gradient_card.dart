import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_tokens.dart';
import '../../core/motion_tokens.dart';

/// Base card component for all major UI cards following glassmorphic design
class GradientCard extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Gradient? gradient;
  final Widget? child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final List<BoxShadow>? shadows;
  final double blurAmount;
  final Color? borderColor;
  final double borderWidth;

  const GradientCard({
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(DesignTokens.spacingLG),
    this.borderRadius = DesignTokens.borderRadiusLG,
    this.gradient,
    this.child,
    this.onTap,
    this.semanticLabel,
    this.shadows,
    this.blurAmount = DesignTokens.blurGlassmorphic,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionTokens.tap,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.easeOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap?.call();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveShadows = widget.shadows ?? [
      ...DesignTokens.elevation3(),
      ...DesignTokens.primaryGlow(_glowAnimation.value),
    ];

    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: widget.gradient ?? _defaultGradient,
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: widget.borderColor ?? DesignTokens.textDisabled,
          width: widget.borderWidth,
        ),
        boxShadow: effectiveShadows,
      ),
      child: widget.child,
    );

    // Apply glassmorphic blur
    cardContent = ClipRRect(
      borderRadius: widget.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurAmount,
          sigmaY: widget.blurAmount,
        ),
        child: cardContent,
      ),
    );

    // Wrap with animation
    cardContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: cardContent,
    );

    // Add tap detection if onTap is provided
    if (widget.onTap != null) {
      cardContent = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: cardContent,
      );
    }

    // Add semantic label for accessibility
    if (widget.semanticLabel != null) {
      cardContent = Semantics(
        label: widget.semanticLabel,
        button: widget.onTap != null,
        child: cardContent,
      );
    }

    return cardContent;
  }

  LinearGradient get _defaultGradient => LinearGradient(
        colors: [
          DesignTokens.backgroundPrimary.withValues(alpha: 0.7),
          DesignTokens.backgroundSecondary.withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
