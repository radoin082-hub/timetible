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
      final data = json.decode(response.data);
      setState(() {
        departments = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFrench = Provider.of<Language>(context).isFrench;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark; // Check if dark mode is enabled

    return Scaffold(
      appBar: AppBar(
        title: Text('Departments'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Provider.of<Language>(context, listen: false).toggleLanguage();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Color.fromARGB(255, 0, 0, 0) : Colors.white, // Adjust background color based on theme
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color:isDarkMode ?  Colors.red.withOpacity(0.3):Colors.grey.withOpacity(0.5),
                  spreadRadius:0.4,
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: ListTile(
              title: Text(isFrench ? departments[index]['name_fr'] : departments[index]['name_ar']),
              leading: Icon(Icons.account_balance),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecialityPage(departmentId: departments[index]['id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
