import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:epub_view/epub_view.dart';
import '../features/reader/presentation/reader_screen.dart';

class ReaderService {
  Future<void> openBook(BuildContext context, String localPath, String title) async {
    try {
      final file = File(localPath);

      if (!file.existsSync() || file.lengthSync() == 0) {
        throw Exception('File does not exist or is corrupted');
      }

      // Initialize the EpubController
      final epubController = EpubController(
        document: EpubDocument.openFile(file),
      );

      // Navigate to the Reader Screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderScreen(
              controller: epubController,
              title: title,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error opening local book: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening book: $e')),
        );
      }
    }
  }
}
