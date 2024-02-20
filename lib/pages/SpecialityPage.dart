import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/pages/LevelPage.dart';

class SpecialityPage extends StatefulWidget {
  final String departmentId;

  SpecialityPage({required this.departmentId});

  @override
  _SpecialityPageState createState() => _SpecialityPageState();
}

class _SpecialityPageState extends State<SpecialityPage> {
  List specialities = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchScpeciality();
  }
fetchScpeciality() async {
  try {
    // final response = await dio.get('http://num.univ-biskra.dz/psp/pspapi/department?faculty=${widget.facultyId}&key=appmob');
    final response = await dio.get('https://num.univ-biskra.dz/psp/pspapi/specialty?department=${widget.departmentId}&semester=2&key=appmob');

    final data = json.decode(response.data); // Decode the JSON string
    setState(() {
      specialities = data; // Use the decoded data
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
        title: Text('Specialities'),
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
        itemCount: specialities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(isFrench ? specialities[index]['Nom_spec'] : specialities[index]['name_spec_ar']),
             
               onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LevelPage(id_specialty: specialities[index]['id_specialty']),
                ),
              );}
             
               );
        },
      ),
    );
  }
}


