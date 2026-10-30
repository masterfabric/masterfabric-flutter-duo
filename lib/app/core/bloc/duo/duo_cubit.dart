import 'package:hello_flutter/app/core/base/base_view_model_cubit.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_state.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';

/// Exposes the [DuoBridge] (posture, reserved regions, native tab bar) as
/// cubit state so widgets rebuild through `BlocBuilder`.
class DuoCubit extends BaseViewModelCubit<DuoState> {
  /// Creates the cubit, seeded with the bridge's current values.
  DuoCubit({required DuoBridge bridge})
    : _bridge = bridge,
      super(
        DuoState(info: bridge.info, nativeTabsShown: bridge.nativeTabsShown),
      ) {
    _bridge.addListener(_onBridge);
  }

  final DuoBridge _bridge;

  void _onBridge() => stateChanger(
    DuoState(info: _bridge.info, nativeTabsShown: _bridge.nativeTabsShown),
  );

  /// Hands navigation to the native side tab bar while [visible] (closed
  /// iPhone Duo) and keeps its [selected] tab in sync.
  Future<void> syncNativeTabs({
    required List<({String title, String symbol})> tabs,
    required int selected,
    required bool visible,
  }) =>
      _bridge.syncNativeTabs(tabs: tabs, selected: selected, visible: visible);

  @override
  Future<void> close() {
    _bridge.removeListener(_onBridge);
    return super.close();
  }
}
