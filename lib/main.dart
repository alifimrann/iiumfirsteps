import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'screens/main_layout.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Uncomment the lines below after you have run 'flutterfire configure' in the terminal
   await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
  );

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
