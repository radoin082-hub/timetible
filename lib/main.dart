import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/pages/FacultiesPage.dart';
import 'package:timo/pages/TimeTabel.dart';
import 'package:timo/Management/SharedPreferences.dart'; // Make sure to import your Prefs class

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Prefs.init(); // Initialize Prefs 
    bool isFirstRun = Prefs.isFirstRun;
    bool hasAllIds = Prefs.getIdSpecialty() != null;

    runApp(
        MultiProvider(
            providers: [
                ChangeNotifierProvider(create: (context) => Language()),
                ChangeNotifierProvider(create: (context) => TimetableData()),
            ],
            child: ShowCaseWidget(
                builder: Builder(
                    builder: (context) => MyApp(isFirstRun: isFirstRun, hasAllIds: hasAllIds),
                ),
            ),
        ),
    );
}

class MyApp extends StatelessWidget {
    final bool isFirstRun;
    final bool hasAllIds;

    MyApp({required this.isFirstRun, required this.hasAllIds});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'TIMO Biskra University Time Table',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: isFirstRun ? FacultiesPage() : (hasAllIds ? TimeTablePage() : FacultiesPage()),
        );
    }
}
