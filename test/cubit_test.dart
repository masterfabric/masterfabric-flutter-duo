import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_cubit.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_state.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_cubit.dart';
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

  group('NavigationCubit', () {
    test('clamps the initial index', () {
      expect(NavigationCubit(bridge: bridge, initialIndex: 9).state.index, 3);
      expect(NavigationCubit(bridge: bridge, initialIndex: -2).state.index, 0);
    });

    blocTest<NavigationCubit, NavigationState>(
      'select emits the new index and ignores repeats / out of range',
      build: () => NavigationCubit(bridge: bridge),
      act: (c) => c
        ..select(2)
        ..select(2)
        ..select(7)
        ..select(NavigationCubit.contactIndex),
      expect: () => const [
        NavigationState(index: 2),
        NavigationState(index: 3),
      ],
    );

    blocTest<NavigationCubit, NavigationState>(
      'native side tab bar taps select the section',
      build: () => NavigationCubit(bridge: bridge),
      act: (_) => bridge.onNativeTabSelected?.call(1),
      expect: () => const [NavigationState(index: 1)],
    );

    test('close detaches from the native tab bar', () async {
      final cubit = NavigationCubit(bridge: bridge);
      expect(bridge.onNativeTabSelected, isNotNull);
      await cubit.close();
      expect(bridge.onNativeTabSelected, isNull);
    });
  });

  group('DuoCubit', () {
    const closed = FoldInfo(
      supported: true,
      hinge: HingeStatus.closed,
      verticalBarEdge: VerticalBarEdge.trailing,
    );

    test('starts from the bridge state', () {
      expect(DuoCubit(bridge: bridge).state, const DuoState());
    });

    blocTest<DuoCubit, DuoState>(
      'mirrors posture and native tab bar changes from the bridge',
      build: () => DuoCubit(bridge: bridge),
      act: (_) => bridge
        ..debugSet(closed)
        ..debugSetNativeTabsShown(true),
      expect: () => const [
        DuoState(info: closed),
        DuoState(info: closed, nativeTabsShown: true),
      ],
    );

    test('stops listening after close', () async {
      final cubit = DuoCubit(bridge: bridge);
      await cubit.close();
      bridge.debugSet(closed);
      expect(cubit.state, const DuoState());
    });
  });
}
