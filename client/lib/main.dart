import 'package:flutter/material.dart';
import 'package:client/pages/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';

import "firebase_options.dart";

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const App());
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
