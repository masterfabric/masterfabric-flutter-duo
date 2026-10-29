import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/links.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _Hero(onNavigate: onNavigate),
        const Gap(28),
        const _ClaudePartner(),
        const Gap(28),
        const _ClaudeCodeTerminal(),
        const Gap(36),
        const _AiFirst(),
        const Gap(36),
        _StartProjectCta(onNavigate: onNavigate),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MfColors.blue50, Colors.white],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow(SiteContent.heroEyebrow, background: Colors.white),
          const Gap(16),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(text: 'Custom Software,\n'),
                TextSpan(
                  text: 'AI Transformation,\n',
                  style: TextStyle(color: MfColors.blue600),
                ),
                TextSpan(text: 'Built to Brief'),
              ],
            ),
            style: t.displaySmall,
          ),
          const Gap(16),
          Text(SiteContent.heroBody, style: t.bodyLarge),
          const Gap(22),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => onNavigate(3),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Start your project'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onNavigate(1),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('Our services'),
                ),
              ),
            ],
          ),
          const Gap(24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              for (final h in SiteContent.heroHighlights) _HighlightTile(h),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile(this.feature);

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(feature.icon, color: MfColors.blue600, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: MfColors.slate500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaudePartner extends StatelessWidget {
  const _ClaudePartner();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: kPagePadding,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MfColors.claudeSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MfColors.claude.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/images/claude-mark.svg', height: 22),
                const SizedBox(width: 8),
                const Eyebrow(
                  'Claude Partner Network',
                  color: MfColors.claude,
                  background: Colors.white,
                ),
              ],
            ),
            const Gap(14),
            Text.rich(
              const TextSpan(children: [
                TextSpan(text: 'We are a '),
                TextSpan(
                  text: 'Claude Partner Network',
                  style: TextStyle(color: MfColors.claude),
                ),
                TextSpan(text: ' partner'),
              ]),
              style: t.headlineSmall?.copyWith(color: MfColors.claudeInk),
            ),
            const Gap(10),
            Text(SiteContent.claudeBody, style: t.bodyMedium),
            const Gap(20),
            Text(
              'How an engagement runs',
              style: t.titleMedium?.copyWith(color: MfColors.claudeInk),
            ),
            const Gap(14),
            for (var i = 0; i < SiteContent.claudeSteps.length; i++)
              StepTile(
                SiteContent.claudeSteps[i],
                accent: MfColors.claude,
                isLast: i == SiteContent.claudeSteps.length - 1,
              ),
            const Gap(16),
            TextButton.icon(
              onPressed: () => openLink(context, 'https://claude.com/partners'),
              style: TextButton.styleFrom(foregroundColor: MfColors.claude),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('About the partner network'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaudeCodeTerminal extends StatelessWidget {
  const _ClaudeCodeTerminal();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const mono = TextStyle(
      fontFamily: 'Menlo',
      fontSize: 12.5,
      color: Color(0xFFE2E8F0),
      height: 1.6,
    );
    return Padding(
      padding: kPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'AI-native SDLC with Claude',
            title: 'Your team ships like an AI-native team, without giving up control.',
            body:
                'An engineer states the task. Claude Code reads the repository, drafts the change, '
                'and runs the checks. The review — and every decision that matters — stays with your people.',
          ),
          const Gap(18),
          Container(
            decoration: BoxDecoration(
              color: MfColors.terminal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      for (final c in const [Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)])
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                        ),
                      const SizedBox(width: 8),
                      Text('~/bank-core — claude', style: mono.copyWith(color: MfColors.slate400, fontSize: 11.5)),
                    ],
                  ),
                ),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: '✻ ', style: TextStyle(color: MfColors.claude)),
                          const TextSpan(text: 'Welcome to '),
                          TextSpan(
                            text: 'Claude Code',
                            style: mono.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ]),
                        style: mono,
                      ),
                      const SizedBox(height: 8),
                      Text('> fintech · engineer in the loop', style: mono.copyWith(color: MfColors.slate400)),
                      const SizedBox(height: 8),
                      for (final line in const [
                        ['1 Plan', 'The brief becomes a task in Claude Code.'],
                        ['2 Build', 'Claude Code drafts the diff in the working tree.'],
                        ['3 Prove', 'Tests and checks run in that same session.'],
                        ['4 Review', 'An engineer accepts the diff.'],
                      ])
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: '${line[0].padRight(9)} ',
                              style: const TextStyle(color: MfColors.claude, fontWeight: FontWeight.w700),
                            ),
                            TextSpan(text: line[1]),
                          ]),
                          style: mono,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          for (final b in SiteContent.claudeCodeBenefits) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle_rounded, size: 20, color: MfColors.blue600),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.title, style: t.titleMedium),
                      Text(b.body, style: t.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
          ],
        ],
      ),
    );
  }
}

class _AiFirst extends StatelessWidget {
  const _AiFirst();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: kPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'AI & Agentic',
            title: 'Agentic Coding & Sector Solutions',
            body: SiteContent.aiFirstBody,
          ),
          const Gap(18),
          for (final f in SiteContent.aiFirst) ...[FeatureCard(f), const Gap(10)],
          const Gap(8),
          Text('We deliver AI-first and agentic solutions across sectors', style: t.titleMedium),
          const Gap(12),
          const TagWrap(SiteContent.sectors),
        ],
      ),
    );
  }
}

class _StartProjectCta extends StatelessWidget {
  const _StartProjectCta({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: kPagePadding,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: MfColors.slate900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Start a project', color: Colors.white, background: Color(0x22FFFFFF)),
            const Gap(14),
            Text('Ready to start your project?', style: t.headlineSmall?.copyWith(color: Colors.white)),
            const Gap(10),
            Text(
              'Custom software and AI transformation for institutions and private clients. '
              'Send us the brief — we plan it, build it, and hand it over.',
              style: t.bodyMedium?.copyWith(color: MfColors.slate400),
            ),
            const Gap(16),
            const TagWrap(
              [
                'Planned around your brief',
                'Built with Claude in the loop',
                'Reviewed by engineers',
                'Software you own',
              ],
              dark: true,
            ),
            const Gap(20),
            FilledButton(
              onPressed: () => onNavigate(3),
              style: FilledButton.styleFrom(
                backgroundColor: MfColors.blue600,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}
