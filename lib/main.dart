import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart'; 
import 'package:provider/provider.dart';
import 'package:timo/Services/cls.dart';
import 'Lang/Language.dart';
import 'pages/FacultiesPage.dart';

void main() {
  runApp(
    MultiProvider( 
      providers: [
        ChangeNotifierProvider(create: (context) => Language()),
        ChangeNotifierProvider(create: (context) => TimetableData()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      home: SplashPage(),
    );
  }
}


class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add a delay before navigating to FacultiesPage
    Future.delayed(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => FacultiesPage()),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TypewriterAnimatedTextKit(
              text: ['TIMO\nBiskra Unversity Time Table'],
              textStyle: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
