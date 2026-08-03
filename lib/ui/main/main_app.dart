import 'package:flutter/material.dart';
import 'package:than_player/ui/main/home/home_screen.dart';
import 'package:than_player/ui/partials/material_theme_provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialThemeProvider(child: HomeScreen());
  }
}
