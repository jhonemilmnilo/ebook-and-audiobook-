import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/book_card.dart';
import '../../../services/service_providers.dart';
import '../../../services/library_sync_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localBooksAsync = ref.watch(localBooksProvider);
    final audiobooksAsync = ref.watch(topAudiobooksProvider);

    // Auto-sync on startup if library is empty
    ref.listen(localBooksProvider, (previous, next) {
      if (next.hasValue && next.value!.isEmpty) {
        ref.read(librarySyncServiceProvider).syncLibrary();
      }
    });

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What are we reading?',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSearchBar(),
              const SizedBox(height: 40),
              _buildSectionHeader('Top Ebooks'),
              const SizedBox(height: 16),
              localBooksAsync.when(
                data: (books) {
                  if (books.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 24),
                          Text(
                            'Initializing your library...',
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Downloading the best classics for you',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildBookList(context, ref, books, isAudio: false);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading library: $err'),
              ),
              const SizedBox(height: 40),
              _buildSectionHeader('Top Audiobooks'),
              const SizedBox(height: 16),
              audiobooksAsync.when(
                data: (books) {
                  return _buildAudioList(context, ref, books);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
      ),
      child: TextField(
        style: GoogleFonts.inter(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          icon: const Icon(LucideIcons.search, color: AppTheme.textSecondary),
          hintText: 'Search for books or authors...',
          hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'See All',
            style: GoogleFonts.inter(color: AppTheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBookList(BuildContext context, WidgetRef ref, List<dynamic> books, {required bool isAudio}) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index]; // This is now a LocalBook object from Drift
          
          return BookCard(
            title: book.title,
            author: book.author,
            coverUrl: book.coverUrl,
            isAudio: isAudio,
            onTap: () {
              // Now we just pass the local path to the ReaderService! It's guaranteed to work.
              ref.read(readerServiceProvider).openBook(context, book.localPath, book.title);
            },
          );
        },
      ),
    );
  }

  Widget _buildAudioList(BuildContext context, WidgetRef ref, List<dynamic> books) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          
          return BookCard(
            title: book['title'] ?? 'No Title',
            author: book['authors'] != null && (book['authors'] as List).isNotEmpty
                ? book['authors'][0]['last_name']
                : 'Unknown Author',
            coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=160&auto=format&fit=crop', // Placeholder for audio
            isAudio: true,
            onTap: () {
              // TODO: Navigate to Player
            },
          );
        },
      ),
    );
  }
}
