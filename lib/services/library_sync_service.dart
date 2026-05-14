import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_provider.dart';
import '../core/database/app_database.dart';
import 'service_providers.dart';
import 'package:drift/drift.dart';

final librarySyncServiceProvider = Provider<LibrarySyncService>((ref) {
  return LibrarySyncService(ref);
});

class LibrarySyncService {
  final Ref ref;
  final Dio _dio = Dio(BaseOptions(
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  bool _isSyncing = false;

  LibrarySyncService(this.ref);

  Future<void> syncLibrary() async {
    if (_isSyncing) return;
    _isSyncing = true;
    print('DEBUG: Starting Library Sync (Dual-Source Aggregator)... 🚀');

    final db = ref.read(databaseProvider);
    final directory = await getApplicationDocumentsDirectory();

    // 1. Fetch from Gutendex
    try {
      print('DEBUG: Fetching from Gutendex...');
      final gutendexBooks = await ref.read(bookServiceProvider).getTopEbooks();
      // Sync only top 5 from Gutendex to save time/bandwidth initially
      for (var book in gutendexBooks.take(5)) {
        final bookId = 'gutendex_${book['id']}';
        final epubUrl = book['formats']['application/epub+zip'];
        final title = book['title'] ?? 'Unknown Title';
        final author = (book['authors'] as List?)?.isNotEmpty == true ? book['authors'][0]['name'] : 'Unknown Author';
        final coverUrl = book['formats']['image/jpeg'] ?? '';

        await _processBook(db, directory, bookId, title, author, coverUrl, epubUrl, 'gutendex');
      }
    } catch (e) {
      print('DEBUG ERROR: Gutendex Sync failed: $e');
    }

    // 2. Fetch from Open Library
    try {
      print('DEBUG: Fetching from Open Library...');
      final openLibraryService = ref.read(openLibraryServiceProvider);
      // We search for books that have fulltext available
      final olBooks = await openLibraryService.searchBooks('classic');
      
      for (var book in olBooks.take(5)) {
        final bookId = 'ol_${book['key']}';
        final title = book['title'] ?? 'Unknown Title';
        final author = (book['author_name'] as List?)?.isNotEmpty == true ? book['author_name'][0] : 'Unknown Author';
        final coverUrl = openLibraryService.getCoverUrl(book['cover_i']);
        final epubUrl = openLibraryService.getIaEpubUrl(book['ia']);

        await _processBook(db, directory, bookId, title, author, coverUrl, epubUrl, 'open_library');
      }
    } catch (e) {
      print('DEBUG ERROR: Open Library Sync failed: $e');
    }

    print('DEBUG: Library Sync Complete! ✅');
    _isSyncing = false;
  }

  Future<void> _processBook(
    AppDatabase db,
    Directory directory,
    String bookId,
    String title,
    String author,
    String coverUrl,
    String? epubUrl,
    String source,
  ) async {
    if (epubUrl == null) return;

    // Check if already saved
    final existing = await db.getLocalBookById(bookId);
    if (existing != null) return; // Already downloaded

    final safeTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filePath = '${directory.path}/$safeTitle.epub';
    final file = File(filePath);

    try {
      if (!file.existsSync() || file.lengthSync() == 0) {
        print('DEBUG: Downloading $title from $source... ⏳');
        await _dio.download(epubUrl, filePath);
        
        if (file.lengthSync() > 0) {
          // Success! Save to database
          await db.addLocalBook(LocalBooksCompanion(
            bookId: Value(bookId),
            title: Value(title),
            author: Value(author),
            coverUrl: Value(coverUrl),
            localPath: Value(filePath),
            source: Value(source),
          ));
          print('DEBUG: Saved $title to local database. ✅');
        } else {
           file.deleteSync();
        }
      }
    } catch (e) {
      print('DEBUG ERROR: Failed to download $title: $e');
      if (file.existsSync()) {
        try { file.deleteSync(); } catch (_) {}
      }
    }
  }
}
