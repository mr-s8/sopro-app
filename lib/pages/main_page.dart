import 'package:flutter/material.dart';
import 'package:taskscout/app_colors.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 50.0,
            top: 100,
          ),
          child: Image.asset(
            'lib/assets/worker_image.png',
            width: 300,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/*

*/