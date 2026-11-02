import 'dart:io' show Platform;

import 'package:get_it/get_it.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_bloc.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_bloc.dart';
import 'package:hello_flutter/app/helper/layout/duo/duo_bridge.dart';

/// Service locator, as in masterfabric_core's `di/` (GetIt).
final GetIt getIt = GetIt.instance;

/// Registers helpers and view models. Safe to call more than once.
void configureDependencies() {
  if (getIt.isRegistered<DuoBridge>()) return;
  getIt
    ..registerSingleton<DuoBridge>(DuoBridge.instance)
    ..registerFactory<DuoBloc>(() => DuoBloc(bridge: getIt<DuoBridge>()))
    ..registerFactory<NavigationBloc>(
      () => NavigationBloc(
        bridge: getIt<DuoBridge>(),
        initialIndex: initialSectionIndex(),
      ),
    );
}

/// Section to open at launch, for screenshots:
/// `flutter run --dart-define=MF_TAB=2` (or the `MF_TAB` environment variable).
int initialSectionIndex() {
  const defined = String.fromEnvironment('MF_TAB');
  final raw = defined.isNotEmpty ? defined : Platform.environment['MF_TAB'];
  return (int.tryParse(raw ?? '') ?? 0).clamp(
    0,
    NavigationBloc.sectionCount - 1,
  );
}
