// ignore: file_names
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/pages/SectionPage.dart';

class LevelPage extends StatefulWidget {
  final String id_specialty;


  LevelPage({required this.id_specialty});

  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  List levels = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchLevels();
  }
fetchLevels() async {
  try {
    final response = await dio.get('https://num.univ-biskra.dz/psp/pspapi/level?specialty=${widget.id_specialty}&semester=2&key=appmob');
    print('''
=========================================================================================================
=========================================================================================================
=========================================
=========================================================================================================
Response from Your_API_Endpoint: ${response.data}
=========================================================================================================
=========================================================================================================
=========================================================================================================
''');
    final data = json.decode(response.data); // Decode the JSON string
    setState(() {
      levels = data; // Use the decoded data
    });
  } catch (e) {
    print(e);
  }
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

     appBar: AppBar(
        title: Text('Level'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Provider.of<Language>(context, listen: false).toggleLanguage(); // Toggling language
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          return ListTile(
  title: Text(
    levels[index]['id_niveau'] == "1" ? "L1" :
    levels[index]['id_niveau'] == "2" ? "L2" :
    levels[index]['id_niveau'] == "3" ? "L3" :
    levels[index]['id_niveau'] == "4" ? "M1" :
    levels[index]['id_niveau'] == "5" ? "M2" : "Unknown Level"
  ),
  
onTap: () {
  // تحديد قيمة niveau بناءً على id_niveau
  String niveauValue = "";
  switch (levels[index]['id_niveau']) {
    case "1":
      niveauValue = "1";
      break;
    case "2":
      niveauValue = "2";
      break;
    case "3":
      niveauValue = "3";
      break;
    case "4":
      niveauValue = "4";
      break;
    case "5":
      niveauValue = "5";
      break;
    default:
      niveauValue = "0"; // قيمة افتراضية في حال لم يتم تطابق أي حالات
  }

  // تعيين قيمة niveau في Provider
  Provider.of<TimetableData>(context, listen: false).setNiveau(niveauValue);

  // التنقل إلى SectionPage
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SectionPage(level_specialty: levels[index]['id_niv_spec']),
    ),
  );
}


          );
        },
      ),
    );
  }
}


