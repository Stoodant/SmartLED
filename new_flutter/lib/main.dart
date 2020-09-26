import 'package:flutter/material.dart';
import 'pages/tabs.dart';
import 'pages/create.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Tabs(), routes: <String, WidgetBuilder>{
      'draw': (_) => drawPage(),
      //'edit': (_) => editPage(),
    });
  }
}
