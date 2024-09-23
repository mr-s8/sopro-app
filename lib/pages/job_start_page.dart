import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taskscout/app_colors.dart';
import 'package:taskscout/classes/job.dart'; // Importiere die Job-Klasse
import 'package:taskscout/data_model.dart';
import 'package:taskscout/pages/button_problem.dart';
import 'package:taskscout/pages/detail_page.dart';
import 'package:taskscout/pages/route_page.dart';
import 'package:taskscout/services/job_start_page_services.dart'; // Importiere JobDetailPage

class JobStartPage extends StatefulWidget {
  final Job job;
  final String thumbnailPath;

  const JobStartPage({
    required this.job,
    required this.thumbnailPath,
    super.key,
  });

  @override
  State<JobStartPage> createState() => _JobStartPageState();
}

class _JobStartPageState extends State<JobStartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.map_outlined,
                size: 40,
              ),
              onPressed: () {
                // Füge hier die Aktion hinzu, z. B. Öffnen der Einstellungen
                print("Settings icon pressed");
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bild mit abgerundeten Ecken
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(16.0), // Abgerundete Ecken
                  child: Image.file(
                    File(widget.thumbnailPath),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Weitere Widgets
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.job.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.buildingAddress,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${widget.job.userStatus}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (widget.job.downloaded &&
                  !(widget.job.userStatus == "to_submit"))
              ? () async {
                  // Hier die Logik für das Annehmen und Starten des Jobs einfügen
                  // Zum Beispiel, JobStatus ändern und zur JobDetailPage navigieren

                  setState(() {
                    widget.job.userStatus = "started";
                  });
                  var instance = DataModel();
                  instance.saveCurrentJobs();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutePage(job: widget.job),
                    ),
                  );
                  setState(() {});
                }
              : widget.job.userStatus == "to_submit"
                  ? () async {
                      // poppen und fehler behandlung fehlen
                      print(widget.job.userStatus);
                      bool successSubmitting =
                          await JobStartPageServices().submitJob(widget.job);
                      if (successSubmitting) {
                        Navigator.pop(context);
                      }
                    }
                  : null, // Button deaktivieren, wenn job.downloaded false ist
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.job.downloaded
                ? AppColors.primaryColor
                : Colors.grey, // Button Hintergrundfarbe
            minimumSize: Size(double.infinity, 64), // Button Größe
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0), // Abgerundete Ecken
            ),
          ),
          child: Text(
            widget.job.userStatus == 'started'
                ? 'Fortsetzen'
                : widget.job.userStatus == 'to_submit'
                    ? 'Abschicken'
                    : 'Auftrag Annehmen und Starten',
            style: TextStyle(
                color: widget.job.downloaded
                    ? Colors.white
                    : Colors.black54, // Button Textfarbe
                fontSize: 20),
          ),
        ),
      ),
    );
  }
}
