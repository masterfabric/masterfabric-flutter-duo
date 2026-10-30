import 'package:flutter/material.dart';

import '../data/site_content.dart';
import '../theme/app_theme.dart';

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
  const Eyebrow(
    this.text, {
    super.key,
    this.color = MfColors.blue700,
    this.background = MfColors.blue50,
  });

  final String text;
  final Color color;
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

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.body,
  });

  final String? eyebrow;
  final String title;
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

class FeatureCard extends StatelessWidget {
  const FeatureCard(this.feature, {super.key, this.accent = MfColors.blue600});

  final Feature feature;
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

class StepTile extends StatelessWidget {
  const StepTile(
    this.step, {
    super.key,
    this.accent = MfColors.blue600,
    this.isLast = false,
  });

  final ProcessStep step;
  final Color accent;
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

class TagWrap extends StatelessWidget {
  const TagWrap(this.tags, {super.key, this.dark = false});

  final List<String> tags;
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

class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}
