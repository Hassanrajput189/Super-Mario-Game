import 'package:flutter/material.dart';
import 'package:client/pages/HomePage.dart';
import "package:flutter/services.dart";
import 'package:hive_flutter/hive_flutter.dart';
import "package:client/models/progress.dart";
import 'package:client/boxes.dart';

Future main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ Initialize Hive for Flutter
    await Hive.initFlutter();

    // ✅ Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProgressAdapter());
    }

    // ✅ Lock orientation to landscape
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);

    // ✅ Open Hive box
    progressBox = await Hive.openBox<Progress>('ProgressBox');

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
