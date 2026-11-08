import 'package:flutter/material.dart';

import 'bible/reader_screen.dart';
import 'common.dart';
import 'home/home_screen.dart';
import 'paths/paths_screen.dart';
import 'progress/progress_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      // IndexedStack : chaque onglet garde sa position (lecture, défilement).
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), PathsScreen(), ReaderScreen(), ProgressScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l.navHome),
          NavigationDestination(icon: const Icon(Icons.route_outlined), selectedIcon: const Icon(Icons.route), label: l.navPaths),
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: l.navBible),
          NavigationDestination(icon: const Icon(Icons.insights_outlined), selectedIcon: const Icon(Icons.insights), label: l.navProgress),
        ],
      ),
    );
  }
}
