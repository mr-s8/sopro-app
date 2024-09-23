import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskscout/classes/user.dart';
import 'package:taskscout/data_model.dart';
import 'package:taskscout/pages/login_page.dart';
import 'package:taskscout/services/auth_services.dart';
import './main_page.dart';
import './tasks_page.dart';
import './history_page.dart';
import './account_page.dart';
import '../app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MainPage(),
    const TasksPage(),
    const HistoryPage(),
    AccountPage()
  ];

  @override
  void initState() {
    super.initState();
    _authService
        .checkLoginStatus(context); // Login-Status beim Start der App prüfen
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
      builder: (context, value, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'TaskScout',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 40,
              ),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.info_outline,
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
        body: _pages[_currentIndex],
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            iconSize: 32,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.menuColor,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                label: 'Main',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.task,
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                ),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                label: 'Account',
              ),
            ],
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.white,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
