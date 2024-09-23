// Vollbild-Ansicht für das Bild
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageFullScreen extends StatelessWidget {
  final String imagePath;
  final String buildingId;

  const ImageFullScreen({
    Key? key,
    required this.imagePath,
    required this.buildingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<String>(
        future: getPathForRouteImage(imagePath, buildingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Fehler beim Laden des Bildes',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final filePath = snapshot.data!;
          return GestureDetector(
            onTap: () {
              Navigator.pop(context); // Zurück zur vorherigen Seite
            },
            child: Center(
              child: Image.file(
                File(filePath),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String> getPathForRouteImage(
      String routeImage, String buildingId) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$buildingId/$routeImage';
    return filePath;
  }
}
