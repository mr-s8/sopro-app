// data_model_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:collection/collection.dart';

import '../config.dart';
import '../classes/user.dart';
import '../classes/job.dart';
import '../data_model.dart';

class DataModelService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<List<Job>> refreshJobs(User user) async {
    // API-Aufruf und Jobs-Handling auslagern
    String? username = await secureStorage.read(key: 'username');
    String? password = await secureStorage.read(key: 'password');

    final response = await http
        .post(
          Uri.parse(
              'http://${Config.backendIp}:${Config.backendPort}/api/jobs'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'userId': user.id,
          }),
        )
        .timeout(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final jobsJson = data["jobs"];
        final newJobs =
            (data['jobs'] as List).map((job) => Job.fromJson(job)).toList();
        await _getThumbnails(newJobs);

        var dataModel = DataModel();
        List<Job> currJobs = dataModel.tasks;

        List<Job> resJobs = keepUserData(newJobs, currJobs);

        await saveJobsToLocalStorage(
            resJobs); // vlt trotzdem schöner ein Jobs objekt zu nehmen wegen wieder verwendung?
        return resJobs;
      }
    }
    return pullJobsFromLocalStorage(); // Bei Fehler von LocalStorage lesen
  }

  Future<void> _getThumbnails(List<Job> jobs) async {
    String? username = await secureStorage.read(key: 'username');
    String? password = await secureStorage.read(key: 'password');

    // Iteriere durch jeden Job in der Liste
    for (var job in jobs) {
      // Hole die buildingID für den aktuellen Job
      final buildingId = job.buildingId;
      final buildingImage = job.buildingImage;
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = Directory('${directory.path}/$buildingId');

      // Überprüfe, ob das Verzeichnis bereits existiert
      if (!await folderPath.exists()) {
        // Erstelle das Verzeichnis, wenn es nicht existiert
        await folderPath.create(recursive: true);
        print('Verzeichnis erstellt: ${folderPath.path}');
      } else {
        print('Verzeichnis existiert bereits: ${folderPath.path}');
      }
      final filePath = '${folderPath.path}/${buildingImage}';

      final file = File(filePath);

      if (await file.exists()) {
        print('Datei existiert bereits. Kein Download erforderlich.');
        continue;
      }

      // URL deines Backend-Servers
      final url = Uri.parse(
          'http://${Config.backendIp}:${Config.backendPort}/api/thumbnail');

      // Erstelle den POST-Request mit den Authentifizierungsdaten
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'buildingId': buildingId,
        }),
      );

      if (response.statusCode == 200) {
        // Erfolgreiche Antwort mit der Bilddatei
        final bytes = response.bodyBytes;

        // Lade das Verzeichnis, in dem die Datei gespeichert werden soll

        // Schreibe die empfangene Datei ins Dateisystem

        await file.writeAsBytes(bytes);

        print('Bild erfolgreich heruntergeladen und gespeichert: $filePath');
      } else if (response.statusCode == 404) {
        print('Bild nicht gefunden');
      } else if (response.statusCode == 401) {
        print('Authentifizierung fehlgeschlagen');
      } else {
        print('Fehler: ${response.statusCode}');
      }
    }
    print(jobs);
    print("get thumbnails done");
  }

  Future<void> saveJobsToLocalStorage(List<Job> jobs) async {
    final jobsJson = jobs.map((e) => Job.toJson(e)).toList();
    final prefs = await SharedPreferences.getInstance();
    final String jobData = jsonEncode(jobsJson);
    print("saving");
    print(jobData);
    await prefs.setString('jobs', jobData);
  }

  Future<List<Job>> pullJobsFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String jobsData = prefs.getString('jobs') ?? '[]';
    final List<dynamic> jobsJson = jsonDecode(jobsData);
    return jobsJson.map((jobJson) => Job.fromJson(jobJson)).toList();
  }

  Future<List<Job>> pullDoneJobsFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String doneJobsString = prefs.getString('doneJobs') ?? '[]';
    final List<dynamic> doneJobsJson = jsonDecode(doneJobsString);
    return doneJobsJson.map((e) => Job.fromJson(e)).toList();
  }

  Future<void> downloadAllImages(Job job) async {
    final secureStorage = const FlutterSecureStorage();
    String? username = await secureStorage.read(key: 'username');
    String? password = await secureStorage.read(key: 'password');

    final routeList = job.route;
    final buildingId = job.buildingId;

    for (var route in routeList) {
      final routeId = route.id;
      final routeImage = route.routeImage;

      final directory = await getApplicationDocumentsDirectory();
      final folderPath = Directory('${directory.path}/$buildingId');
      final filePath = '${folderPath.path}/$routeImage';

      final file = File(filePath);
      if (!await file.exists()) {
        final url = Uri.parse(
            'http://${Config.backendIp}:${Config.backendPort}/api/routeImage'); // Ersetze dies mit der tatsächlichen URL
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'jobId': job.id,
            'routeId': routeId,
          }),
        );

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          await file.writeAsBytes(bytes);
          job.downloaded = true;
          print(
              'Routen-Bild erfolgreich heruntergeladen und gespeichert: $filePath');
        } else {
          print(
              'Fehler beim Herunterladen des Routen-Bildes: ${response.statusCode}');
        }
      } else {
        print('Datei existiert bereits: $filePath');
        job.downloaded = true;

        var instance = DataModel();
        instance
            .saveCurrentJobs(); // storing to the downloaded status to the local db
      }
    }
  }

  List<Job> keepUserData(List<Job> newJobs, List<Job> currJobs) {
    // Gehe durch die Liste der neuen Jobs
    for (var newJob in newJobs) {
      // Suche nach dem entsprechenden aktuellen Job in currJobs anhand der ID
      var currJob = currJobs.firstWhereOrNull((job) => job.id == newJob.id);

      // Falls der Job bereits bekannt ist, übernehme die user-spezifischen Felder
      if (currJob != null) {
        newJob.progress = currJob.progress;
        newJob.comments = currJob.comments;
        newJob.userStatus = currJob.userStatus;
        newJob.downloaded = currJob.downloaded;
      }
    }

    // Rückgabe der Liste der neuen Jobs mit den aktualisierten User-Daten
    return newJobs;
  }

  saveDoneJobsToLocalStorage(List<Job> doneJobs) async {
    final doneJobsJson = doneJobs.map((e) => Job.toJson(e)).toList();
    final prefs = await SharedPreferences.getInstance();
    final String doneJobsString = jsonEncode(doneJobsJson);
    print("saving");
    print(doneJobsJson);
    await prefs.setString('doneJobs', doneJobsString);
  }
}
