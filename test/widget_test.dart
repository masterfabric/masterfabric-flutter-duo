import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_flutter/duo/duo_bridge.dart';
import 'package:hello_flutter/duo/dual_pane_layout.dart';
import 'package:hello_flutter/duo/duo_nav_rail.dart';
import 'package:hello_flutter/duo/fold_info.dart';
import 'package:hello_flutter/main.dart';
import 'package:hello_flutter/widgets/pill_nav_bar.dart';

void main() {
  tearDown(() => DuoBridge.instance.debugSet(FoldInfo.none));

  testWidgets('renders MasterFabric hero', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MasterFabricApp());
    expect(find.text('MasterFabric'), findsWidgets);
    expect(find.byKey(const ValueKey('mf-nav-pane')), findsNothing);
  });

  testWidgets('opened Duo inner display shows two panes', (tester) async {
    tester.view.physicalSize = const Size(951 * 3, 669 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MasterFabricApp());
    expect(find.byKey(const ValueKey('mf-nav-pane')), findsOneWidget);
    expect(find.byKey(const ValueKey('mf-content-pane')), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);

    // Selecting a section in the nav pane switches the content pane.
    await tester.tap(find.text('Clients, Academy & open source'));
    await tester.pumpAndSettle();
    expect(find.text('On Companies'), findsOneWidget);
  });

  testWidgets('panes avoid an active Duo fold region', (tester) async {
    tester.view.physicalSize = const Size(951 * 3, 669 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    DuoBridge.instance.debugSet(
      const FoldInfo(
        supported: true,
        hinge: HingeStatus.partiallyOpen,
        angle: 110,
        divisions: [
          ReservedRegion(Rect.fromLTWH(455, 0, 40, 669), active: true),
        ],
      ),
    );
    await tester.pumpWidget(const MasterFabricApp());
    final nav = tester.getRect(find.byKey(const ValueKey('mf-nav-pane')));
    final content = tester.getRect(
      find.byKey(const ValueKey('mf-content-pane')),
    );
    expect(nav.right, lessThanOrEqualTo(455));
    expect(content.left, greaterThanOrEqualTo(495));
  });

  Future<void> pumpDuo(WidgetTester tester, Size size, [FoldInfo? fold]) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    if (fold != null) DuoBridge.instance.debugSet(fold);
    await tester.pumpWidget(const MasterFabricApp());
  }

  testWidgets('open Duo uses the vertical Duo navbar, not the pill bar', (
    tester,
  ) async {
    await pumpDuo(tester, const Size(951, 669));
    expect(find.byType(DuoNavRail), findsOneWidget);
    expect(find.byType(PillNavBar), findsNothing);
    final rail = tester.getRect(find.byType(DuoNavRail));
    final nav = tester.getRect(find.byKey(const ValueKey('mf-nav-pane')));
    expect(rail.left, lessThan(nav.left + 40)); // leading edge of the list pane
    expect(rail.right, lessThan(nav.right));

    await tester.tap(
      find.descendant(
        of: find.byType(DuoNavRail),
        matching: find.byIcon(Icons.auto_awesome_outlined),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('mf-content-pane')),
        matching: find.text('Services'),
      ),
      findsWidgets,
    );
  });

  testWidgets('folded phone keeps the pill navbar', (tester) async {
    await pumpDuo(tester, const Size(402, 874));
    expect(find.byType(PillNavBar), findsOneWidget);
    expect(find.byType(DuoNavRail), findsNothing);
  });

  testWidgets('hinge glyph reflects posture and angle', (tester) async {
    await pumpDuo(
      tester,
      const Size(951, 669),
      const FoldInfo(
        supported: true,
        hinge: HingeStatus.partiallyOpen,
        angle: 120,
        divisions: [
          ReservedRegion(Rect.fromLTWH(455, 0, 40, 669), active: true),
        ],
      ),
    );
    expect(find.byType(HingeGlyph), findsOneWidget);
    expect(find.text('Book'), findsOneWidget);
    expect(find.text('120°'), findsOneWidget);
  });

  testWidgets('tabletop: content above the fold, controls below', (
    tester,
  ) async {
    await pumpDuo(
      tester,
      const Size(669, 951),
      const FoldInfo(
        supported: true,
        hinge: HingeStatus.partiallyOpen,
        angle: 100,
        divisions: [
          ReservedRegion(Rect.fromLTWH(0, 455, 669, 40), active: true),
        ],
      ),
    );
    final content = tester.getRect(
      find.byKey(const ValueKey('mf-content-pane')),
    );
    final controls = tester.getRect(find.byKey(const ValueKey('mf-nav-pane')));
    expect(content.bottom, lessThanOrEqualTo(455));
    expect(controls.top, greaterThanOrEqualTo(495));
    // The section controls sit below the fold, not straddling it.
    for (final label in ['Home', 'Services', 'Work', 'Contact']) {
      final r = tester.getRect(find.text(label).last);
      expect(r.top, greaterThanOrEqualTo(495), reason: label);
      expect(r.bottom, lessThanOrEqualTo(951), reason: label);
    }
  });

  testWidgets('system vertical bar on the leading edge moves the rail', (
    tester,
  ) async {
    await pumpDuo(
      tester,
      const Size(951, 669),
      const FoldInfo(
        supported: true,
        hinge: HingeStatus.fullyOpen,
        angle: 180,
        verticalBarEdge: VerticalBarEdge.leading,
      ),
    );
    final rail = tester.getRect(find.byType(DuoNavRail));
    expect(rail.left, greaterThan(951 / 2));
  });

  testWidgets('dragging a section across the fold opens it', (tester) async {
    await pumpDuo(tester, const Size(951, 669));
    final tile = find.text('Clients, Academy & open source');
    final gesture = await tester.startGesture(tester.getCenter(tile));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(const Offset(720, 400));
    await tester.pump();
    expect(find.text('Drop to open Work'), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('On Companies'), findsOneWidget);
  });

  testWidgets('section state survives fold / unfold', (tester) async {
    await pumpDuo(tester, const Size(402, 874));
    final before = tester.state(find.byType(Scrollable).first);
    tester.view.physicalSize = const Size(951 * 3, 669 * 3);
    await tester.pumpAndSettle();
    expect(find.byType(DuoNavRail), findsOneWidget);
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    await tester.pumpAndSettle();
    expect(
      identical(tester.state(find.byType(Scrollable).first), before),
      isTrue,
    );
  });

  test('occlusionInsets pads away from a camera housing', () {
    const pane = Rect.fromLTWH(476, 0, 475, 669);
    final i = occlusionInsets(pane, const [Rect.fromLTWH(860, 0, 60, 30)]);
    expect(i, const EdgeInsets.only(top: 30));
    expect(
      occlusionInsets(pane, const [Rect.fromLTWH(10, 0, 60, 30)]),
      EdgeInsets.zero,
    );
  });

  group('DualPaneGeometry.resolve', () {
    test('flat display splits where the inactive division sits', () {
      const fold = FoldInfo(
        hinge: HingeStatus.fullyOpen,
        divisions: [
          ReservedRegion(Rect.fromLTWH(470, 0, 0, 669), active: false),
        ],
      );
      final g = DualPaneGeometry.resolve(
        const MediaQueryData(size: Size(951, 669)),
        fold,
      );
      expect(g.source, LayoutSource.breakpoint);
      expect(g.hinge.center.dx, closeTo(470, 0.01));
    });

    const phone = MediaQueryData(size: Size(402, 874));
    const inner = MediaQueryData(size: Size(951, 669));

    test('landscape phone stays single', () {
      const landscape = MediaQueryData(size: Size(874, 402));
      expect(
        DualPaneGeometry.resolve(landscape, FoldInfo.none).isDual,
        isFalse,
      );
    });

    test('slab / outer display stays single', () {
      expect(DualPaneGeometry.resolve(phone, FoldInfo.none).isDual, isFalse);
    });

    test('flat inner display splits at the centre crease', () {
      final g = DualPaneGeometry.resolve(inner, FoldInfo.none);
      expect(g.source, LayoutSource.breakpoint);
      expect(g.hinge.center.dx, closeTo(475.5, 0.01));
    });

    test('Flutter hinge display feature wins', () {
      final mq = inner.copyWith(
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(470, 0, 10, 669),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.unknown,
          ),
        ],
      );
      final g = DualPaneGeometry.resolve(mq, FoldInfo.none);
      expect(g.source, LayoutSource.displayFeature);
      expect(g.axis, PaneAxis.horizontal);
    });

    test('horizontal fold stacks panes (tabletop)', () {
      const fold = FoldInfo(
        hinge: HingeStatus.partiallyOpen,
        divisions: [
          ReservedRegion(Rect.fromLTWH(0, 455, 669, 40), active: true),
        ],
      );
      final g = DualPaneGeometry.resolve(
        const MediaQueryData(size: Size(669, 951)),
        fold,
      );
      expect(g.source, LayoutSource.reservedRegion);
      expect(g.axis, PaneAxis.vertical);
    });

    test('inactive or fully-open divisions are ignored', () {
      const lagging = FoldInfo(
        hinge: HingeStatus.fullyOpen,
        divisions: [
          ReservedRegion(Rect.fromLTWH(455, 0, 40, 669), active: true),
        ],
      );
      expect(
        DualPaneGeometry.resolve(inner, lagging).source,
        LayoutSource.breakpoint,
      );
    });
  });
}
