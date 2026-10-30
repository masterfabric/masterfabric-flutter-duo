import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_flutter/app/theme/app_theme.dart';

/// A navigation destination: icons and label.
class PillNavItem {
  /// Creates a destination.
  const PillNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// Icon when not selected.
  final IconData icon;

  /// Icon when selected.
  final IconData selectedIcon;

  /// Destination label.
  final String label;
}

/// Floating capsule tab bar (new-generation Instagram iOS style):
/// frosted translucent background, hairline border, soft shadow, and an
/// animated pill that slides and morphs behind the selected tab.
class PillNavBar extends StatelessWidget {
  /// Creates the bar for [items].
  const PillNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// Destinations.
  final List<PillNavItem> items;

  /// Index of the selected destination.
  final int selectedIndex;

  /// Called with the tapped destination index.
  final ValueChanged<int> onSelected;

  /// Bar height.
  static const double barHeight = 64;

  /// Horizontal margin from the screen edges.
  static const double sideMargin = 20;

  /// Gap above the bottom safe area.
  static const double bottomGap = 10;
  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sideMargin,
        0,
        sideMargin,
        (bottomInset > 0 ? bottomInset : 12) + bottomGap - 8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(barHeight / 2),
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
          borderRadius: BorderRadius.circular(barHeight / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: barHeight,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(barHeight / 2),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final count = items.length;
                  final width = constraints.maxWidth;
                  // Selected tab is wider (icon + label); others share the rest.
                  final selectedWidth = (width * 0.36).clamp(96.0, 150.0);
                  final otherWidth = (width - selectedWidth) / (count - 1);
                  double leftOf(int i) => i <= selectedIndex
                      ? i * otherWidth
                      : selectedWidth + (i - 1) * otherWidth;
                  double widthOf(int i) =>
                      i == selectedIndex ? selectedWidth : otherWidth;

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: _duration,
                        curve: _curve,
                        left: leftOf(selectedIndex),
                        top: 0,
                        bottom: 0,
                        width: selectedWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: MfColors.slate900,
                            borderRadius: BorderRadius.circular(barHeight),
                          ),
                        ),
                      ),
                      for (var i = 0; i < count; i++)
                        AnimatedPositioned(
                          duration: _duration,
                          curve: _curve,
                          left: leftOf(i),
                          top: 0,
                          bottom: 0,
                          width: widthOf(i),
                          child: _PillTab(
                            item: items[i],
                            selected: i == selectedIndex,
                            onTap: () {
                              if (i != selectedIndex) {
                                HapticFeedback.lightImpact();
                              }
                              onSelected(i);
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
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
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: PillNavBar._duration,
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  key: ValueKey(selected),
                  color: color,
                  size: 24,
                ),
              ),
              Flexible(
                child: AnimatedSize(
                  duration: PillNavBar._duration,
                  curve: PillNavBar._curve,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
