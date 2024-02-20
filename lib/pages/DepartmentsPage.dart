import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/pages/SpecialityPage.dart';

class DepartmentsPage extends StatefulWidget {
  final String facultyId;

  DepartmentsPage({required this.facultyId});

  @override
  _DepartmentsPageState createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  List departments = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }
fetchDepartments() async {
  try {
    final response = await dio.get('http://num.univ-biskra.dz/psp/pspapi/department?faculty=${widget.facultyId}&key=appmob');
    final data = json.decode(response.data); // Decode the JSON string
    setState(() {
      departments = data; // Use the decoded data
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
        title: Text('Departments'),
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
        itemCount: departments.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(isFrench ? departments[index]['name_fr'] : departments[index]['name_ar']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpecialityPage(departmentId: departments[index]['id']),
                ),
              );}
          );
        },
      ),
    );
  }
}


