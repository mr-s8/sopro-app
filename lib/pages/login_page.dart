import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskscout/config.dart';
import 'package:taskscout/services/auth_services.dart';
import 'dart:convert';
import '../app_colors.dart';
import 'home_page.dart'; // Importiere die HomePage
import 'package:taskscout/components/my_login_button.dart';
import 'package:taskscout/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  void _loginUser(BuildContext context) {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _authService.showError(context, "Bitte beide Felder ausfüllen.");
      return;
    }

    _authService.loginUser(context, username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 70),
              Image.asset(
                "lib/assets/taskscout_logo.png",
                width: 150,
              ),
              const SizedBox(height: 50),
              const Text(
                "Willkommen",
                style: TextStyle(
                  color: AppColors.font2,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: usernameController,
                hintText: "Username",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: passwordController,
                hintText: "Passwort",
                obscureText: true,
              ),
              const SizedBox(height: 20),
              MyLoginButton(
                onTap: () => _loginUser(context), // loginUser-Funktion aufrufen
              ),
            ],
          ),
        ),
      ),
    );
  }
}
