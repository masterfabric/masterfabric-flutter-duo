// Content mirrored from https://masterfabric.co and https://masterfabric.co/llm.txt
// (llm.txt v1.5.0, last updated 2026-10-29). Do not add facts that are not on the site.
import 'package:flutter/material.dart';

/// A titled feature with an icon.
class Feature {
  /// Creates a feature.
  const Feature(this.icon, this.title, this.body);

  /// Icon.
  final IconData icon;

  /// Title.
  final String title;

  /// Body.
  final String body;
}

/// One numbered step of a process.
class ProcessStep {
  /// Creates a step.
  const ProcessStep(this.number, this.title, this.body);

  /// Number.
  final String number;

  /// Title.
  final String title;

  /// Body.
  final String body;
}

/// A client shown in the Work section.
class ClientLogo {
  /// Creates a client entry.
  const ClientLogo(this.name, this.asset, this.url);

  /// Name.
  final String name;

  /// Asset.
  final String asset;

  /// Url.
  final String url;
}

/// A contact / site link with an icon.
class LinkItem {
  /// Creates a link.
  const LinkItem(this.icon, this.label, this.value, this.url);

  /// Icon.
  final IconData icon;

  /// Label.
  final String label;

  /// Value.
  final String value;

  /// Url.
  final String url;
}

/// Static copy of masterfabric.co shown in the app.
class SiteContent {
  // ---------- Hero ----------
  /// Hero eyebrow.
  static const heroEyebrow = 'Custom Software Development Studio';

  /// Hero title.
  static const heroTitle =
      'Custom Software,\nAI Transformation,\nBuilt to Brief';

  /// Hero body.
  static const heroBody =
      'We build custom software and AI transformation systems for '
      'institutions and private clients. Not a packaged product — the '
      'bespoke software you asked for.';

  /// Hero highlights.
  static const heroHighlights = [
    Feature(
      Icons.auto_awesome,
      'AI Transformation',
      'Requested systems, in production',
    ),
    Feature(Icons.bolt_rounded, 'Fast Delivery', 'Quick turnaround times'),
    Feature(
      Icons.support_agent_rounded,
      '24/7 Support',
      'Ongoing maintenance & support',
    ),
    Feature(
      Icons.code_rounded,
      'Custom Software',
      'Bespoke for institutions & private clients',
    ),
  ];

  // ---------- Claude Partner Network ----------
  /// Claude title.
  static const claudeTitle = 'We are a Claude Partner Network partner';

  /// Claude body.
  static const claudeBody =
      'MasterFabric designs and ships custom software with Claude. '
      'Institutions and private clients get a system written around their '
      'brief — planned, built, and reviewed with Claude in the loop.';

  /// Claude steps.
  static const claudeSteps = [
    ProcessStep(
      '01',
      'Take the brief',
      'We start from the request: the process, the data, and what done means for an institution or a private client.',
    ),
    ProcessStep(
      '02',
      'Plan with Claude',
      'Architecture, flows, and the agent plan are shaped with Claude before the production system is written.',
    ),
    ProcessStep(
      '03',
      'Build in review',
      'Agents draft the work. Engineers stay in the loop for design, security, and the calls Claude should not make alone.',
    ),
    ProcessStep(
      '04',
      'Prove and hand over',
      'Tests, fixes, and deploy are the same pass. The client leaves with software they own.',
    ),
  ];

  /// Claude code benefits.
  static const claudeCodeBenefits = [
    Feature(
      Icons.check_rounded,
      'Faster from brief to diff',
      'Routine work is drafted by the agent, so engineers spend their time on the hard calls.',
    ),
    Feature(
      Icons.check_rounded,
      'Every change reviewed',
      'Plans, diffs, and test runs stay visible. Nothing reaches production unseen.',
    ),
    Feature(
      Icons.check_rounded,
      'Your team keeps the skill',
      'We work inside your repositories and train your engineers on the same flow.',
    ),
  ];

  // ---------- AI-first ----------
  /// Ai first body.
  static const aiFirstBody =
      'We build custom software and AI transformation systems with an agentic, '
      'platform-based approach — for institutions and private clients.';

  /// Ai first.
  static const aiFirst = [
    Feature(
      Icons.lightbulb_outline_rounded,
      'AI-First Projects',
      'AI built in from day one — intelligent features and data-driven decisions.',
    ),
    Feature(
      Icons.smart_toy_outlined,
      'Agentic Coding',
      'AI-assisted development and human-in-the-loop workflows for faster delivery.',
    ),
    Feature(
      Icons.hub_outlined,
      'AI Integrations',
      'Chatbots, copilots, RAG, and custom AI solutions for your domain.',
    ),
  ];

  /// Sectors.
  static const sectors = [
    'Healthcare',
    'Fintech',
    'E-commerce',
    'Education',
    'Logistics',
  ];

  // ---------- What we are hired to build ----------
  /// Hired body.
  static const hiredBody =
      'MasterFabric is the company institutions and private clients call when '
      'they need bespoke software — especially requested AI transformations. '
      'We do not sell a packaged platform. We write the system that was asked for.';

  /// Hired for.
  static const hiredFor = [
    Feature(
      Icons.account_balance_outlined,
      'Institutions',
      'Enterprises and public organizations that need a system written around their process — including the AI transformation they asked for.',
    ),
    Feature(
      Icons.person_outline_rounded,
      'Private clients',
      'Founders and private companies that need bespoke software, not another off-the-shelf product they have to adapt to.',
    ),
    Feature(
      Icons.auto_awesome_outlined,
      'AI transformation',
      'Assistants, automation, and decision support delivered as production software on your data.',
    ),
    Feature(
      Icons.design_services_outlined,
      'Custom / bespoke software',
      'The exact product requested — mobile, web, and backend — owned by the client after launch.',
    ),
  ];

  /// Core services.
  static const coreServices = [
    'AI transformation: production assistants, automation, document intelligence, and decision support',
    'Custom / bespoke software for one organization',
    'Mobile and web products for iOS, Android, HarmonyOS, and the browser',
    'Cross-platform engineering with Flutter and React Native',
    'Native work with Swift and Kotlin when needed',
    'Integrations, APIs, admin consoles, and data layers',
    'Application modernization and performance-focused refactors',
    'Backend work with TypeScript / NestJS, Firebase, and cloud delivery',
    'CI/CD, handover, training, and ongoing maintenance',
  ];

  /// Process.
  static const process = [
    ProcessStep(
      '1',
      'Discover',
      'Map workflow, data, and the requested AI or product outcome.',
    ),
    ProcessStep(
      '2',
      'Design',
      'Architecture, interfaces, and where AI belongs.',
    ),
    ProcessStep(
      '3',
      'Build',
      'Mobile, web, backend, and models in short cycles.',
    ),
    ProcessStep('4', 'Operate', 'Handover, training, and ongoing improvement.'),
  ];

  // ---------- Technologies ----------
  /// Tech groups.
  static const techGroups = <String, List<String>>{
    'Editors & IDEs': ['Cursor', 'VS Code', 'JetBrains'],
    'Version control': ['GitHub', 'GitLab'],
    'Cloud & DevOps': ['Azure', 'Firebase', 'Vercel', 'Docker'],
    'Languages': ['TypeScript', 'Go', 'Dart', 'Swift', 'Kotlin', 'Python'],
    'AI': ['OpenAI', 'Anthropic', 'MCP'],
    'Our tools': ['Masterfabric CLI', 'Mobile CLI', 'Web CLI'],
  };

  // ---------- App design & growth ----------
  /// Growth.
  static const growth = [
    Feature(
      Icons.touch_app_outlined,
      'Event Tracking',
      'Track user interactions and behaviors with detailed analytics and insights',
    ),
    Feature(
      Icons.bug_report_outlined,
      'Crash Reports & Monitoring',
      'Monitor app stability and identify performance issues in real-time',
    ),
    Feature(
      Icons.insights_outlined,
      'Analytics Reports',
      'Comprehensive data insights and metrics to drive growth strategies',
    ),
    Feature(
      Icons.rocket_launch_outlined,
      'Release Monitoring',
      'Track deployment success and monitor issues with real-time alerts',
    ),
    Feature(
      Icons.storage_outlined,
      'BigData Management',
      'Process and analyze large datasets to extract meaningful insights',
    ),
    Feature(
      Icons.trending_up_rounded,
      'User Growth & Retention',
      'Optimize user acquisition and engagement to increase retention rates',
    ),
  ];

  /// Supercharge.
  static const supercharge = [
    Feature(
      Icons.timer_outlined,
      'Fast Implementation',
      'Get your optimized product or service live within 2-4 weeks with our proven delivery process.',
    ),
    Feature(
      Icons.query_stats_rounded,
      'Data-Driven Results',
      'Achieve measurable improvements in performance, user engagement, and conversion rates.',
    ),
    Feature(
      Icons.handshake_outlined,
      'Ongoing Support',
      'Continuous monitoring, updates, and technical support for long-term success.',
    ),
  ];

  // ---------- Work / clients ----------
  /// Clients.
  static const clients = [
    ClientLogo(
      'Infotech Academy',
      'assets/logos/infotechAcademy.png',
      'https://infotechacademy.com',
    ),
    ClientLogo(
      'Desi Alarm',
      'assets/logos/desiAlarm.png',
      'https://desialarm.com',
    ),
    ClientLogo(
      'İnce Hesap',
      'assets/logos/incehesap.png',
      'https://incehesap.com',
    ),
    ClientLogo(
      'Teknopark İstanbul',
      'assets/logos/teknoparkIstanbul.png',
      'https://www.teknoparkistanbul.com.tr/',
    ),
    ClientLogo('Ticimax', 'assets/logos/ticimax.png', 'https://ticimax.com'),
    ClientLogo('Veripark', 'assets/logos/veripark.png', 'https://veripark.com'),
  ];

  /// Academy tags.
  static const academyTags = [
    'Agentic AI Developer',
    'AI SDLC',
    'Private company programs',
    'MCP',
  ];

  // ---------- Company / contact ----------
  /// Legal name.
  static const legalName = 'MasterFabric Information Technology Inc.';

  /// Address.
  static const address =
      'Hacı Bayram Mah. Mahmut Atalay Sk. L Blok No: 6 İç Kapı No: 227, Altındağ / Ankara, Turkey';

  /// Hours.
  static const hours = ['Monday–Friday 09:00–18:00', 'Saturday 10:00–16:00'];

  /// Contact links.
  static const contactLinks = [
    LinkItem(
      Icons.mail_outline_rounded,
      'Project inquiries',
      'info@masterfabric.co',
      'mailto:info@masterfabric.co',
    ),
    LinkItem(
      Icons.edit_note_rounded,
      'Contact form',
      'masterfabric.co/contact',
      'https://masterfabric.co/contact/',
    ),
    LinkItem(
      Icons.school_outlined,
      'Academy',
      'academy@masterfabric.co',
      'mailto:academy@masterfabric.co',
    ),
    LinkItem(
      Icons.code_rounded,
      'GitHub',
      'github.com/masterfabric',
      'https://github.com/masterfabric',
    ),
    LinkItem(
      Icons.phone_iphone_rounded,
      'GitHub (mobile)',
      'github.com/masterfabric-mobile',
      'https://github.com/masterfabric-mobile',
    ),
    LinkItem(
      Icons.business_center_outlined,
      'LinkedIn',
      'linkedin.com/company/masterfabric',
      'https://www.linkedin.com/company/masterfabric',
    ),
  ];

  /// Site links.
  static const siteLinks = [
    LinkItem(
      Icons.miscellaneous_services_outlined,
      'Services',
      '',
      'https://masterfabric.co/services/',
    ),
    LinkItem(
      Icons.auto_awesome_outlined,
      'AI Transformation',
      '',
      'https://masterfabric.co/yapay-zeka-donusumu/',
    ),
    LinkItem(
      Icons.info_outline_rounded,
      'About',
      '',
      'https://masterfabric.co/about/',
    ),
    LinkItem(
      Icons.menu_book_outlined,
      'Docs',
      '',
      'https://catalogs.masterfabric.co/',
    ),
    LinkItem(
      Icons.work_outline_rounded,
      'Jobs',
      '',
      'https://masterfabric.co/jobs/',
    ),
    LinkItem(
      Icons.article_outlined,
      'Blog',
      '',
      'https://masterfabric.co/blog/',
    ),
  ];
}
