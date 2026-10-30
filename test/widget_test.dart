import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_flutter/duo/duo_bridge.dart';
import 'package:hello_flutter/duo/dual_pane_layout.dart';
import 'package:hello_flutter/duo/fold_info.dart';
import 'package:hello_flutter/main.dart';

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
    expect(find.text('Explore MasterFabric'), findsOneWidget);

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

  group('DualPaneGeometry.resolve', () {
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
