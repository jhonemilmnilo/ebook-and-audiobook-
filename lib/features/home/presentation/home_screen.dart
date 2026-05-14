import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/book_card.dart';
import '../../../services/service_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebooksAsync = ref.watch(topEbooksProvider);
    final audiobooksAsync = ref.watch(topAudiobooksProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Good Morning, Pare!',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What are we reading today?',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              _buildSearchBar(),
              const SizedBox(height: 40),
              _buildSectionHeader('Top Ebooks'),
              const SizedBox(height: 16),
              ebooksAsync.when(
                data: (books) {
                  print('DEBUG: HomeScreen received ${books.length} ebooks. Rendering now... 🎨');
                  return _buildBookList(context, ref, books, isAudio: false);
                },
                loading: () {
                  print('DEBUG: Ebooks are still loading... ⏳');
                  return const Center(child: CircularProgressIndicator());
                },
                error: (err, stack) {
                  print('DEBUG ERROR: Failed to load ebooks: $err ❌');
                  return Text('Error: $err');
                },
              ),
              const SizedBox(height: 40),
              _buildSectionHeader('Top Audiobooks'),
              const SizedBox(height: 16),
              audiobooksAsync.when(
                data: (books) {
                  print('DEBUG: HomeScreen received ${books.length} audiobooks. Rendering now... 🎧');
                  return _buildAudioList(context, ref, books);
                },
                loading: () {
                  print('DEBUG: Audiobooks are still loading... ⏳');
                  return const Center(child: CircularProgressIndicator());
                },
                error: (err, stack) {
                  print('DEBUG ERROR: Failed to load audiobooks: $err ❌');
                  return Text('Error: $err');
                },
              ),
              const SizedBox(height: 120), // Padding for BottomNav
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
    final olService = ref.watch(openLibraryServiceProvider);
    
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final author = (book['author_name'] as List?)?.first ?? 'Unknown Author';
          final coverUrl = olService.getCoverUrl(book['cover_i']);
          
          return BookCard(
            title: book['title'] ?? 'No Title',
            author: author,
            coverUrl: coverUrl,
            isAudio: isAudio,
            onTap: () {
              // Open Library doesn't provide EPUB directly, so we search Gutendex for a readable version
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Finding a readable version for you, pare... ⏳')),
              );
              
              ref.read(bookServiceProvider).searchEbooks(book['title'] ?? '').then((gutendexResults) {
                if (gutendexResults.isNotEmpty) {
                  final epubUrl = gutendexResults[0]['formats']['application/epub+zip'];
                  if (epubUrl != null) {
                    ref.read(readerServiceProvider).openBook(epubUrl, book['title'] ?? 'book');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sorry pare, no EPUB found on Gutendex fallback.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorry pare, could not find this book on Gutendex.')),
                  );
                }
              });
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
