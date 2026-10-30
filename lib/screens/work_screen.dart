import 'package:flutter/material.dart';

import '../data/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/links.dart';

const _kRadius = 20.0;
const _kBorder = Color(0xFFE2E8F0);

class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: pagePadding(context)
          .copyWith(top: 24, bottom: MediaQuery.paddingOf(context).bottom + 24),
      children: [
        const SectionHeader(
          eyebrow: 'Our Works',
          title: 'On Companies',
          body:
              "We've partnered with industry leaders to deliver exceptional results. "
              'Our reliable business partners with whom we have signed many successful projects.',
        ),
        const Gap(22),
        const _ClientGrid(),
        const Gap(36),
        const _SectionLabel('Academy'),
        const Gap(12),
        const _AcademyCard(),
        const Gap(16),
        const _OpenSourceCard(),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: MfColors.slate500,
      ),
    );
  }
}

/// Two-column grid of uniform client cards. Built with rows (not a GridView)
/// so every card gets the same height without a fixed aspect ratio.
class _ClientGrid extends StatelessWidget {
  const _ClientGrid();

  @override
  Widget build(BuildContext context) {
    const clients = SiteContent.clients;
    const spacing = 12.0;
    final rows = <Widget>[];
    for (var i = 0; i < clients.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: spacing));
      rows.add(
        Row(
          children: [
            Expanded(child: _ClientCard(clients[i])),
            const SizedBox(width: spacing),
            Expanded(
              child: i + 1 < clients.length
                  ? _ClientCard(clients[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard(this.client);
  final ClientLogo client;

  String get _domain {
    final host = Uri.parse(client.url).host;
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kRadius),
        side: const BorderSide(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openLink(context, client.url),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Uniform logo well: every logo is fitted (contain) into the
              // same optical box so wide and tall marks read at similar weight.
              Container(
                height: 84,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: MfColors.slate50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  client.asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 4, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: MfColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _domain,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MfColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.north_east_rounded,
                      size: 16,
                      color: MfColors.slate400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcademyCard extends StatelessWidget {
  const _AcademyCard();

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
        borderRadius: BorderRadius.circular(_kRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  'assets/images/academy-badge.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'MasterFabric Academy',
                  style: t.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            'Company training for Agentic AI Developers and the AI SDLC — how teams design, '
            'secure, and ship software when agents write, test, and deploy the code.',
            style: t.bodyMedium?.copyWith(color: const Color(0xFFCBD5E1)),
          ),
          const Gap(16),
          const TagWrap(SiteContent.academyTags, dark: true),
          const Gap(16),
          Text(
            'Curriculum covers agent architecture, tool use, multi-agent orchestration, guardrails, '
            'and DevOps + SecOps + LLMOps. Enterprises can request a private cohort or an adoption roadmap.',
            style: t.bodySmall?.copyWith(color: MfColors.slate400, height: 1.5),
          ),
          const Gap(20),
          FilledButton.icon(
            onPressed: () =>
                openLink(context, 'https://academy.masterfabric.co'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MfColors.slate900,
              minimumSize: const Size.fromHeight(50),
            ),
            icon: const Icon(Icons.north_east_rounded, size: 18),
            label: const Text('Visit Academy'),
          ),
        ],
      ),
    );
  }
}

class _OpenSourceCard extends StatelessWidget {
  const _OpenSourceCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: MfColors.blue50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: MfColors.blue600,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Open source'),
                    const SizedBox(height: 6),
                    Text(
                      'Open-source MCP learning',
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            '100-day roadmaps with the official Academy MCP — day-by-day lessons and project planning.',
            style: t.bodyMedium,
          ),
          const Gap(16),
          const TagWrap([
            'Flutter',
            'Expo / React Native',
            'DevOps',
            'NestJS',
            'Next.js',
            'Go',
            'TypeScript',
            'GraphQL',
            'AI Agents',
          ]),
          const Gap(20),
          OutlinedButton.icon(
            onPressed: () => openLink(
              context,
              'https://github.com/masterfabric/one-hundered-days',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            icon: const Icon(Icons.code_rounded, size: 18),
            label: const Text('one-hundered-days on GitHub'),
          ),
        ],
      ),
    );
  }
}
