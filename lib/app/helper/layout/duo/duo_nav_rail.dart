import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/pill_nav_bar.dart';
import 'fold_info.dart';

/// The iPhone Duo navbar: a vertical, frosted capsule that runs along the
/// side of the opened inner display.
///
/// Apple's iPhone Duo guidance moves tab bars and toolbars to the side so
/// content keeps the full height; this is the same idea for our own
/// (Flutter-drawn) navigation. It shares the [PillNavBar] look: a dark pill
/// slides between items and grows to show the selected label.
class DuoNavRail extends StatelessWidget {
  const DuoNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.footer,
  });

  final List<PillNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Optional widget under the items (e.g. the live [HingeGlyph]).
  final Widget? footer;

  static const double width = 76;
  static const double itemHeight = 58;
  static const double selectedHeight = 76;
  static const _duration = Duration(milliseconds: 260);
  static const _curve = Curves.easeOutCubic;

  double _topOf(int i) => i <= selectedIndex
      ? i * itemHeight
      : selectedHeight + (i - 1) * itemHeight;
  double _heightOf(int i) => i == selectedIndex ? selectedHeight : itemHeight;

  @override
  Widget build(BuildContext context) {
    final itemsHeight = selectedHeight + (items.length - 1) * itemHeight;
    return DecoratedBox(
      key: const ValueKey('mf-duo-rail'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width / 2),
        boxShadow: [
          BoxShadow(
            color: MfColors.slate900.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: MfColors.slate900.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: width,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(width / 2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: itemsHeight,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: _duration,
                        curve: _curve,
                        top: _topOf(selectedIndex),
                        left: 0,
                        right: 0,
                        height: selectedHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: MfColors.slate900,
                            borderRadius: BorderRadius.circular(width / 2),
                          ),
                        ),
                      ),
                      for (var i = 0; i < items.length; i++)
                        AnimatedPositioned(
                          duration: _duration,
                          curve: _curve,
                          top: _topOf(i),
                          left: 0,
                          right: 0,
                          height: _heightOf(i),
                          child: _RailItem(
                            item: items[i],
                            selected: i == selectedIndex,
                            onTap: () {
                              if (i != selectedIndex) {
                                HapticFeedback.selectionClick();
                              }
                              onSelected(i);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                if (footer != null) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 28,
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  footer!,
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PillNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : MfColors.slate600;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: DuoNavRail._duration,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                key: ValueKey(selected),
                color: color,
                size: 24,
              ),
            ),
            AnimatedSize(
              duration: DuoNavRail._duration,
              curve: DuoNavRail._curve,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox(width: 0, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live hinge indicator: two panels drawn at the current hinge angle
/// (from `UIHingeInteraction`), with the posture name underneath.
class HingeGlyph extends StatelessWidget {
  const HingeGlyph({super.key, required this.fold, this.showLabel = true});

  final FoldInfo fold;
  final bool showLabel;

  static String postureLabel(FoldInfo f) => switch (f.posture) {
    DuoPosture.flat => 'Flat',
    DuoPosture.book => 'Book',
    DuoPosture.tabletop => 'Tabletop',
    DuoPosture.closed => 'Closed',
    DuoPosture.unknown => 'Open',
  };

  @override
  Widget build(BuildContext context) {
    final angle = fold.angle >= 0 ? fold.angle.clamp(0.0, 180.0) : 180.0;
    return Semantics(
      label: 'Hinge ${postureLabel(fold)} ${angle.round()} degrees',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: angle),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, a, _) => CustomPaint(
              size: const Size(40, 24),
              painter: _HingePainter(
                a,
                active:
                    fold.posture == DuoPosture.book ||
                    fold.posture == DuoPosture.tabletop,
              ),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 4),
            Text(
              postureLabel(fold),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: MfColors.slate600,
              ),
            ),
            if (fold.angle >= 0)
              Text(
                '${angle.round()}°',
                style: const TextStyle(fontSize: 10, color: MfColors.slate400),
              ),
          ],
        ],
      ),
    );
  }
}

class _HingePainter extends CustomPainter {
  _HingePainter(this.degrees, {required this.active});

  final double degrees;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final pivot = Offset(size.width / 2, size.height - 3);
    final half = (180 - degrees) / 2 * math.pi / 180;
    const len = 17.0;
    final paint = Paint()
      ..color = active ? MfColors.blue600 : MfColors.slate800
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    // Left panel tilts up-left, right panel up-right, meeting at the hinge.
    final left = pivot + Offset(-math.cos(half) * len, -math.sin(half) * len);
    final right = pivot + Offset(math.cos(half) * len, -math.sin(half) * len);
    canvas.drawLine(pivot, left, paint);
    canvas.drawLine(pivot, right, paint);
    canvas.drawCircle(pivot, 2.5, Paint()..color = MfColors.slate400);
  }

  @override
  bool shouldRepaint(_HingePainter old) =>
      old.degrees != degrees || old.active != active;
}
