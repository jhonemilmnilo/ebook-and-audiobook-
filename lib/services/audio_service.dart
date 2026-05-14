import 'package:dio/dio.dart';

class AudioService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://librivox.org/api/feed'));

  Future<List<dynamic>> getTopAudiobooks() async {
    try {
      print('DEBUG: Starting LibriVox fetch... 🎧');
      final response = await _dio.get('/audiobooks', queryParameters: {
        'format': 'json',
        'limit': 20,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        // LibriVox uses 'books' as the key for its results!
        final results = response.data['books'];
        if (results is List) {
          print('DEBUG: Successfully fetched ${results.length} audiobooks from LibriVox 🎧');
          return results;
        }
      }
      print('DEBUG: No audiobooks found in response or invalid format.');
      return [];
    } catch (e) {
      print('Error fetching audiobooks: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchAudiobooks(String query) async {
    try {
      final response = await _dio.get('/audiobooks', queryParameters: {
        'format': 'json',
        'title': '^$query', // Basic search
      });
      if (response.statusCode == 200) {
        return response.data['audiobooks'];
      }
      return [];
    } catch (e) {
      print('Error searching audiobooks: $e');
      return [];
    }
  }
}
