import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for every view model in the app.
///
/// Mirrors `BaseViewModelCubit` from
/// [masterfabric_core](https://github.com/masterfabric-mobile/masterfabric_core):
/// view models extend it and change state through [stateChanger] only.
abstract class BaseViewModelCubit<S> extends Cubit<S> {
  /// Creates the view model with its [initialState].
  BaseViewModelCubit(super.initialState);

  /// Emits [next] unless the cubit is already closed.
  void stateChanger(S next) {
    if (isClosed) return;
    emit(next);
  }
}
