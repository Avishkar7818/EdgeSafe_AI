// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart' hide GetNumUtils;
import '../app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();

    // Deep breathing background animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bgAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    // Keep the splash on screen long enough to appreciate the boot-up sequence
    Future.delayed(const Duration(milliseconds: 3800), () {
      Get.offNamed('/login');
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.lerp(
                Alignment.topCenter,
                Alignment.bottomRight,
                _bgAnimation.value,
              )!,
              radius:
                  1.8 -
                  (_bgAnimation.value * 0.2), // Creates a pulsing depth effect
              colors: [
                const Color(0xFF0D2137).withOpacity(0.8),
                AppTheme.bgDark,
                const Color(0xFF050A18),
              ],
            ),
          ),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- THE LOGO CLUSTER ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Radar Ring (Spins clockwise)
                  Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryCyan.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: 4.seconds, curve: Curves.linear),

                  // Inner Dashed/Targeting Ring (Spins counter-clockwise)
                  Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle
                                .none, // Handled via outline or dashed package ideally, but we simulate with opacity pulse
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryCyan.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(
                        begin: 1,
                        end: 0,
                        duration: 3.seconds,
                        curve: Curves.linear,
                      )
                      .fade(duration: 1.seconds)
                      .then()
                      .fade(duration: 1.seconds, begin: 1, end: 0.5),

                  // Core Animated Logo
                  Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryCyan,
                              AppTheme.primaryBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryCyan.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 45,
                        ),
                      )
                      .animate()
                      // Snap in with a focus blur
                      .scale(duration: 800.ms, curve: Curves.easeOutBack)
                      .blur(
                        begin: const Offset(10, 10),
                        end: Offset.zero,
                        duration: 600.ms,
                      )
                      // Laser scan shimmer
                      .shimmer(
                        delay: 800.ms,
                        duration: 1200.ms,
                        color: Colors.white,
                        angle: 2,
                      )
                      // Heartbeat pulse shadow
                      .boxShadow(
                        delay: 800.ms,
                        duration: 1500.ms,
                        begin: BoxShadow(
                          color: AppTheme.primaryCyan.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        end: BoxShadow(
                          color: AppTheme.primaryCyan.withOpacity(0.1),
                          blurRadius: 60,
                          spreadRadius: 15,
                        ),
                        curve: Curves.easeInOutSine,
                      ),
                ],
              ),

              const SizedBox(height: 40),

              // --- ANIMATED TITLE ---
              const Text(
                    'EDGESAFE AI',
                    style: TextStyle(
                      color: AppTheme.primaryCyan,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  // Cinematic Y-axis blur reveal
                  .blurY(
                    begin: 20,
                    end: 0,
                    delay: 500.ms,
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  )
                  .slideY(begin: 0.2, curve: Curves.easeOut)
                  // High-contrast cyber sweep
                  .shimmer(
                    delay: 1300.ms,
                    duration: 1200.ms,
                    color: Colors.white,
                    angle: 1.5,
                  ),

              const SizedBox(height: 16),

              // --- ANIMATED SUBTITLE ---
              const Text(
                    'Intelligence at the Edge.\nSafety in Real-Time.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      letterSpacing: 2,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  // Terminal-style slide in
                  .fadeIn(delay: 1200.ms, duration: 600.ms)
                  .slideX(
                    begin: 0.1,
                    end: 0,
                    delay: 1200.ms,
                    curve: Curves.easeOut,
                  )
                  // Slight color pop at the end of the boot sequence
                  .tint(
                    color: AppTheme.primaryCyan.withOpacity(0.5),
                    delay: 1800.ms,
                    duration: 400.ms,
                  )
                  .then()
                  .tint(color: Colors.transparent, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
