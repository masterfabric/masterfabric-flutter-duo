// Layout sweep at real iPhone Duo sizes: every section in every posture must
// lay out without overflow / framework errors, keep even panes, and keep
// content clear of the fold.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/app/app.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_nav_rail.dart';
import 'package:hello_flutter/app/helper/layout/duo/fold_info.dart';
import 'package:hello_flutter/app/widgets/pill_nav_bar.dart';

class _Case {
  const _Case(this.name, this.size, this.pad, this.fold);
  final String name;
  final Size size;
  final EdgeInsets pad;
  final FoldInfo fold;
}

const _closed = FoldInfo(supported: true, hinge: HingeStatus.closed, angle: 0);
const _flat = FoldInfo(
  supported: true,
  hinge: HingeStatus.fullyOpen,
  angle: 180,
  verticalBarEdge: VerticalBarEdge.trailing,
  divisions: [ReservedRegion(Rect.fromLTWH(475.5, 0, 0, 669), active: false)],
);
const _book = FoldInfo(
  supported: true,
  hinge: HingeStatus.partiallyOpen,
  angle: 120,
  verticalBarEdge: VerticalBarEdge.trailing,
  divisions: [ReservedRegion(Rect.fromLTWH(455.5, 0, 40, 669), active: true)],
);
const _table = FoldInfo(
  supported: true,
  hinge: HingeStatus.partiallyOpen,
  angle: 100,
  divisions: [ReservedRegion(Rect.fromLTWH(0, 455.5, 669, 40), active: true)],
);

const _cases = [
  _Case(
    'outer display',
    Size(466, 678),
    EdgeInsets.fromLTRB(0, 54, 0, 30),
    _closed,
  ),
  _Case(
    'outer display, vertical bar',
    Size(466, 678),
    EdgeInsets.fromLTRB(0, 0, 54, 20),
    FoldInfo(
      supported: true,
      hinge: HingeStatus.closed,
      angle: 0,
      verticalBarEdge: VerticalBarEdge.trailing,
    ),
  ),
  _Case('inner flat', Size(951, 669), EdgeInsets.fromLTRB(0, 0, 54, 20), _flat),
  _Case('inner book', Size(951, 669), EdgeInsets.fromLTRB(0, 0, 54, 20), _book),
  _Case(
    'inner portrait',
    Size(669, 951),
    EdgeInsets.fromLTRB(0, 54, 0, 30),
    FoldInfo(supported: true, hinge: HingeStatus.fullyOpen, angle: 180),
  ),
  _Case(
    'inner tabletop',
    Size(669, 951),
    EdgeInsets.fromLTRB(0, 54, 0, 30),
    _table,
  ),
  _Case(
    'iPhone slab',
    Size(402, 874),
    EdgeInsets.fromLTRB(0, 62, 0, 34),
    FoldInfo.none,
  ),
];

const _icons = [
  Icons.home_outlined,
  Icons.auto_awesome_outlined,
  Icons.workspaces_outline,
  Icons.mail_outline_rounded,
];

Future<void> _pump(WidgetTester tester, _Case c) async {
  tester.view.physicalSize = c.size * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.padding = FakeViewPadding(
    left: c.pad.left * 3,
    top: c.pad.top * 3,
    right: c.pad.right * 3,
    bottom: c.pad.bottom * 3,
  );
  tester.view.viewPadding = tester.view.padding;
  addTearDown(tester.view.reset);
  DuoBridge.instance.debugSet(c.fold);
  await tester.pumpWidget(const MasterFabricApp());
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => DuoBridge.instance.debugSet(FoldInfo.none));

  for (final c in _cases) {
    for (var tab = 0; tab < 4; tab++) {
      testWidgets('${c.name}: section $tab lays out cleanly to the end', (
        tester,
      ) async {
        await _pump(tester, c);
        if (tab > 0) {
          await tester.tap(find.byIcon(_icons[tab]).first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        // Scroll every visible scrollable to its end: overflows further down
        // a page surface as exceptions here.
        final scrollables = find.byType(Scrollable).hitTestable();
        for (var i = 0; i < scrollables.evaluate().length; i++) {
          final state = tester.state<ScrollableState>(scrollables.at(i));
          final pos = state.position;
          if (pos.maxScrollExtent > 0) {
            pos.jumpTo(pos.maxScrollExtent);
            await tester.pump();
            expect(tester.takeException(), isNull);
          }
        }
      });
    }
  }

  testWidgets('book: panes are even and nothing sits in the fold', (
    tester,
  ) async {
    await _pump(tester, _cases[3]);
    final nav = tester.getRect(find.byKey(const ValueKey('mf-nav-pane')));
    final content = tester.getRect(
      find.byKey(const ValueKey('mf-content-pane')),
    );
    expect((nav.width - content.width).abs(), lessThanOrEqualTo(1));
    // Backgrounds meet at the fold centre; text never enters the fold.
    expect(nav.right, closeTo(475.5, 1));
    for (final e
        in find
            .descendant(
              of: find.byKey(const ValueKey('mf-nav-pane')),
              matching: find.byType(Text),
            )
            .evaluate()) {
      final r = tester.getRect(find.byWidget(e.widget).first);
      expect(r.right, lessThanOrEqualTo(455.5));
    }
  });

  testWidgets('flat: seam splits the panes evenly at the inactive division', (
    tester,
  ) async {
    await _pump(tester, _cases[2]);
    final nav = tester.getRect(find.byKey(const ValueKey('mf-nav-pane')));
    final content = tester.getRect(
      find.byKey(const ValueKey('mf-content-pane')),
    );
    expect((nav.width - content.width).abs(), lessThanOrEqualTo(2));
  });

  testWidgets('open: one navigation only, clear of the display corner', (
    tester,
  ) async {
    await _pump(tester, _cases[3]);
    expect(find.byType(DuoNavRail), findsNothing);
    expect(find.byType(PillNavBar), findsNothing);
    final header = tester.getRect(find.text('Explore'));
    expect(header.left, greaterThanOrEqualTo(20));
  });

  testWidgets('outer display with a vertical bar uses the side rail', (
    tester,
  ) async {
    await _pump(tester, _cases[1]);
    expect(find.byType(DuoNavRail), findsOneWidget);
    expect(find.byType(PillNavBar), findsNothing);
    // Opposite the trailing system bar.
    expect(tester.getRect(find.byType(DuoNavRail)).left, lessThan(100));
  });

  testWidgets('tabletop deck tiles are evenly sized', (tester) async {
    await _pump(tester, _cases[5]);
    final tiles = [
      for (final l in ['Home', 'Services', 'Work', 'Contact'])
        tester.getRect(
          find
              .ancestor(of: find.text(l).last, matching: find.byType(SizedBox))
              .first,
        ),
    ];
    for (final r in tiles) {
      expect(r.size, tiles.first.size);
      expect(r.top, greaterThanOrEqualTo(495.5));
    }
  });
}
