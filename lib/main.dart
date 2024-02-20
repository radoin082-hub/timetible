import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/pages/FacultiesPage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Language(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FacultiesPage(),
    );
  }
}
