import 'package:dio/dio.dart';

class OpenLibraryService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://openlibrary.org'));

  Future<List<dynamic>> searchBooks(String query) async {
    try {
      final response = await _dio.get('/search.json', queryParameters: {
        'q': query,
        'limit': 20,
      });
      if (response.statusCode == 200) {
        return response.data['docs'];
      }
      return [];
    } catch (e) {
      print('DEBUG ERROR: Open Library search failed: $e');
      return [];
    }
  }

  // Helper to get cover URL
  String getCoverUrl(int? coverId) {
    if (coverId == null) return '';
    return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
  }

  // Helper to get Internet Archive EPUB URL
  String? getIaEpubUrl(List<dynamic>? iaIds) {
    if (iaIds != null && iaIds.isNotEmpty) {
      final id = iaIds.first;
      return 'https://archive.org/download/$id/$id.epub';
    }
    return null;
  }
}
