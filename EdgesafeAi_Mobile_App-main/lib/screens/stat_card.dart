// lib/widgets/stat_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_theme.dart';
import 'glass_card.dart';

class StatCard extends StatefulWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isDanger;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.isDanger = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  int _prevValue = 0;

  @override
  Widget build(BuildContext context) {
    final valueChanged = widget.value != _prevValue;
    _prevValue = widget.value;

    return GlowBorder(
      glowColor: widget.isDanger ? AppTheme.dangerRed : widget.color,
      child: GlassCard(
        backgroundColor: AppTheme.bgCard,
        borderColor: widget.color.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: widget.color.withOpacity(0.3)),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                if (widget.isDanger)
                  PulsingDot(color: AppTheme.dangerRed, size: 10),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                widget.value.toString(),
                key: ValueKey(widget.value),
                style: TextStyle(
                  color: widget.color,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.subtitle,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}