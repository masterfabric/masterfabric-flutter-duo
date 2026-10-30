import 'package:hello_flutter/app/core/base/base_view_model_cubit.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_state.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';

/// Owns the selected section for every navigation surface: the pill bar,
/// the Duo section list, the tabletop deck and the native side tab bar.
class NavigationCubit extends BaseViewModelCubit<NavigationState> {
  /// Creates the cubit and listens for taps on the native tab bar.
  NavigationCubit({required DuoBridge bridge, int initialIndex = 0})
    : _bridge = bridge,
      super(NavigationState(index: initialIndex.clamp(0, sectionCount - 1))) {
    bridge.onNativeTabSelected = select;
  }

  /// Number of top-level sections.
  static const sectionCount = 4;

  /// Index of the Contact section.
  static const contactIndex = 3;

  final DuoBridge _bridge;

  /// Selects section [index]; out-of-range values are ignored.
  void select(int index) {
    if (index < 0 || index >= sectionCount || index == state.index) return;
    stateChanger(state.copyWith(index: index));
  }

  @override
  Future<void> close() {
    if (_bridge.onNativeTabSelected == select) {
      _bridge.onNativeTabSelected = null;
    }
    return super.close();
  }
}
