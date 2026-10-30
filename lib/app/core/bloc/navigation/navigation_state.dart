import 'package:equatable/equatable.dart';

/// Which top-level section (tab) is showing.
final class NavigationState extends Equatable {
  /// Creates a state with the selected section [index].
  const NavigationState({this.index = 0});

  /// Index into the app's sections: 0 Home, 1 Services, 2 Work, 3 Contact.
  final int index;

  /// Returns a copy with [index] replaced.
  NavigationState copyWith({int? index}) =>
      NavigationState(index: index ?? this.index);

  @override
  List<Object?> get props => [index];
}
