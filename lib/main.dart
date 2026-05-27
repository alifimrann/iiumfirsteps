import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const IIUMFirstStepsApp());
}

class IIUMFirstStepsApp extends StatelessWidget {
  const IIUMFirstStepsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIUM First Steps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainLayout(),
    );
  }
}
