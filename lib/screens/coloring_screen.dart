import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ColoringScreen extends StatelessWidget {
  final List<String> coloringImages = [
    'assets/coloring/coloring1.png',
    'assets/coloring/coloring2.png',
    'assets/coloring/coloring3.png',
  ];

  ColoringScreen({super.key});

  Future<void> _shareImageAsPdf(BuildContext context, String imagePath) async {
    try {
      final ByteData bytes = await rootBundle.load(imagePath);
      final Uint8List imageData = bytes.buffer.asUint8List();

      final pdfData = await _wrapImageAsPdf(imageData);

      final outputDir = await getTemporaryDirectory();
      final file = File('${outputDir.path}/coloring.pdf');
      await file.writeAsBytes(pdfData);

      // Використовуємо XFile і shareXFiles
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Розмальовка для друку!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при створенні PDF: $e')),
      );
    }
  }

  Future<Uint8List> _wrapImageAsPdf(Uint8List imageData) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.coloring),
        backgroundColor: Colors.deepPurple,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coloringImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final imagePath = coloringImages[index];
          return GestureDetector(
            onTap: () => _shareImageAsPdf(context, imagePath),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.print, color: Colors.white, size: 28),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
