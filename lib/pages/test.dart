import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLoginStatus(context),
      builder: (context, snapshot) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Ladeanzeige
          ),
        );
      },
    );
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    // Lade die Daten aus dem Secure Storage
    String? loggedIn = await storage.read(key: 'loggedIn');

    if (loggedIn == 'true') {
      // Falls der Benutzer eingeloggt ist, gehe zur HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Falls nicht eingeloggt, gehe zur LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
}
