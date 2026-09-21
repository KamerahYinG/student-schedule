import 'package:flutter/material.dart';

import '../features/deadlines/deadlines_page.dart';
import '../features/inbox/inbox_page.dart';
import '../features/projects/projects_page.dart';
import '../features/settings/settings_page.dart';
import '../features/week/week_page.dart';

enum AppSection { week, deadlines, projects, inbox, settings }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _section = AppSection.week;

  static const _items = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.view_week_outlined), selectedIcon: Icon(Icons.view_week), label: 'Week'),
    NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Deadlines'),
    NavigationDestination(icon: Icon(Icons.account_tree_outlined), selectedIcon: Icon(Icons.account_tree), label: 'Projects'),
    NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Inbox'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
  ];

  static final _phoneItems = <NavigationDestination>[
    _items[0],
    _items[1],
    _items[2],
    _items[3],
  ];

  Widget get _page => switch (_section) {
        AppSection.week => const WeekPage(),
        AppSection.deadlines => const DeadlinesPage(),
        AppSection.projects => const ProjectsPage(),
        AppSection.inbox => const InboxPage(),
        AppSection.settings => const SettingsPage(),
      };

  void _select(int index) => setState(() => _section = AppSection.values[index]);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        return Scaffold(
          appBar: isWide
              ? null
              : AppBar(
                  title: Text(_section.name[0].toUpperCase() + _section.name.substring(1)),
                  actions: [
                    if (_section != AppSection.settings)
                      IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => setState(() => _section = AppSection.settings),
                      ),
                  ],
                ),
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: _section.index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  destinations: _items
                      .map((item) => NavigationRailDestination(
                            icon: item.icon,
                            selectedIcon: item.selectedIcon,
                            label: Text(item.label),
                          ))
                      .toList(),
                ),
              if (isWide) const VerticalDivider(width: 1),
              Expanded(child: _page),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: _section == AppSection.settings ? 0 : _section.index,
                  onDestinationSelected: _select,
                  destinations: _phoneItems,
                ),
        );
      },
    );
  }
}
