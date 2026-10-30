import 'package:flutter/material.dart';
import 'package:hello_flutter/app/models/site_content.dart';
import 'package:hello_flutter/app/theme/app_theme.dart';
import 'package:hello_flutter/app/widgets/common.dart';
import 'package:hello_flutter/app/widgets/links.dart';

/// Services section: what MasterFabric builds.
class ServicesView extends StatelessWidget {
  /// Creates the services view.
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: pagePadding(context)
          .copyWith(top: 24, bottom: MediaQuery.paddingOf(context).bottom + 24),
      children: [
        const SectionHeader(
          eyebrow: 'What we are hired to build',
          title: 'AI transformation and custom software',
          body: SiteContent.hiredBody,
        ),
        const Gap(18),
        for (final f in SiteContent.hiredFor) ...[
          FeatureCard(f),
          const Gap(10),
        ],
        const Gap(24),
        Text(
          'Core services',
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < SiteContent.coreServices.length; i++) ...[
                  // ListTile wraps itself in a SafeArea; the page already
                  // applied the side insets, so don't let it apply them again.
                  MediaQuery.removePadding(
                    context: context,
                    removeLeft: true,
                    removeRight: true,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.arrow_forward_rounded,
                        color: MfColors.blue600,
                        size: 20,
                      ),
                      minLeadingWidth: 20,
                      title: Text(
                        SiteContent.coreServices[i],
                        style: const TextStyle(
                          fontSize: 14,
                          color: MfColors.slate800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  if (i != SiteContent.coreServices.length - 1)
                    const Divider(height: 1, indent: 52),
                ],
              ],
            ),
          ),
        ),
        const Gap(32),
        const SectionHeader(
          eyebrow: 'How we work',
          title: 'From discovery to operation',
        ),
        const Gap(18),
        for (var i = 0; i < SiteContent.process.length; i++)
          StepTile(
            SiteContent.process[i],
            isLast: i == SiteContent.process.length - 1,
          ),
        const Gap(32),
        const SectionHeader(
          title: 'Supercharge Your Service Experience',
          body: 'Join companies that have optimized their products and services with MasterFabric.',
        ),
        const Gap(18),
        for (final f in SiteContent.supercharge) ...[
          FeatureCard(f),
          const Gap(10),
        ],
        const Gap(28),
        const SectionHeader(
          title: 'App Design, Optimization and Growth',
          body:
              'Already have an app? We can help refresh its look and enhance its performance. '
              'We focus on improving user experience and applying the latest technologies.',
        ),
        const Gap(18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [
            for (final f in SiteContent.growth)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(f.icon, color: MfColors.blue600),
                      const Gap(10),
                      Text(
                        f.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          f.body,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontSize: 12,
                            color: MfColors.slate500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const Gap(32),
        const SectionHeader(
          eyebrow: 'Technology & tools',
          title: 'Technologies we use',
          body:
              'From editors and version control to cloud, frameworks, and AI — the stack we use '
              'to build and ship platform-based, AI-first products.',
        ),
        const Gap(16),
        for (final entry in SiteContent.techGroups.entries) ...[
          Text(
            entry.key,
            style: t.titleSmall?.copyWith(color: MfColors.slate500),
          ),
          const Gap(8),
          TagWrap(entry.value),
          const Gap(16),
        ],
        const Gap(8),
        OutlinedButton.icon(
          onPressed: () =>
              openLink(context, 'https://masterfabric.co/services/'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('Services on masterfabric.co'),
        ),
      ],
    );
  }
}
