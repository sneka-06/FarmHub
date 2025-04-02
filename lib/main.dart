import 'package:farm_hub/front_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //print("🔥 Firebase Connected Successfully!");
  runApp(MyApp());
}
//options: DefaultFirebaseOptions.currentPlatform

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FrontScreen(), debugShowCheckedModeBanner: false);
  }
}
