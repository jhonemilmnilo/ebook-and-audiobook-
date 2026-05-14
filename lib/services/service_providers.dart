import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/book_service.dart';
import '../services/audio_service.dart';

final bookServiceProvider = Provider<BookService>((ref) => BookService());
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final topEbooksProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(bookServiceProvider).getTopEbooks();
});

final topAudiobooksProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(audioServiceProvider).getTopAudiobooks();
});
