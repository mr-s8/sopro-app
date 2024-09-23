import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskscout/config.dart';
import 'package:taskscout/classes/user.dart';
import 'package:taskscout/data_model.dart';
import 'package:taskscout/pages/login_page.dart';
import 'package:taskscout/pages/home_page.dart';
import 'package:taskscout/services/data_model_services.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Login-Funktion
  Future<void> loginUser(
      BuildContext context, String username, String password) async {
    try {
      // Mache eine POST-Anfrage zum Backend
      final response = await http.post(
        Uri.parse('http://${Config.backendIp}:${Config.backendPort}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Speichere die Daten im Secure Storage
          await _secureStorage.write(key: 'username', value: username);
          await _secureStorage.write(key: 'password', value: password);
          await _secureStorage.write(key: 'loggedIn', value: 'true');
          await _secureStorage.write(key: 'userId', value: data['id']);
          await _secureStorage.write(
              key: 'roles', value: jsonEncode(data['roles']));

          // Navigiere zur HomePage, wenn der Login erfolgreich war
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }
      } else if (response.statusCode == 401) {
        showError(context, "Falsches Passwort oder Benutzername.");
      } else {
        showError(
            context, "Ein Fehler ist aufgetreten. Versuche es später erneut.");
      }
    } catch (e) {
      showError(context, "Netzwerkfehler. Überprüfe deine Verbindung. ${e}");
    }
  }

  // Funktion zum Logout
  Future<void> logoutUser(BuildContext context) async {
    await _secureStorage.deleteAll(); // Löscht alle gespeicherten Login-Daten

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // Funktion zum Login-Status prüfen
  Future<void> checkLoginStatus(BuildContext context) async {
/*
    FlutterSecureStorage sec = FlutterSecureStorage();
    sec.deleteAll();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    */

    String? loggedIn = await _secureStorage.read(key: 'loggedIn');

    if (!context.mounted) return;

    if (loggedIn != 'true') {
      // Falls nicht eingeloggt, gehe zur LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      proceedWithLoggedInUser(context);
    }
  }

  // Funktion zum Fortfahren, wenn der Benutzer eingeloggt ist
  Future<void> proceedWithLoggedInUser(BuildContext context) async {
    final dataModel = context.read<DataModel>();
    final dataServices = DataModelService();

    String? userId = await _secureStorage.read(key: 'userId');
    String? username = await _secureStorage.read(key: 'username');
    String? roles = await _secureStorage.read(key: 'roles');

    List<String> rolesData =
        roles != null ? List<String>.from(jsonDecode(roles)) : [];

    User user =
        User(id: userId ?? '', username: username ?? '', roles: rolesData);
    dataModel.user = user;

    var savedJobs = await dataServices.pullJobsFromLocalStorage();
    dataModel.tasks = savedJobs;

    var savedDoneJobs = await dataServices.pullDoneJobsFromLocalStorage();
    dataModel.doneTasks = savedDoneJobs;
    await dataModel.refreshList();
  }

  // Zeige Fehlermeldungen
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
