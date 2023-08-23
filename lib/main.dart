import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:rhyno_admin_app/firebase/auth.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/shared_prefernces.dart';
import 'package:rhyno_admin_app/screens/profile.dart';
import 'package:rhyno_admin_app/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

void onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final service = FlutterBackgroundService();
  service.setNotificationInfo(title: 'Rhyno Admin', content: 'Running Service');
  service.setAutoStartOnBootMode(true);
  service.onDataReceived.listen((event) {
    if (event!['action'] == 'stopService') {
      service.stopBackgroundService();
    }
  });
  final startAudioPlayer = AudioPlayer();
  final endAudioPlayer = AudioPlayer();

  final startPlayer = AudioCache(prefix: 'assets/audio/');
  startPlayer.fixedPlayer = startAudioPlayer;

  final endPlayer = AudioCache(prefix: 'assets/audio/');
  endPlayer.fixedPlayer = endAudioPlayer;

  DatabaseMethods().getEndRideRequest(false).listen((event) async {
    if (await AuthMethods().getCurrentUser() != null) {
      if (event.docs.isNotEmpty) {
        if (endAudioPlayer.state != PlayerState.PLAYING) {
          endPlayer.loop('tone.mp3');
        }
      } else {
        endAudioPlayer.stop();
      }
    }
  });

  DatabaseMethods().getStartRideRequest(false).listen((event) async {
    if (await AuthMethods().getCurrentUser() != null) {
      if (event.docs.isNotEmpty) {
        if (startAudioPlayer.state != PlayerState.PLAYING) {
          startPlayer.play('tone.mp3');
        }
      } else {
        startAudioPlayer.stop();
      }
    }
  });

  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const KeyboardDismisser(
      gestures: [GestureType.onTap],
      child: MaterialApp(
        home: SplashScreen(),
      ),
    );
  }
}
