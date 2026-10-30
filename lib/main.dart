import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'duo/duo_bridge.dart';
import 'duo/dual_pane_layout.dart';
import 'duo/fold_info.dart';
import 'screens/about_contact_screen.dart';
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/work_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/mf_logo.dart';
import 'widgets/pill_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DuoBridge.instance.start();
  runApp(const MasterFabricApp());
}

class MasterFabricApp extends StatelessWidget {
  const MasterFabricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MasterFabric',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const RootShell(),
    );
  }
}

class _Section {
  const _Section(this.item, this.subtitle);
  final PillNavItem item;
  final String subtitle;
}

const _sections = [
  _Section(
    PillNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    'Software studio for mobile, web & AI',
  ),
  _Section(
    PillNavItem(icon: Icons.auto_awesome_outlined, selectedIcon: Icons.auto_awesome, label: 'Services'),
    'What we design, build and ship',
  ),
  _Section(
    PillNavItem(icon: Icons.workspaces_outline, selectedIcon: Icons.workspaces, label: 'Work'),
    'Clients, Academy & open source',
  ),
  _Section(
    PillNavItem(icon: Icons.mail_outline_rounded, selectedIcon: Icons.mail_rounded, label: 'Contact'),
    'Start a project with us',
  ),
];

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index = _initialTab();

  /// Allows opening a specific tab at launch (used for screenshots):
  /// `flutter run --dart-define=MF_TAB=2`
  static int _initialTab() {
    const defined = String.fromEnvironment('MF_TAB');
    final raw = defined.isNotEmpty ? defined : Platform.environment['MF_TAB'];
    final value = int.tryParse(raw ?? '') ?? 0;
    return value.clamp(0, 3);
  }

  void _goTo(int i) => setState(() => _index = i);

  late final List<Widget> _pages = <Widget>[
    HomeScreen(onNavigate: _goTo),
    const ServicesScreen(),
    const WorkScreen(),
    const AboutContactScreen(),
  ];

  Widget get _contentStack => IndexedStack(index: _index, children: _pages);

  PillNavBar _pillBar() => PillNavBar(
        selectedIndex: _index,
        onSelected: _goTo,
        items: [for (final s in _sections) s.item],
      );

  Widget _contactButton() => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: FilledButton(
          onPressed: () => _goTo(3),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Text('Contact'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DuoBridge.instance,
      builder: (context, _) {
        final fold = DuoBridge.instance.info;
        final geometry = DualPaneGeometry.resolve(MediaQuery.of(context), fold);
        return geometry.isDual ? _dual(geometry, fold) : _single();
      },
    );
  }

  /// Folded / slab iPhone: the original single-screen layout, unchanged.
  Widget _single() {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const MfWordmark(),
        actions: [_contactButton()],
      ),
      body: _contentStack,
      extendBody: true,
      bottomNavigationBar: _pillBar(),
    );
  }

  /// Opened iPhone Duo: navigation pane + content pane on either side of the
  /// fold. The pill bar lives entirely inside the navigation pane.
  Widget _dual(DualPaneGeometry geometry, FoldInfo fold) {
    final navPane = Scaffold(
      key: const ValueKey('mf-nav-pane'),
      backgroundColor: MfColors.slate50,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: MfColors.slate50,
        title: const MfWordmark(),
      ),
      extendBody: true,
      body: _SectionList(
        selected: _index,
        onSelected: _goTo,
        caption: _caption(geometry, fold),
      ),
      bottomNavigationBar: _pillBar(),
    );

    final contentPane = Scaffold(
      key: const ValueKey('mf-content-pane'),
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          _sections[_index].item.label,
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
        actions: [if (_index != 3) _contactButton()],
      ),
      body: _contentStack,
    );

    return ColoredBox(
      color: MfColors.slate50,
      child: DualPane(
        geometry: geometry,
        primary: navPane,
        secondary: contentPane,
        hingeColor: const Color(0xFFE2E8F0),
      ),
    );
  }

  static String _caption(DualPaneGeometry g, FoldInfo fold) {
    final src = switch (g.source) {
      LayoutSource.displayFeature => 'Flutter display feature',
      LayoutSource.reservedRegion => 'iPhone Duo fold region',
      LayoutSource.breakpoint => 'opened inner display',
      LayoutSource.single => 'single screen',
    };
    final hinge = fold.hinge == HingeStatus.none
        ? ''
        : ' · hinge ${fold.hinge.name}${fold.angle >= 0 ? ' ${fold.angle.round()}°' : ''}';
    return 'Two-pane layout · $src$hinge';
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.selected, required this.onSelected, required this.caption});

  final int selected;
  final ValueChanged<int> onSelected;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.paddingOf(context).bottom + 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
          child: Text(
            'Explore MasterFabric',
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
        ),
        for (var i = 0; i < _sections.length; i++) ...[
          _SectionTile(
            section: _sections[i],
            selected: i == selected,
            onTap: () => onSelected(i),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.view_sidebar_outlined, size: 14, color: MfColors.slate400),
            const SizedBox(width: 6),
            Expanded(
              child: Text(caption, style: const TextStyle(fontSize: 11, color: MfColors.slate400)),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section, required this.selected, required this.onTap});

  final _Section section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : MfColors.slate900;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? MfColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? MfColors.slate900 : const Color(0xFFE2E8F0)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white.withValues(alpha: 0.12) : MfColors.blue50,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.item.label,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        section.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: selected ? const Color(0xFFCBD5E1) : MfColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: selected ? Colors.white : MfColors.slate400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
