import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_bloc.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_state.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_bloc.dart';
import 'package:hello_flutter/app/helper/layout/duo/dual_pane_layout.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_nav_rail.dart';
import 'package:hello_flutter/app/helper/layout/duo/fold_info.dart';
import 'package:hello_flutter/app/theme/app_theme.dart';
import 'package:hello_flutter/app/views/view_contact/contact_view.dart';
import 'package:hello_flutter/app/views/view_home/home_view.dart';
import 'package:hello_flutter/app/views/view_services/services_view.dart';
import 'package:hello_flutter/app/views/view_shell/models/shell_section.dart';
import 'package:hello_flutter/app/views/view_shell/widgets/section_list_widget.dart';
import 'package:hello_flutter/app/views/view_work/work_view.dart';
import 'package:hello_flutter/app/widgets/mf_logo.dart';
import 'package:hello_flutter/app/widgets/pill_nav_bar.dart';

/// The app shell: picks the navigation for the current iPhone Duo posture
/// (native side tab bar, pill bar, section list or tabletop deck) and shows
/// the selected section. State lives in [NavigationBloc] and [DuoBloc].
class ShellView extends StatefulWidget {
  /// Creates the shell.
  const ShellView({super.key});

  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<ShellView> {
  int get _index => context.read<NavigationBloc>().state.index;

  void _goTo(int i) =>
      context.read<NavigationBloc>().add(NavigationSectionSelected(i));

  /// iPhone Duo closed: hand navigation to the native UIKit tab bar, which
  /// the system renders in its vertical bar on the outer display.
  void _syncNativeTabs(bool closed) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DuoBloc>().add(
        DuoNativeTabsSyncRequested(
          tabs: [
            for (final s in kShellSections)
              (title: s.item.label, symbol: s.symbol),
          ],
          selected: _index,
          visible: closed,
        ),
      );
    });
  }

  late final List<Widget> _pages = <Widget>[
    HomeView(onNavigate: _goTo),
    const ServicesView(),
    const WorkView(),
    const ContactView(),
  ];

  /// Global keys let each section keep its state (scroll offset, expanded
  /// cards…) when the page moves between the folded single-screen shell and
  /// the opened Duo panes: Apple asks for continuity across fold / unfold.
  final List<GlobalKey> _pageKeys = List.generate(
    kShellSections.length,
    (i) => GlobalKey(debugLabel: 'page$i'),
  );

  Widget get _contentStack => IndexedStack(
    index: _index,
    children: [
      for (var i = 0; i < _pages.length; i++)
        KeyedSubtree(key: _pageKeys[i], child: _pages[i]),
    ],
  );

  List<PillNavItem> get _items => [for (final s in kShellSections) s.item];

  PillNavBar _pillBar() =>
      PillNavBar(selectedIndex: _index, onSelected: _goTo, items: _items);

  Widget _contactButton() => FilledButton(
    onPressed: () => _goTo(NavigationBloc.contactIndex),
    style: FilledButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 14),
    ),
    child: const Text('Contact'),
  );

  @override
  Widget build(BuildContext context) {
    // Rebuild on section changes and on posture / native tab bar changes.
    context.watch<NavigationBloc>();
    return BlocBuilder<DuoBloc, DuoState>(
      builder: (context, duo) {
        final fold = duo.info;
        final mq = MediaQuery.of(context);
        final geometry = DualPaneGeometry.resolve(mq, fold);
        _syncNativeTabs(!geometry.isDual && fold.hinge == HingeStatus.closed);
        if (geometry.isDual) return _dual(geometry, fold);
        // Single screen: still keep clear of an active camera housing.
        final occ = occlusionInsets(
          Offset.zero & mq.size,
          fold.activeOcclusions,
          mq.padding,
        );
        return MediaQuery(
          data: mq.copyWith(
            padding: maxInsets(mq.padding, occ),
            viewPadding: maxInsets(mq.viewPadding, occ),
          ),
          child: _single(fold, nativeTabsShown: duo.nativeTabsShown),
        );
      },
    );
  }

  /// Folded / slab iPhone: the original single-screen layout, unchanged.
  Widget _single(FoldInfo fold, {required bool nativeTabsShown}) {
    // Native UIKit tab bar is the navigation: no Flutter rail / pill.
    if (nativeTabsShown) {
      // Closed Duo: the native side navbar (platform channel) in the
      // system's vertical bar is the only navigation. It lives in the side
      // safe area, which the content already insets by, so nothing sits
      // under it and the content keeps scrolling.
      return Scaffold(
        appBar: AppBar(titleSpacing: 20, title: const MfWordmark()),
        body: _contentStack,
      );
    }
    // iPhone Duo outer display (and other displays where the system puts
    // its bars vertically): Apple moves bars to the side, so use the Duo
    // rail on the edge opposite the system vertical bar instead of a
    // bottom pill that would eat the shorter height.
    if (fold.verticalBarEdge != VerticalBarEdge.unspecified) {
      final railLeading = fold.verticalBarEdge == VerticalBarEdge.trailing;
      return Builder(
        builder: (context) {
          final mq = MediaQuery.of(context);
          final pad = mq.padding;
          // The rail floats over full-bleed content; content just gets the
          // rail's footprint as extra safe area on that side.
          const gutter = 10.0;
          const footprint = gutter + DuoNavRail.width;
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 20,
              title: const MfWordmark(),
              actions: [
                if (_index != NavigationBloc.contactIndex) _contactButton(),
              ],
              actionsPadding: const EdgeInsets.only(right: 20),
            ),
            body: Builder(
              builder: (context) {
                final body = MediaQuery.paddingOf(context);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          padding: body.copyWith(
                            left: railLeading
                                ? body.left + footprint
                                : body.left,
                            right: railLeading
                                ? body.right
                                : body.right + footprint,
                          ),
                        ),
                        child: _contentStack,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: railLeading ? pad.left + gutter : null,
                      right: railLeading ? null : pad.right + gutter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 12,
                          bottom: body.bottom + 12,
                        ),
                        child: Center(
                          child: SingleChildScrollView(child: _rail(fold)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const MfWordmark(),
        actions: [if (_index != NavigationBloc.contactIndex) _contactButton()],
        actionsPadding: const EdgeInsets.only(right: 20),
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
    // One navigation at a time: the leading pane *is* the Duo navbar
    // (book / flat) or the control deck (tabletop).
    final Widget primary = tabletop ? _controlsPane(fold) : _navPane(fold);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DualPane(
        geometry: geometry,
        primary: KeyedSubtree(
          key: const ValueKey('mf-nav-pane'),
          child: primary,
        ),
        secondary: _contentPane(fold),
        hingeColor: Colors.white,
        occlusions: fold.activeOcclusions.toList(),
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

  /// Leading pane (book / flat): the expanded Duo navbar. It is the only
  /// navigation while open (list of the list-detail pair); drag a tile
  /// across the fold to open it.
  Widget _navPane(FoldInfo fold) {
    return Builder(
      builder: (context) {
        final pad = MediaQuery.paddingOf(context);
        return Material(
          color: MfColors.slate50,
          child: Padding(
            padding: EdgeInsets.only(left: pad.left, right: pad.right),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24, pad.top + 18, 20, 0),
                  child: const SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: MfWordmark(),
                    ),
                  ),
                ),
                Expanded(
                  child: SectionList(selected: _index, onSelected: _goTo),
                ),
                if (fold.hinge == HingeStatus.none)
                  SizedBox(height: pad.bottom)
                else
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 20, pad.bottom + 14),
                    child: Row(
                      children: [
                        HingeGlyph(fold: fold, showLabel: false),
                        const SizedBox(width: 10),
                        Text(
                          HingeGlyph.postureLabel(fold),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: MfColors.slate600,
                          ),
                        ),
                        if (fold.angle >= 0)
                          Text(
                            '  ·  ${fold.angle.round()}°',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: MfColors.slate400,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
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
              pad.top + 16,
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
                            for (var i = 0; i < kShellSections.length; i++)
                              SizedBox(
                                width: w,
                                height: h,
                                child: DraggableSection(
                                  index: i,
                                  child: SectionTile(
                                    section: kShellSections[i],
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
  Widget _contentPane(FoldInfo fold) {
    return Builder(
      key: const ValueKey('mf-content-pane'),
      builder: (context) {
        final pad = MediaQuery.paddingOf(context);
        final content = Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                pad.left + 20,
                pad.top + 14,
                pad.right + 20,
                6,
              ),
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
                          kShellSections[_index].item.label,
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
                    if (_index != NavigationBloc.contactIndex) _contactButton(),
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
                                'Drop to open ${kShellSections[candidates.first ?? 0].item.label}',
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
        return Material(color: Colors.white, child: content);
      },
    );
  }
}
