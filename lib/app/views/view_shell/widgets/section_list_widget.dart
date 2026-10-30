import 'package:flutter/material.dart';
import 'package:hello_flutter/app/theme/app_theme.dart';
import 'package:hello_flutter/app/views/view_shell/models/shell_section.dart';

/// Long-press a section and drag it across the fold into the content pane.
class DraggableSection extends StatelessWidget {
  /// Creates a draggable wrapper for section [index].
  const DraggableSection({required this.index, required this.child, super.key});

  /// Section index carried as drag data.
  final int index;

  /// The tile being dragged.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        elevation: 14,
        shadowColor: const Color(0x55000000),
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 260,
          child: Opacity(
            opacity: 0.92,
            child: SectionTile(
              section: kShellSections[index],
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: child,
    );
  }
}

/// Duo navigation pane: the list of sections, each draggable across the fold.
class SectionList extends StatelessWidget {
  /// Creates the list with the [selected] index and an [onSelected] callback.
  const SectionList({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Currently selected section.
  final int selected;

  /// Called with the tapped section index.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
          child: Text(
            'Explore',
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        for (var i = 0; i < kShellSections.length; i++) ...[
          DraggableSection(
            index: i,
            child: SectionTile(
              section: kShellSections[i],
              selected: i == selected,
              onTap: () => onSelected(i),
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.open_with_rounded,
                  size: 14,
                  color: MfColors.slate400,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Long-press a section and drag it across the fold to open it.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: MfColors.slate400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A section card: icon, title, subtitle and chevron.
class SectionTile extends StatelessWidget {
  /// Creates a tile for [section].
  const SectionTile({
    required this.section,
    required this.selected,
    required this.onTap,
    this.fill = false,
    super.key,
  });

  /// Section shown by this tile.
  final ShellSection section;

  /// Whether this is the current section.
  final bool selected;

  /// Called when the tile is tapped.
  final VoidCallback onTap;

  /// Fills its parent box (tabletop control deck) instead of sizing to text.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : MfColors.slate900;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? MfColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? MfColors.slate900 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: fill ? 10 : 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.12)
                        : MfColors.blue50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selected ? section.item.selectedIcon : section.item.icon,
                    color: selected ? Colors.white : MfColors.blue600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        section.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: selected
                              ? const Color(0xFFCBD5E1)
                              : MfColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: selected ? Colors.white : MfColors.slate400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
