import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/book_card.dart';
import 'favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Library',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All your favorites in one place, pare.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: favorites.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final fav = favorites[index];
                          return BookCard(
                            title: fav.title,
                            author: fav.author,
                            coverUrl: fav.coverUrl,
                            isAudio: fav.type == 'audiobook',
                            onTap: () {
                              // TODO: Navigate to reader/player
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Walang laman, pare!',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go back and add some books to your library.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
