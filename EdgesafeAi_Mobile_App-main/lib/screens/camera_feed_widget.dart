// lib/widgets/camera_feed_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edgesafe_ai/app_theme.dart';
import '../screens/dashboard_controller.dart';

class CameraFeedWidget extends StatefulWidget {
  const CameraFeedWidget({super.key});

  @override
  State<CameraFeedWidget> createState() => _CameraFeedWidgetState();
}

class _CameraFeedWidgetState extends State<CameraFeedWidget>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _blinkController;
  late Animation<double> _scanAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(_blinkController);
  }

  @override
  void dispose() {
    _scanController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryCyan.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Dark camera background with grid (Shows if no frame is received yet)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF030810),
              child: CustomPaint(painter: _GridPainter()),
            ),

            // 🔥 THE REAL LIVE VIDEO FEED 🔥
            Positioned.fill(
              child: Obx(() {
                if (ctrl.currentFrameBase64.value.isEmpty) {
                  return const Center(
                    child: Text(
                      'WAITING FOR VIDEO STREAM...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        letterSpacing: 2,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }

                // 🔥 FIX: Aggressive string sanitization
                try {
                  String base64Str = ctrl.currentFrameBase64.value;

                  // 1. Strip any "data:image/jpeg;base64," prefix if it sneaked in
                  if (base64Str.contains(',')) {
                    base64Str = base64Str.split(',').last;
                  }

                  // 2. Eradicate all hidden whitespace, newlines, and carriage returns
                  base64Str = base64Str.replaceAll(RegExp(r'\s+'), '');

                  // 3. Pad the string so it is perfectly divisible by 4
                  while (base64Str.length % 4 != 0) {
                    base64Str += '=';
                  }

                  return Image.memory(
                    base64Decode(base64Str),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  );
                } catch (e) {
                  print("Image Decode Error: $e");
                  return Center(
                    child: Text(
                      'DECODE ERROR: ${e.toString().split(':').first}',
                      style: const TextStyle(
                        color: AppTheme.dangerRed,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
              }),
            ),

            // Scan line overlay
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (_, __) {
                return Positioned(
                  top: _scanAnimation.value * 280,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryCyan.withOpacity(0.8),
                          AppTheme.primaryCyan,
                          AppTheme.primaryCyan.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryCyan.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Corner brackets overlay
            Positioned.fill(
              child: CustomPaint(painter: _CornerBracketPainter()),
            ),

            // Top bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.black.withOpacity(0.6),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _blinkAnimation,
                      builder: (_, __) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed.withOpacity(
                            _blinkAnimation.value,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.dangerRed.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '● REC  CAM-01  LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getTime(),
                      style: const TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom status bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                color: Colors.black.withOpacity(0.7),
                child: Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye,
                      color: AppTheme.primaryCyan,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'AI DETECTION ACTIVE',
                      style: TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      final count =
                          ctrl.stats.value.totalPeople +
                          ctrl.stats.value.totalThreats;
                      return Text(
                        '$count OBJECTS',
                        style: TextStyle(
                          color: AppTheme.accentGreen.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    const len = 20.0;
    const margin = 8.0;

    // TL
    canvas.drawLine(
      Offset(margin, margin + len),
      Offset(margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + len, margin),
      paint,
    );
    // TR
    canvas.drawLine(
      Offset(size.width - margin, margin + len),
      Offset(size.width - margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin - len, margin),
      paint,
    );
    // BL
    canvas.drawLine(
      Offset(margin, size.height - margin - len),
      Offset(margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + len, size.height - margin),
      paint,
    );
    // BR
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin - len),
      Offset(size.width - margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin - len, size.height - margin),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
