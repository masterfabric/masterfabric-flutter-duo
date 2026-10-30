import 'package:flutter/material.dart';
import 'package:hello_flutter/app/widgets/pill_nav_bar.dart';

/// One top-level section of the app (a tab).
class ShellSection {
  /// Creates a section with its nav [item], [subtitle] and SF [symbol].
  const ShellSection(this.item, this.subtitle, this.symbol);

  /// Icon + label used by the Flutter navigation surfaces.
  final PillNavItem item;

  /// One-line description shown in the Duo section list.
  final String subtitle;

  /// SF Symbol name for the native UIKit side tab bar.
  final String symbol;
}

/// Sections in display order: Home, Services, Work, Contact.
const kShellSections = [
  ShellSection(
    PillNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    'Software studio for mobile, web & AI',
    'house',
  ),
  ShellSection(
    PillNavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'Services',
    ),
    'What we design, build and ship',
    'sparkles',
  ),
  ShellSection(
    PillNavItem(
      icon: Icons.workspaces_outline,
      selectedIcon: Icons.workspaces,
      label: 'Work',
    ),
    'Clients, Academy & open source',
    'square.grid.2x2',
  ),
  ShellSection(
    PillNavItem(
      icon: Icons.mail_outline_rounded,
      selectedIcon: Icons.mail_rounded,
      label: 'Contact',
    ),
    'Start a project with us',
    'envelope',
  ),
];
