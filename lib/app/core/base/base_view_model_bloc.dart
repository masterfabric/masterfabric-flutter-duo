import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for every view model in the app.
///
/// The Bloc counterpart of `BaseViewModelCubit` from
/// [masterfabric_core](https://github.com/masterfabric-mobile/masterfabric_core):
/// view models extend it, receive events of type [E] and change state only
/// inside their `on<Event>` handlers.
abstract class BaseViewModelBloc<E, S> extends Bloc<E, S> {
  /// Creates the view model with its [initialState].
  BaseViewModelBloc(super.initialState);

  /// Adds [event] unless the bloc is already closed. Use it for events that
  /// come from outside the widget tree (platform channels, listeners), which
  /// may fire after the bloc has been closed.
  void dispatch(E event) {
    if (isClosed) return;
    add(event);
  }
}
