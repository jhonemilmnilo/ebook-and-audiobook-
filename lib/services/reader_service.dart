import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import '../core/theme/app_theme.dart';

class ReaderService {
  final Dio _dio = Dio();

  Future<void> openBook(String url, String title) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$title.epub';

      if (!File(filePath).existsSync()) {
        // Download if not exists
        await _dio.download(url, filePath);
      }

      // Configure Viewer
      VocsyEpub.setConfig(
        themeColor: AppTheme.primary,
        identifier: 'iosBook',
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: true,
      );

      // Open Viewer
      VocsyEpub.open(
        filePath,
        lastLocation: null, // TODO: Save location in SQLite
      );
    } catch (e) {
      print('Error opening book: $e');
    }
  }
}
