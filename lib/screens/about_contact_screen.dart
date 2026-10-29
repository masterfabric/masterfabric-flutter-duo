import 'package:flutter/material.dart';

import '../data/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/links.dart';
import '../widgets/mf_logo.dart';

class AboutContactScreen extends StatelessWidget {
  const AboutContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        const SectionHeader(
          eyebrow: 'Start a conversation',
          title: 'Get in Touch',
          body:
              "Ready to start your project? Send us the brief and we'll get back to you within 24 hours.",
        ),
        const Gap(18),
        FilledButton.icon(
          onPressed: () => openLink(context, 'https://masterfabric.co/contact/'),
          style: FilledButton.styleFrom(
            backgroundColor: MfColors.blue600,
            minimumSize: const Size.fromHeight(52),
          ),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Start Your Project'),
        ),
        const Gap(10),
        OutlinedButton.icon(
          onPressed: () => openLink(context, 'mailto:info@masterfabric.co'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          icon: const Icon(Icons.mail_outline_rounded, size: 18),
          label: const Text('info@masterfabric.co'),
        ),
        const Gap(24),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < SiteContent.contactLinks.length; i++) ...[
                _LinkTile(SiteContent.contactLinks[i]),
                if (i != SiteContent.contactLinks.length - 1) const Divider(height: 1, indent: 64),
              ],
            ],
          ),
        ),
        const Gap(24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(Icons.location_on_outlined, 'Office', SiteContent.address),
                const Gap(14),
                _InfoRow(
                  Icons.schedule_rounded,
                  'Hours (Europe/Istanbul)',
                  SiteContent.hours.join('\n'),
                ),
              ],
            ),
          ),
        ),
        const Gap(32),
        const SectionHeader(
          eyebrow: 'About',
          title: 'Bespoke software, not a packaged product',
          body:
              'MasterFabric does not sell a one-size-fits-all SaaS product. It writes bespoke software '
              'for a single institution or private client. If a ready-made tool already solves the '
              'problem, the company says so. If it does not, it builds the product.',
        ),
        const Gap(14),
        Text(
          'MasterFabric delivers projects through business partnerships in Turkey and Europe, is a '
          'stakeholder in the digital transformation of public institutions in Turkey (especially '
          'education and military), and delivers qualified energy-transformation projects.',
          style: t.bodyMedium,
        ),
        const Gap(24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final l in SiteContent.siteLinks)
              ActionChip(
                avatar: Icon(l.icon, size: 18, color: MfColors.blue600),
                label: Text(l.label),
                onPressed: () => openLink(context, l.url),
                backgroundColor: MfColors.slate50,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
          ],
        ),
        const Gap(36),
        const Divider(),
        const Gap(20),
        const MfWordmark(),
        const Gap(12),
        Text(SiteContent.legalName, style: t.titleSmall),
        const Gap(4),
        Text(
          'Custom software and AI transformation for institutions and private clients.',
          style: t.bodySmall?.copyWith(color: MfColors.slate500),
        ),
        const Gap(12),
        Text(
          '© 2026 MasterFabric Inc. · Representative Claude Partner Network',
          style: t.bodySmall?.copyWith(color: MfColors.slate400),
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile(this.item);

  final LinkItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: MfColors.blue50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: MfColors.blue600, size: 20),
      ),
      title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(item.value, style: const TextStyle(color: MfColors.slate500, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right_rounded, color: MfColors.slate400),
      onTap: () => openLink(context, item.url),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: MfColors.blue600, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: MfColors.slate600, fontSize: 13.5, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
