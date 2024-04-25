import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/Management/SharedPreferences.dart';
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
  final GlobalKey _deptKey = GlobalKey();
  bool isFirstRun = true; // Define isFirstRun here

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    checkFirstRunAndShowcase();
  }

  void checkFirstRunAndShowcase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstRun = prefs.getBool('first_run') ?? true; // Update isFirstRun based on stored value

    if (isFirstRun) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context)?.startShowCase([_deptKey]);
        prefs.setBool('first_run', false); // Set to false so it doesn't show again
      });
    }
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Departments'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => Provider.of<Language>(context, listen: false).toggleLanguage(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (context, index) {
          Widget listItem = Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0.4,
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: ListTile(
              title: Text(isFrench ? departments[index]['name_fr'] : departments[index]['name_ar']),
              leading: Icon(Icons.account_balance),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('lastDepartmentId', departments[index]['id']);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SpecialityPage(departmentId: departments[index]['id']),
                  ),
                );
              },
            ),
          );

          // Only wrap the listItem with Showcase at a specific index and on first run
          if (index == 2 && isFirstRun) {
            return Showcase(
              key: _deptKey,
              title: 'Department Details',
              description: 'Tap to view specialties within this department',
              child: listItem,
            );
          }
          return listItem;
        },
      ),
    );
  }
}
