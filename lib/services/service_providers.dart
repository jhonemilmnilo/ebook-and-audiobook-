import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/book_service.dart';
import '../services/audio_service.dart';
import '../services/reader_service.dart';
import '../services/open_library_service.dart';

final bookServiceProvider = Provider<BookService>((ref) => BookService());
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
final readerServiceProvider = Provider<ReaderService>((ref) => ReaderService());
final openLibraryServiceProvider = Provider<OpenLibraryService>((ref) => OpenLibraryService());

// Discovery: Now using Open Library for a better "Top Pick" list
final topEbooksProvider = FutureProvider<List<dynamic>>((ref) {
  // We'll search for popular classic books to fill the Home Screen
  return ref.watch(openLibraryServiceProvider).searchBooks('classic');
});

final topAudiobooksProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(audioServiceProvider).getTopAudiobooks();
});
