import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskscout/pages/login_page.dart';
import 'package:taskscout/services/auth_services.dart';
import '../app_colors.dart';

class AccountPage extends StatelessWidget {
  AccountPage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 200,
            bottom: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 100,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name: HansPeter', // Name des Benutzers
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rollen: Worker', // Rollen des Benutzers
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _authService.logoutUser(context),
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.primaryColor,
                ),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 64, vertical: 18),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
