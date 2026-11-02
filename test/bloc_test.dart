import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_bloc.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_state.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_bloc.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_state.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';
import 'package:hello_flutter/app/helper/layout/duo/fold_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bridge = DuoBridge.instance;

  setUp(() {
    bridge
      ..debugSet(FoldInfo.none)
      ..debugSetNativeTabsShown(false);
  });

  group('NavigationBloc', () {
    test('clamps the initial index', () {
      expect(NavigationBloc(bridge: bridge, initialIndex: 9).state.index, 3);
      expect(NavigationBloc(bridge: bridge, initialIndex: -2).state.index, 0);
    });

    blocTest<NavigationBloc, NavigationState>(
      'NavigationSectionSelected emits the new index and ignores repeats / '
      'out of range',
      build: () => NavigationBloc(bridge: bridge),
      act: (b) => b
        ..add(const NavigationSectionSelected(2))
        ..add(const NavigationSectionSelected(2))
        ..add(const NavigationSectionSelected(7))
        ..add(const NavigationSectionSelected(-1))
        ..add(const NavigationSectionSelected(NavigationBloc.contactIndex)),
      expect: () => const [
        NavigationState(index: 2),
        NavigationState(index: 3),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'native side tab bar taps select the section',
      build: () => NavigationBloc(bridge: bridge),
      act: (_) => bridge.onNativeTabSelected?.call(1),
      expect: () => const [NavigationState(index: 1)],
    );

    test('close detaches from the native tab bar', () async {
      final bloc = NavigationBloc(bridge: bridge);
      expect(bridge.onNativeTabSelected, isNotNull);
      await bloc.close();
      expect(bridge.onNativeTabSelected, isNull);
    });
  });

  group('DuoBloc', () {
    const closed = FoldInfo(
      supported: true,
      hinge: HingeStatus.closed,
      verticalBarEdge: VerticalBarEdge.trailing,
    );

    test('starts from the bridge state', () {
      expect(DuoBloc(bridge: bridge).state, const DuoState());
    });

    blocTest<DuoBloc, DuoState>(
      'mirrors posture and native tab bar changes from the bridge',
      build: () => DuoBloc(bridge: bridge),
      act: (_) => bridge
        ..debugSet(closed)
        ..debugSetNativeTabsShown(true),
      expect: () => const [
        DuoState(info: closed),
        DuoState(info: closed, nativeTabsShown: true),
      ],
    );

    blocTest<DuoBloc, DuoState>(
      'DuoBridgeChanged emits the snapshot it carries',
      build: () => DuoBloc(bridge: bridge),
      act: (b) =>
          b.add(const DuoBridgeChanged(info: closed, nativeTabsShown: true)),
      expect: () => const [DuoState(info: closed, nativeTabsShown: true)],
    );

    blocTest<DuoBloc, DuoState>(
      'DuoNativeTabsSyncRequested without the native bridge emits nothing',
      build: () => DuoBloc(bridge: bridge),
      act: (b) => b.add(
        const DuoNativeTabsSyncRequested(
          tabs: [(title: 'Home', symbol: 'house')],
          selected: 0,
          visible: true,
        ),
      ),
      expect: () => const <DuoState>[],
    );

    test('stops listening after close', () async {
      final bloc = DuoBloc(bridge: bridge);
      await bloc.close();
      bridge.debugSet(closed);
      expect(bloc.state, const DuoState());
    });
  });
}
