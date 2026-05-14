import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:epub_view/epub_view.dart';
import '../features/reader/presentation/reader_screen.dart';
import '../core/theme/app_theme.dart';

class ReaderService {
  Future<void> openBook(BuildContext context, String localPath, String title) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );

    try {
      final file = File(localPath);

      if (!file.existsSync() || file.lengthSync() == 0) {
        throw Exception('File not found or corrupted');
      }

      // Initialize the EpubController
      final epubController = EpubController(
        document: EpubDocument.openFile(file),
      );

      // Pop the loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

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
      // Pop the loading dialog if it's still showing
      if (context.mounted) {
        Navigator.pop(context);
      }

      print('Error opening local book: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open book: $e')),
        );
      }
    }
  }
}
