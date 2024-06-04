import 'dart:math' as math;

import 'package:flutter/material.dart';

class StripedProgressIndicator extends StatefulWidget {
  final double value;
  final double stripeWidth;
  final Color stripeColor;
  final double angle;
  final double stripeSpacing;
  final Color backgroundColor;
  final int speed;

  const StripedProgressIndicator({
    super.key,
    required this.value,
    this.stripeWidth = 8.0,
    this.stripeColor = Colors.blue,
    this.angle = 45.0,
    this.stripeSpacing = 4.0,
    this.speed = 1000,
    this.backgroundColor = Colors.grey,
  });

  @override
  State<StripedProgressIndicator> createState() =>
      _StripedProgressIndicatorState();
}

class _StripedProgressIndicatorState extends State<StripedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.speed),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double progressWidth = constraints.maxWidth * widget.value;
      return Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: CustomPaint(
                  painter: _StripedProgressPainter(
                    value: widget.value,
                    stripeWidth: widget.stripeWidth,
                    stripeColor: widget.stripeColor,
                    animationValue: _controller.value,
                    angle: widget.angle,
                    stripeSpacing: widget.stripeSpacing,
                    backgroundColor: widget.backgroundColor,
                  ),
                  child: const SizedBox(
                    height: 20.0,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: progressWidth - 2,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4.0,
                  color: Colors.black,
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

class _StripedProgressPainter extends CustomPainter {
  final double value;
  final double stripeWidth;
  final Color stripeColor;
  final double animationValue;
  final double angle;
  final double stripeSpacing;
  final Color backgroundColor;

  _StripedProgressPainter({
    required this.value,
    required this.stripeWidth,
    required this.stripeColor,
    required this.animationValue,
    required this.angle,
    required this.stripeSpacing,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Paint foregroundPaint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.fill;

    // Calculate the width of the progress bar
    double progressWidth = size.width * value;

    size = Size(progressWidth, size.height);

    // Draw background
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Convert angle to radians
    double angleRad = angle * math.pi / 180;

    // Calculate the stripe height based on the angle and stripe width
    double stripeHeight = stripeWidth / math.tan(angleRad);

    // Calculate the total length to be covered by the stripes
    double stripeLength =
        math.sqrt(stripeWidth * stripeWidth + stripeHeight * stripeHeight) +
            stripeSpacing;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, progressWidth, size.height));

    for (double x = -stripeLength + (animationValue * stripeLength);
        x < progressWidth + stripeLength;
        x += stripeLength) {
      // Create a path for each stripe
      Path path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth - stripeHeight, size.height)
        ..lineTo(x - stripeHeight, size.height)
        ..close();

      // Draw the stripe
      canvas.drawPath(path, foregroundPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
