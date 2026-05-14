import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/book_service.dart';
import '../services/audio_service.dart';
import '../services/reader_service.dart';
import '../services/open_library_service.dart';
import '../core/database/database_provider.dart';

final bookServiceProvider = Provider<BookService>((ref) => BookService());
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
final readerServiceProvider = Provider<ReaderService>((ref) => ReaderService());
final openLibraryServiceProvider = Provider<OpenLibraryService>((ref) => OpenLibraryService());

// Discovery: Now reading purely from the local SQLite database (Offline-First)
final localBooksProvider = StreamProvider<List<dynamic>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchLocalBooks();
});

final topAudiobooksProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(audioServiceProvider).getTopAudiobooks();
});
