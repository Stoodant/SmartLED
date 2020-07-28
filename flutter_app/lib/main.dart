import 'package:flutter/material.dart';
import 'pages/tabs.dart';
import 'pages/create.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Tabs(),
        routes: <String, WidgetBuilder>{'draw': (_) => drawPage()});
  }
}
