import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timo/Lang/Language.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/pages/TimeTabel.dart';

class GroupPage extends StatefulWidget {
  final String sectionID;

  GroupPage({required this.sectionID});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List group = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchGroup();
  }
fetchGroup() async {
  try {
final response = await dio.get('https://num.univ-biskra.dz/psp/pspapi/group?section=${widget.sectionID}&semester=2&key=appmob');
    final data = json.decode(response.data); // Decode the JSON string
    setState(() {
      group = data; // Use the decoded data
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
        title: Text('Groups'),
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
        itemCount: group.length,
        itemBuilder: (context, index) {
          return ListTile(
title: Text(isFrench ? group[index]['Abrev_fr'] : group[index]['Abrev_ar']),
             onTap: () {
  final timetableData = Provider.of<TimetableData>(context, listen: false);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TimeTablePage(),
    ),
  );
}

          );
        },
      ),
    );
  }
}


