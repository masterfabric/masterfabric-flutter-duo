import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_flutter/app/core/bloc/duo/duo_bloc.dart';
import 'package:hello_flutter/app/core/bloc/navigation/navigation_bloc.dart';
import 'package:hello_flutter/app/core/di/injection.dart';
import 'package:hello_flutter/app/theme/app_theme.dart';
import 'package:hello_flutter/app/views/view_shell/shell_view.dart';

/// Root widget: provides the app-wide blocs and the theme.
class MasterFabricApp extends StatelessWidget {
  /// Creates the app. Call [configureDependencies] first.
  const MasterFabricApp({super.key});

  @override
  Widget build(BuildContext context) {
    configureDependencies();
    return MultiBlocProvider(
      providers: [
        BlocProvider<DuoBloc>(create: (_) => getIt<DuoBloc>()),
        BlocProvider<NavigationBloc>(create: (_) => getIt<NavigationBloc>()),
      ],
      child: MaterialApp(
        title: 'MasterFabric',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const ShellView(),
      ),
    );
  }
}
