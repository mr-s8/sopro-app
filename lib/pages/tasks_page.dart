import 'dart:io'; // Für File-Zugriff
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:taskscout/components/my_taskfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Für JSON-Parsing
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskscout/data_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskscout/pages/job_start_page.dart';

import 'detail_page.dart'; // Für getApplicationDocumentsDirectory

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> _getThumbnailPath(
      String buildingId, String buildingImage) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = Directory('${directory.path}/$buildingId');
    final filePath = '${folderPath.path}/$buildingImage';
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    final dataModel = Provider.of<DataModel>(context);
    final jobs = dataModel.tasks;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: RefreshIndicator(
          onRefresh: () async {
            await dataModel.refreshList();
          },
          child: ListView.builder(
            itemCount: jobs?.length ?? 0,
            itemBuilder: (context, index) {
              final job = jobs?[index];
              if (job == null) {
                return const SizedBox
                    .shrink(); // oder eine andere Platzhalter-Widget
              }

              final buildingId = job.buildingId; // Zugriff auf die Eigenschaft
              final buildingImage =
                  job.buildingImage; // Zugriff auf die Eigenschaft

              return FutureBuilder<String>(
                future: _getThumbnailPath(buildingId,
                    buildingImage), // Thumbnails aus Dateisystem laden
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Ladeanzeige während des Ladens
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text(
                        'Fehler beim Laden des Thumbnails'); // Fehleranzeige
                  }

                  final thumbnailPath = snapshot.data!;

                  return Container(
                    child: InkWell(
                      child: TaskField(
                        job: job, // Zugriff auf den Namen des Jobs

                        thumbnailPath: thumbnailPath,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobStartPage(
                              job: job,
                              thumbnailPath: thumbnailPath,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}


/**
 * 
 * wie soll ich das jetzt machen. beim ersten laden aus localstorage oder direkt request?
 * und was bei kein internt? dann am besten erstmal aus local storage und dann refresh
 * oder beim start der app einmal und in local storage speichern.
 * 
 * trotzdem anschauen wie das geht mit nur beim ersten mal laden
 * 
 * 
 * plan: pageview (mit navbar?? ; erstmal global observer); dann localstorage; dann provider oder so; dann logout variablen unchecken fall nötig;
 * dann download von bilder
 * 
 * 
 * beim starten post request dann in local storage. das dann an den provider; bei refresh in local storage und dann in dem provider
 * beim starten versuche zu getten ansonsten localstorage
 * 
 * userid und roles werden erst in local storage gespeichert und der provider holt sich die ggf hoch, oder warte...
 * 
 * 
 * 
 * problem: wo userID in den provider packen
 * 
 * //print(Provider.of<DataModel>(context).userId);
 * 
 * 
 * 
 * verstehen was ein consumer macht.
 * 
 * beim login soll er noch nix mit provider machen
 * beim init aufruf der homepage soll er einmal alle variablen aus dem localstorage in den provider holen (bzw einmal _refreshlist 
 * aus dem provider aufrufen, damit beim start einmal alles neu ist.)
 * dann soll er nur noch bei refresh die funktion aufrufen und hoffentlich wird dann der state refreshed...
 * 
 * ----------
 * 
 * so geht weiter:
 * 
 * nach dem refresh ordner mit building id machen und die bilder ziehen und in local storage packen
 * 
 * 
 * in der datenbank sollen die namen mit endungen gespeichert werden.
 *
 *
 * plan: so ändern dass die ganzen dateinamen in der datenabnk gespeichert werden oder zumindest von dem thumbnail
 * dann dass die bilder auch wirklich angezeigt werden als thumbnail
 * dann download ermöglichen
 *
 *
 *
 * doch eher alles unter aufträgen speichern, weil was wenn sich was ändert bei gebäuden und man einen auftrag nicht beendet,
 * dann bleiben alte bilder erhalten
 *
 * bilder cachen und nicht aus dem datesystem laden
 *
 * mehrere downloads gleichzeitig
 *
 *
 * download status speichern.
 *
 * warum future builder?
 */