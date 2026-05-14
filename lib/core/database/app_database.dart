import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text()(); // API ID
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get coverUrl => text()();
  TextColumn get type => text()(); // 'ebook' or 'audiobook'
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
}

class LocalBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get coverUrl => text()();
  TextColumn get localPath => text()();
  TextColumn get source => text()(); // 'open_library' or 'gutendex'
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
}

@DriftDatabase(tables: [Favorites, LocalBooks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            await m.createTable(localBooks);
          }
        },
      );

  // Favorites Queries
  Future<List<Favorite>> getAllFavorites() => select(favorites).get();
  Future<int> addFavorite(FavoritesCompanion entry) => into(favorites).insert(entry);
  Future<int> removeFavorite(String bookId) => 
      (delete(favorites)..where((t) => t.bookId.equals(bookId))).go();
  Stream<bool> isFavorite(String bookId) => 
      (select(favorites)..where((t) => t.bookId.equals(bookId)))
      .watch()
      .map((event) => event.isNotEmpty);

  // LocalBooks Queries
  Future<List<LocalBook>> getAllLocalBooks() => select(localBooks).get();
  Stream<List<LocalBook>> watchLocalBooks() => select(localBooks).watch();
  Future<int> addLocalBook(LocalBooksCompanion entry) => into(localBooks).insert(entry);
  Future<LocalBook?> getLocalBookById(String bookId) => 
      (select(localBooks)..where((t) => t.bookId.equals(bookId))).getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
