import 'package:dio/dio.dart';

class BookService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://gutendex.com'));

  Future<List<dynamic>> getTopEbooks() async {
    try {
      final response = await _dio.get('/books');
      if (response.statusCode == 200) {
        return response.data['results'];
      }
      return [];
    } catch (e) {
      print('Error fetching ebooks: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchEbooks(String query) async {
    try {
      final response = await _dio.get('/books', queryParameters: {'search': query});
      if (response.statusCode == 200) {
        return response.data['results'];
      }
      return [];
    } catch (e) {
      print('Error searching ebooks: $e');
      return [];
    }
  }
}
