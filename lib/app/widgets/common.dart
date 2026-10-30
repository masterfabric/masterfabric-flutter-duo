import 'package:flutter/material.dart';
import 'package:hello_flutter/app/models/site_content.dart';
import 'package:hello_flutter/app/theme/app_theme.dart';

/// Horizontal padding of every page.
const kPagePadding = EdgeInsets.symmetric(horizontal: 20);

/// Page side padding: the 20pt page margin plus any horizontal safe area
/// (iPhone Duo vertical status bar, fold half, camera housing), so every
/// block in a pane shares one content edge while backgrounds stay
/// full-bleed.
EdgeInsets pagePadding(BuildContext context) {
  final pad = MediaQuery.paddingOf(context);
  return EdgeInsets.only(left: pad.left + 20, right: pad.right + 20);
}

/// Small rounded label, like the site's "AI & Agentic" eyebrow chips.
class Eyebrow extends StatelessWidget {
  /// Creates an eyebrow label.
  const Eyebrow(
    this.text, {
    super.key,
    this.color = MfColors.blue700,
    this.background = MfColors.blue50,
  });

  /// Label text.
  final String text;

  /// Text color.
  final Color color;

  /// Pill background color.
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Eyebrow, title and optional body of a page section.
class SectionHeader extends StatelessWidget {
  /// Creates a section header.
  const SectionHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.body,
  });

  /// Optional small label above the title.
  final String? eyebrow;

  /// Section title.
  final String title;

  /// Optional paragraph under the title.
  final String? body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 12)],
        Text(title, style: t.headlineSmall),
        if (body != null) ...[
          const SizedBox(height: 10),
          Text(body!, style: t.bodyLarge),
        ],
      ],
    );
  }
}

/// Card showing a [Feature].
class FeatureCard extends StatelessWidget {
  /// Creates a card for [feature].
  const FeatureCard(this.feature, {super.key, this.accent = MfColors.blue600});

  /// Feature to show.
  final Feature feature;

  /// Icon accent color.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(feature.icon, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feature.title, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(feature.body, style: t.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Timeline tile for a [ProcessStep].
class StepTile extends StatelessWidget {
  /// Creates a tile for [step].
  const StepTile(
    this.step, {
    super.key,
    this.accent = MfColors.blue600,
    this.isLast = false,
  });

  /// Step to show.
  final ProcessStep step;

  /// Number badge color.
  final Color accent;

  /// Whether this is the last step (no connector line).
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  step.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: accent.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(step.body, style: t.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapping row of tag chips.
class TagWrap extends StatelessWidget {
  /// Creates chips for [tags].
  const TagWrap(this.tags, {super.key, this.dark = false});

  /// Tag labels.
  final List<String> tags;

  /// Use the dark chip style.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : MfColors.slate50,
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.14)
                    : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: dark ? Colors.white : MfColors.slate800,
              ),
            ),
          ),
      ],
    );
  }
}

/// Square spacer of [size].
class Gap extends StatelessWidget {
  /// Creates a gap.
  const Gap(this.size, {super.key});

  /// Width and height of the gap.
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}
