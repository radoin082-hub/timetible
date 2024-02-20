import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Lang/Language.dart';
import 'dart:convert';
import 'package:timo/pages/DepartmentsPage.dart';



class FacultiesPage extends StatefulWidget {
  @override
  _FacultiesPageState createState() => _FacultiesPageState();
}

class _FacultiesPageState extends State<FacultiesPage> {
  List faculties = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchFaculties();
  }

fetchFaculties() async {
  try {
    final response = await dio.get('http://num.univ-biskra.dz/psp/pspapi/faculty?key=appmob');
    final data = json.decode(response.data); // Decode the JSON string
    setState(() {
      faculties = data; // Use the decoded data
    });
  } catch (e) {
    print(e);
  }
}
  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<Language>(context).isFrench; // Accessing language state

    return Scaffold(
      appBar: AppBar(
        title: Text('Faculties'),
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
        itemCount: faculties.length,
              itemBuilder: (context, index) {
          return ListTile(
            title: Text(isFrench ? faculties[index]['name_fac'] : faculties[index]['name_fac_ar']),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DepartmentsPage(facultyId: faculties[index]['id_fac']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

