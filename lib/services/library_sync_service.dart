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
    print('DEBUG: Starting Persistent Library Sync Engine... 🚀');

    final db = ref.read(databaseProvider);
    final directory = await getApplicationDocumentsDirectory();

    int downloadedThisSession = 0;
    const int sessionLimit = 60; // Increased to ensure plenty of books

    // 1. Gutendex Continuous Sync (Paginated)
    int gutendexPage = 1;
    while (downloadedThisSession < sessionLimit && gutendexPage <= 5) {
      try {
        print('DEBUG: Syncing Gutendex Page $gutendexPage...');
        final response = await _dio.get('https://gutendex.com/books', queryParameters: {'page': gutendexPage});
        final List gutendexBooks = response.data['results'];
        
        for (var book in gutendexBooks) {
          if (downloadedThisSession >= sessionLimit) break;

          final bookId = 'gutendex_${book['id']}';
          final epubUrl = book['formats']['application/epub+zip'];
          if (epubUrl == null) continue;

          final title = book['title'] ?? 'Unknown Title';
          final author = (book['authors'] as List?)?.isNotEmpty == true ? book['authors'][0]['name'] : 'Unknown Author';
          final coverUrl = book['formats']['image/jpeg'] ?? '';

          final success = await _processBook(db, directory, bookId, title, author, coverUrl, epubUrl, 'gutendex');
          if (success) downloadedThisSession++;
          
          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        }
        gutendexPage++;
      } catch (e) {
        print('DEBUG ERROR: Gutendex Sync failed at page $gutendexPage: $e');
        break;
      }
    }

    // 2. Open Library Continuous Sync (Paginated)
    int olPage = 1;
    while (downloadedThisSession < sessionLimit && olPage <= 3) {
      try {
        print('DEBUG: Syncing Open Library Page $olPage...');
        final response = await _dio.get('https://openlibrary.org/search.json', queryParameters: {
          'q': 'classic',
          'has_fulltext': 'true',
          'page': olPage,
          'limit': 20,
        });
        final List olBooks = response.data['docs'];
        final olService = ref.read(openLibraryServiceProvider);
        
        for (var book in olBooks) {
          if (downloadedThisSession >= sessionLimit) break;

          final bookId = 'ol_${book['key']}';
          final title = book['title'] ?? 'Unknown Title';
          final author = (book['author_name'] as List?)?.isNotEmpty == true ? book['author_name'][0] : 'Unknown Author';
          final coverUrl = olService.getCoverUrl(book['cover_i']);
          final epubUrl = olService.getIaEpubUrl(book['ia']);

          if (epubUrl == null) continue;

          final success = await _processBook(db, directory, bookId, title, author, coverUrl, epubUrl, 'open_library');
          if (success) downloadedThisSession++;

          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        }
        olPage++;
      } catch (e) {
        print('DEBUG ERROR: Open Library Sync failed at page $olPage: $e');
        break;
      }
    }

    print('DEBUG: Session Sync Complete! Downloaded $downloadedThisSession new books. ✅');
    _isSyncing = false;
  }

  Future<bool> _processBook(
    AppDatabase db,
    Directory directory,
    String bookId,
    String title,
    String author,
    String coverUrl,
    String? epubUrl,
    String source,
  ) async {
    if (epubUrl == null) return false;

    // Check if already saved
    final existing = await db.getLocalBookById(bookId);
    if (existing != null) return false; // Already downloaded

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
          return true;
        } else {
           file.deleteSync();
           return false;
        }
      }
      return false;
    } catch (e) {
      print('DEBUG ERROR: Failed to download $title: $e');
      if (file.existsSync()) {
        try { file.deleteSync(); } catch (_) {}
      }
      return false;
    }
  }
}
