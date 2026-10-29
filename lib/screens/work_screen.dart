import 'package:flutter/material.dart';

import '../data/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/links.dart';

class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        const SectionHeader(
          eyebrow: 'Our Works',
          title: 'On Companies',
          body:
              "We've partnered with industry leaders to deliver exceptional results. "
              'Our reliable business partners with whom we have signed many successful projects.',
        ),
        const Gap(18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [
            for (final c in SiteContent.clients)
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => openLink(context, c.url),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Image.asset(c.asset, fit: BoxFit.contain),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          c.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MfColors.slate600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Gap(32),
        _AcademyCard(),
        const Gap(20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.hub_rounded, color: MfColors.blue600),
                    SizedBox(width: 10),
                    Eyebrow('Open source'),
                  ],
                ),
                const Gap(12),
                Text('Open-source MCP learning', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Gap(6),
                Text(
                  '100-day roadmaps with the official Academy MCP — day-by-day lessons and project planning.',
                  style: t.bodyMedium,
                ),
                const Gap(12),
                const TagWrap([
                  'Flutter', 'Expo / React Native', 'DevOps', 'NestJS', 'Next.js', 'Go',
                  'TypeScript', 'GraphQL', 'AI Agents',
                ]),
                const Gap(14),
                OutlinedButton.icon(
                  onPressed: () => openLink(context, 'https://github.com/masterfabric/one-hundered-days'),
                  icon: const Icon(Icons.code_rounded, size: 18),
                  label: const Text('one-hundered-days on GitHub'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AcademyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MfColors.slate900, Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/academy-badge.png', width: 56, height: 56, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'MasterFabric Academy',
                  style: t.headlineSmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const Gap(14),
          Text(
            'Company training for Agentic AI Developers and the AI SDLC — how teams design, '
            'secure, and ship software when agents write, test, and deploy the code.',
            style: t.bodyMedium?.copyWith(color: const Color(0xFFCBD5E1)),
          ),
          const Gap(14),
          const TagWrap(SiteContent.academyTags, dark: true),
          const Gap(14),
          Text(
            'Curriculum covers agent architecture, tool use, multi-agent orchestration, guardrails, '
            'and DevOps + SecOps + LLMOps. Enterprises can request a private cohort or an adoption roadmap.',
            style: t.bodySmall?.copyWith(color: MfColors.slate400, height: 1.45),
          ),
          const Gap(18),
          FilledButton(
            onPressed: () => openLink(context, 'https://academy.masterfabric.co'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MfColors.slate900,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Visit Academy'),
          ),
        ],
      ),
    );
  }
}
