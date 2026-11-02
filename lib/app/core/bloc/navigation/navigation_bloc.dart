import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_flutter/app/core/base/base_view_model_bloc.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_event.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_state.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';

export 'navigation_event.dart';

/// Owns the selected section for every navigation surface: the pill bar,
/// the Duo section list, the tabletop deck and the native side tab bar.
class NavigationBloc
    extends BaseViewModelBloc<NavigationEvent, NavigationState> {
  /// Creates the bloc and listens for taps on the native tab bar.
  NavigationBloc({required DuoBridge bridge, int initialIndex = 0})
    : _bridge = bridge,
      super(NavigationState(index: initialIndex.clamp(0, sectionCount - 1))) {
    on<NavigationSectionSelected>(_onSectionSelected);
    bridge.onNativeTabSelected = _onNativeTab;
  }

  /// Number of top-level sections.
  static const sectionCount = 4;

  /// Index of the Contact section.
  static const contactIndex = 3;

  final DuoBridge _bridge;

  void _onNativeTab(int index) => dispatch(NavigationSectionSelected(index));

  void _onSectionSelected(
    NavigationSectionSelected event,
    Emitter<NavigationState> emit,
  ) {
    final index = event.index;
    if (index < 0 || index >= sectionCount || index == state.index) return;
    emit(state.copyWith(index: index));
  }

  @override
  Future<void> close() {
    if (_bridge.onNativeTabSelected == _onNativeTab) {
      _bridge.onNativeTabSelected = null;
    }
    return super.close();
  }
}
