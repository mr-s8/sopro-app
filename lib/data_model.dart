import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Für JSON-Parsing
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskscout/classes/job.dart';
import 'package:taskscout/classes/user.dart';
import 'package:taskscout/services/auth_services.dart';
import 'package:taskscout/services/data_model_services.dart';
import './config.dart';

class DataModel extends ChangeNotifier {
  static final DataModel _instance = DataModel._internal();
  late User user;
  List<Job> tasks = [];
  List<Job> doneTasks = [];

  final DataModelService _dataService = DataModelService();

  DataModel._internal();

  factory DataModel() {
    return _instance;
  }

  Future<void> refreshList() async {
    try {
      tasks = await _dataService.refreshJobs(user);
    } catch (e) {
      print('Fehler beim Aktualisieren: $e');
    }
    notifyListeners();
  }

  Future<void> saveCurrentJobs() async {
    try {
      await _dataService.saveJobsToLocalStorage(tasks);
    } catch (e) {
      print('Fehler beim speichern der Jobs: $e');
    }
  }

  removeJob(String id) async {
    tasks.removeWhere((job) => job.id == id);
    await saveCurrentJobs();
    notifyListeners();
  }

  saveDoneJob(Job job) async {
    doneTasks.add(job);
    await _dataService.saveDoneJobsToLocalStorage(doneTasks);
    notifyListeners();
  }
}



// todo: gloablen authservice stellen, funktionen für refresh userdata oder so, schauen dass alles auch immer persistiert wird
// beendete jobs sollten in eine extra liste
// kleine beschreibung des jobs
// da man die job instanzen mutiert, einfach den string zurückspeichern?
// map noch extra speichern
// startjob (status setzen, in ls speichern und notify -> task_page muss consumer sein) methode im datamodel (generell, was muss noch ins datamodel; saveProgress, finishjob?)
//downloadstatus speichern und starten nicht zulassen bevor nicht heruntergeladen...
//downloadimages outsourcen
//progress

// bei refresh sind alle userspezifischen daten weg!!! deswegen trennen...
// darüber klar werden wann provider und wann setstate
// checken was ich jetzt wie auslager