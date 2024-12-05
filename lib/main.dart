import 'package:firebase_lesson/audio/audio_app.dart';
import 'package:firebase_lesson/chat/authentication/user_information_screen.dart';
import 'package:firebase_lesson/chat/screen/chat_screen.dart';
import 'package:firebase_lesson/chat/test/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AudioPlayerExample(),
    );
  }
}
