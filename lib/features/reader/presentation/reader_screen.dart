import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderScreen extends StatelessWidget {
  final EpubController controller;
  final String title;

  const ReaderScreen({
    super.key,
    required this.controller,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showTableOfContents(context),
          ),
        ],
      ),
      body: EpubView(
        controller: controller,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(
            textStyle: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _showTableOfContents(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => EpubViewTableOfContents(
        controller: controller,
      ),
    );
  }
}
