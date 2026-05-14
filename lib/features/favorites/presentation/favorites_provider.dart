import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Favorite>>((ref) {
  final db = ref.watch(databaseProvider);
  return FavoritesNotifier(db);
});

class FavoritesNotifier extends StateNotifier<List<Favorite>> {
  final AppDatabase _db;

  FavoritesNotifier(this._db) : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    state = await _db.getAllFavorites();
  }

  Future<void> toggleFavorite({
    required String bookId,
    required String title,
    required String author,
    required String coverUrl,
    required String type,
  }) async {
    final isFav = state.any((element) => element.bookId == bookId);

    if (isFav) {
      await _db.removeFavorite(bookId);
    } else {
      await _db.addFavorite(FavoritesCompanion.insert(
        bookId: bookId,
        title: title,
        author: author,
        coverUrl: coverUrl,
        type: type,
      ));
    }
    await _loadFavorites();
  }
}
