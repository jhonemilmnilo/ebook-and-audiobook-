import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/chatbot/presentation/chatbot_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoritesScreen(),
    const ChatbotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: AppTheme.surface.withOpacity(0.7),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppTheme.primary,
                unselectedItemColor: AppTheme.textSecondary,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedFontSize: 0,
                unselectedFontSize: 0,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(LucideIcons.home),
                    activeIcon: Icon(LucideIcons.home, color: AppTheme.primary),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(LucideIcons.heart),
                    activeIcon: Icon(LucideIcons.heart, color: AppTheme.primary),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(LucideIcons.messageSquare),
                    activeIcon: Icon(LucideIcons.messageSquare, color: AppTheme.primary),
                    label: 'AI Chat',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
