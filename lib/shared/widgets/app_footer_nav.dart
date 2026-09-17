import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppFooterDestination { home, favorites, search, settings, history }

class AppFooterNav extends StatelessWidget {
  const AppFooterNav({super.key, this.current});
  final AppFooterDestination? current;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: current == AppFooterDestination.favorites ? 4 : 0,
    onDestinationSelected: (index) => context.go(
      ['/', '/bible', '/psalms', '/discover', '/favorites'][index],
    ),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
      NavigationDestination(
        icon: Icon(Icons.menu_book_rounded),
        label: 'Bíblia',
      ),
      NavigationDestination(
        icon: Icon(Icons.wb_sunny_outlined),
        label: 'Salmos',
      ),
      NavigationDestination(
        icon: Icon(Icons.shuffle_rounded),
        label: 'Trechos',
      ),
      NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Salvos'),
    ],
  );
}
