

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/pages/GroupPage.dart';
  String gLevel='';
class SectionPage extends StatefulWidget {
  final String level_specialty ;



  SectionPage({required this.level_specialty });

  @override
  _SectionPageState createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  List sections = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchSections();
  }
fetchSections() async {
  try {
    final response = await dio.get('https://num.univ-biskra.dz/psp/pspapi/section?level_specialty=${widget.level_specialty}&semester=2&key=appmob');
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
    final data = json.decode(response.data);
    gLevel=widget.level_specialty;

    final filteredData = (data as List).where((section) => section['id_year'] == "2").toList();
    setState(() {
      sections = filteredData;
    });
  } catch (e) {
    print(e);
  }
}

  @override
  Widget build(BuildContext context) {
    bool isFrench = Provider.of<Language>(context).isFrench; // Access the language state

    return Scaffold(

     appBar: AppBar(
        title: Text('sections'),
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
        itemCount: sections.length,
        itemBuilder: (context, index) {
          return ListTile(
  title: Text(isFrench ? sections[index]['Abrev_fr'] : sections[index]['Abrev_ar']),
 onTap: () async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastSectionId', sections[index]['sectionn_id']);
    Provider.of<TimetableData>(context, listen: false).setSectionId(sections[index]['sectionn_id']);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GroupPage(sectionID: sections[index]['sectionn_id']),
    ),
  );
}


          );
        },
      ),
    );
  }

}
