import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'screens/about_contact_screen.dart';
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/work_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/mf_logo.dart';
import 'widgets/pill_nav_bar.dart';

void main() => runApp(const MasterFabricApp());

class MasterFabricApp extends StatelessWidget {
  const MasterFabricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MasterFabric',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index = _initialTab();

  /// Allows opening a specific tab at launch (used for screenshots):
  /// `flutter run --dart-define=MF_TAB=2`
  static int _initialTab() {
    const defined = String.fromEnvironment('MF_TAB');
    final raw = defined.isNotEmpty ? defined : Platform.environment['MF_TAB'];
    final value = int.tryParse(raw ?? '') ?? 0;
    return value.clamp(0, 3);
  }

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onNavigate: _goTo),
      const ServicesScreen(),
      const WorkScreen(),
      const AboutContactScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const MfWordmark(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: () => _goTo(3),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text('Contact'),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      extendBody: true,
      bottomNavigationBar: PillNavBar(
        selectedIndex: _index,
        onSelected: _goTo,
        items: const [
          PillNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
          PillNavItem(icon: Icons.auto_awesome_outlined, selectedIcon: Icons.auto_awesome, label: 'Services'),
          PillNavItem(icon: Icons.workspaces_outline, selectedIcon: Icons.workspaces, label: 'Work'),
          PillNavItem(icon: Icons.mail_outline_rounded, selectedIcon: Icons.mail_rounded, label: 'Contact'),
        ],
      ),
    );
  }
}
