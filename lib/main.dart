import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'duo/duo_bridge.dart';
import 'duo/dual_pane_layout.dart';
import 'duo/duo_nav_rail.dart';
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
    PillNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    'Software studio for mobile, web & AI',
  ),
  _Section(
    PillNavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'Services',
    ),
    'What we design, build and ship',
  ),
  _Section(
    PillNavItem(
      icon: Icons.workspaces_outline,
      selectedIcon: Icons.workspaces,
      label: 'Work',
    ),
    'Clients, Academy & open source',
  ),
  _Section(
    PillNavItem(
      icon: Icons.mail_outline_rounded,
      selectedIcon: Icons.mail_rounded,
      label: 'Contact',
    ),
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

  /// Global keys let each section keep its state (scroll offset, expanded
  /// cards…) when the page moves between the folded single-screen shell and
  /// the opened Duo panes: Apple asks for continuity across fold / unfold.
  final List<GlobalKey> _pageKeys = List.generate(
    _sections.length,
    (i) => GlobalKey(debugLabel: 'page$i'),
  );

  Widget get _contentStack => IndexedStack(
    index: _index,
    children: [
      for (var i = 0; i < _pages.length; i++)
        KeyedSubtree(key: _pageKeys[i], child: _pages[i]),
    ],
  );

  List<PillNavItem> get _items => [for (final s in _sections) s.item];

  PillNavBar _pillBar() =>
      PillNavBar(selectedIndex: _index, onSelected: _goTo, items: _items);

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
        final mq = MediaQuery.of(context);
        final geometry = DualPaneGeometry.resolve(mq, fold);
        if (geometry.isDual) return _dual(geometry, fold);
        // Single screen: still keep clear of an active camera housing.
        final occ = occlusionInsets(
          Offset.zero & mq.size,
          fold.activeOcclusions,
        );
        return MediaQuery(
          data: mq.copyWith(
            padding: maxInsets(mq.padding, occ),
            viewPadding: maxInsets(mq.viewPadding, occ),
          ),
          child: _single(fold),
        );
      },
    );
  }

  /// Folded / slab iPhone: the original single-screen layout, unchanged.
  Widget _single(FoldInfo fold) {
    // iPhone Duo outer display (and other displays where the system puts
    // its bars vertically): Apple moves bars to the side, so use the Duo
    // rail on the edge opposite the system vertical bar instead of a
    // bottom pill that would eat the shorter height.
    if (fold.verticalBarEdge != VerticalBarEdge.unspecified) {
      final railLeading = fold.verticalBarEdge == VerticalBarEdge.trailing;
      return Builder(
        builder: (context) {
          final pad = MediaQuery.paddingOf(context);
          final rail = Padding(
            padding: EdgeInsets.fromLTRB(
              railLeading ? pad.left + 10 : 6,
              12,
              railLeading ? 6 : pad.right + 10,
              pad.bottom + 12,
            ),
            child: Center(child: SingleChildScrollView(child: _rail(fold))),
          );
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 20,
              title: const MfWordmark(),
              actions: [_contactButton()],
            ),
            body: Row(
              children: [
                if (railLeading) rail,
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeLeft: railLeading,
                    removeRight: !railLeading,
                    child: _contentStack,
                  ),
                ),
                if (!railLeading) rail,
              ],
            ),
          );
        },
      );
    }
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

  /// Opened iPhone Duo, edge to edge: no app bars, backgrounds run under the
  /// status bar and to every display edge; only safe areas, the fold and
  /// camera housings are kept clear.
  Widget _dual(DualPaneGeometry geometry, FoldInfo fold) {
    final tabletop = geometry.axis == PaneAxis.vertical;
    // UIKit puts its vertical bar on one side; our rail takes the other.
    final railInContent = fold.verticalBarEdge == VerticalBarEdge.leading;

    final Widget primary = tabletop
        ? _controlsPane(fold)
        : _listPane(geometry, fold, withRail: !railInContent);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: Colors.white,
        child: DualPane(
          geometry: geometry,
          primary: KeyedSubtree(
            key: const ValueKey('mf-nav-pane'),
            child: primary,
          ),
          secondary: _contentPane(fold, withRail: railInContent && !tabletop),
          hingeColor: geometry.source == LayoutSource.breakpoint
              ? const Color(0xFFE2E8F0)
              : MfColors.slate100,
          occlusions: fold.activeOcclusions.toList(),
        ),
      ),
    );
  }

  Widget _rail(FoldInfo fold) => DuoNavRail(
    items: _items,
    selectedIndex: _index,
    onSelected: _goTo,
    footer: fold.hinge == HingeStatus.none || fold.hinge == HingeStatus.closed
        ? null
        : HingeGlyph(fold: fold),
  );

  /// Leading pane (book / flat): Duo rail + section list (list of the
  /// list-detail pair; drag a tile across the fold to open it).
  Widget _listPane(
    DualPaneGeometry geometry,
    FoldInfo fold, {
    required bool withRail,
  }) {
    return Builder(
      builder: (context) {
        final pad = MediaQuery.paddingOf(context);
        return Material(
          color: MfColors.slate50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  pad.left + 22,
                  pad.top + 18,
                  20,
                  0,
                ),
                child: const SizedBox(height: 44, child: MfWordmark()),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (withRail)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          pad.left + 14,
                          14,
                          2,
                          pad.bottom + 14,
                        ),
                        child: SingleChildScrollView(child: _rail(fold)),
                      ),
                    Expanded(
                      child: _SectionList(selected: _index, onSelected: _goTo),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bottom pane in tabletop posture (Apple: content above the fold,
  /// controls below): a posture strip and a 2x2 deck of large section
  /// controls. Even column count so nothing straddles the centre.
  Widget _controlsPane(FoldInfo fold) {
    return Builder(
      builder: (context) {
        final pad = MediaQuery.paddingOf(context);
        return Material(
          color: MfColors.slate50,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              pad.left + 16,
              16,
              pad.right + 16,
              pad.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HingeGlyph(fold: fold, showLabel: false),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tabletop${fold.angle >= 0 ? ' · ${fold.angle.round()}°' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MfColors.slate600,
                        ),
                      ),
                    ),
                    const Text(
                      'Drag a section up to open it',
                      style: TextStyle(fontSize: 12, color: MfColors.slate400),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      const gap = 12.0;
                      final w = (c.maxWidth - gap) / 2;
                      final h = ((c.maxHeight - gap) / 2).clamp(64.0, 150.0);
                      return Center(
                        child: Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (var i = 0; i < _sections.length; i++)
                              SizedBox(
                                width: w,
                                height: h,
                                child: _DraggableSection(
                                  index: i,
                                  child: _SectionTile(
                                    section: _sections[i],
                                    selected: i == _index,
                                    onTap: () => _goTo(i),
                                    fill: true,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Trailing / top pane: the selected section, full bleed. Accepts section
  /// tiles dragged across the fold.
  Widget _contentPane(FoldInfo fold, {required bool withRail}) {
    return Builder(
      key: const ValueKey('mf-content-pane'),
      builder: (context) {
        final pad = MediaQuery.paddingOf(context);
        final content = Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, pad.top + 10, pad.right + 8, 8),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (c, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(a),
                            child: c,
                          ),
                        ),
                        layoutBuilder: (cur, prev) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...prev, ?cur],
                        ),
                        child: Text(
                          _sections[_index].item.label,
                          key: ValueKey(_index),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: MfColors.slate900,
                          ),
                        ),
                      ),
                    ),
                    if (_index != 3) _contactButton(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: DragTarget<int>(
                  onAcceptWithDetails: (d) => _goTo(d.data),
                  builder: (context, candidates, _) => Stack(
                    children: [
                      Positioned.fill(child: _contentStack),
                      if (candidates.isNotEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: MfColors.blue50.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: MfColors.blue600,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Drop to open ${_sections[candidates.first ?? 0].item.label}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: MfColors.blue700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        return Material(
          color: Colors.white,
          child: withRail
              ? Row(
                  children: [
                    Expanded(child: content),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        4,
                        pad.top + 12,
                        pad.right + 14,
                        pad.bottom + 12,
                      ),
                      child: Center(
                        child: SingleChildScrollView(child: _rail(fold)),
                      ),
                    ),
                  ],
                )
              : content,
        );
      },
    );
  }
}

/// Long-press a section and drag it across the fold into the content pane.
class _DraggableSection extends StatelessWidget {
  const _DraggableSection({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      hapticFeedbackOnStart: true,
      feedback: Material(
        color: Colors.transparent,
        elevation: 14,
        shadowColor: const Color(0x55000000),
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 260,
          child: Opacity(
            opacity: 0.92,
            child: _SectionTile(
              section: _sections[index],
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

class _SectionList extends StatelessWidget {
  const _SectionList({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pad = MediaQuery.paddingOf(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(10, 14, 20, pad.bottom + 20),
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
        for (var i = 0; i < _sections.length; i++) ...[
          _DraggableSection(
            index: i,
            child: _SectionTile(
              section: _sections[i],
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

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.selected,
    required this.onTap,
    this.fill = false,
  });

  final _Section section;
  final bool selected;
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
