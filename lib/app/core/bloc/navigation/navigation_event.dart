import 'package:equatable/equatable.dart';

/// Events handled by `NavigationBloc`.
sealed class NavigationEvent extends Equatable {
  /// Base constructor.
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

/// A section was picked: pill bar, Duo section list, tabletop deck, a CTA,
/// drag-and-drop or the native side tab bar. Out-of-range values and the
/// already selected index are ignored.
final class NavigationSectionSelected extends NavigationEvent {
  /// Creates the event for section [index].
  const NavigationSectionSelected(this.index);

  /// Index into the app's sections: 0 Home, 1 Services, 2 Work, 3 Contact.
  final int index;

  @override
  List<Object?> get props => [index];
}
