import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_flutter/app/core/base/base_view_model_bloc.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_event.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_state.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';

export 'duo_event.dart';

/// Exposes the [DuoBridge] (posture, reserved regions, native tab bar) as
/// bloc state so widgets rebuild through `BlocBuilder`.
class DuoBloc extends BaseViewModelBloc<DuoEvent, DuoState> {
  /// Creates the bloc, seeded with the bridge's current values.
  DuoBloc({required DuoBridge bridge})
    : _bridge = bridge,
      super(
        DuoState(info: bridge.info, nativeTabsShown: bridge.nativeTabsShown),
      ) {
    on<DuoBridgeChanged>(_onBridgeChanged);
    on<DuoNativeTabsSyncRequested>(_onNativeTabsSyncRequested);
    _bridge.addListener(_onBridge);
  }

  final DuoBridge _bridge;

  void _onBridge() => dispatch(
    DuoBridgeChanged(
      info: _bridge.info,
      nativeTabsShown: _bridge.nativeTabsShown,
    ),
  );

  void _onBridgeChanged(DuoBridgeChanged event, Emitter<DuoState> emit) =>
      emit(DuoState(info: event.info, nativeTabsShown: event.nativeTabsShown));

  Future<void> _onNativeTabsSyncRequested(
    DuoNativeTabsSyncRequested event,
    Emitter<DuoState> emit,
  ) => _bridge.syncNativeTabs(
    tabs: event.tabs,
    selected: event.selected,
    visible: event.visible,
  );

  @override
  Future<void> close() {
    _bridge.removeListener(_onBridge);
    return super.close();
  }
}
