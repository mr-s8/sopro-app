import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:taskscout/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:taskscout/classes/job.dart';
import 'package:taskscout/config.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:taskscout/services/data_model_services.dart';

import '../data_model.dart';

class TaskField extends StatefulWidget {
  Job job;
  String thumbnailPath;

  TaskField({
    super.key,
    required this.job,
    required this.thumbnailPath,
  });

  @override
  State<TaskField> createState() => _TaskFieldState();
}

class _TaskFieldState extends State<TaskField> {
  bool _isDownloading = false;

  void _downloadImages(BuildContext context, Job job) async {
    print("download Images");
    _isDownloading = true;
    DataModelService dataService = DataModelService();
    print(job.downloaded);
    await dataService.downloadAllImages(job);
    print(job.downloaded);
    setState(() {
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0.0, 10.0),
            blurRadius: 10.0,
            spreadRadius: -6.0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail-Bild links
          Container(
            width: 100, // Größe des Bildes am linken Rand
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              image: DecorationImage(
                image: File(widget.thumbnailPath)
                        .existsSync() // Prüfen, ob die Datei existiert
                    ? FileImage(File(widget
                        .thumbnailPath)) // Lade das Bild aus dem Dateisystem
                    : AssetImage('lib/assets/background_image.jpg')
                        as ImageProvider, // Fallback-Bild oder Platzhalter
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10), // Abstand zwischen Bild und Text

          // Name und Beschreibung
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name des Tasks
                Text(
                  widget.job.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                // Beschreibung des TasksbuildingAddress
                Text(
                  widget.job.buildingAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          // Download-Icon rechts
          IconButton(
            icon: widget.job.downloaded
                ? const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 40,
                  ) // Häkchen nach erfolgreichem Download
                : _isDownloading
                    ? const CircularProgressIndicator() // Ladeanzeige während des Downloads
                    : const Icon(
                        Icons.download_for_offline_outlined,
                        color: AppColors.primaryColor,
                        size: 40,
                      ), // Download-Symbol
            onPressed: _isDownloading || widget.job.downloaded
                ? null // Deaktiviert das Icon während des Downloads oder wenn abgeschlossen
                : () {
                    _downloadImages(context, widget.job);
                  },
          ),
          const SizedBox(width: 20), // Abstand zum rechten Rand
        ],
      ),
    );
  }
}
