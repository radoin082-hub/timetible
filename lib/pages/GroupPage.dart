import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      print('''
Response from Your_API_Endpoint: ${response.data}
''');
      final data = json.decode(response.data);
      setState(() {
        group = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFrench = Provider.of<Language>(context).isFrench;

    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => Provider.of<Language>(context, listen: false).toggleLanguage(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: group.length + 1, // Add one for the "ALL" item
        itemBuilder: (context, index) {
          if (index == group.length) {
            // This is the last item which is "ALL"
            return ListTile(
              title: Text("ALL"),
              onTap: () {
                // Handle tap on "ALL"
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TimeTablePage(groupId: 'null'), // Assuming 'all' is a valid ID for fetching all groups
                ));
              },
            );
          } else {
            // These are all the other items
            return ListTile(
              title: Text(isFrench ? group[index]['Abrev_fr'] : group[index]['Abrev_ar']),
  onTap: () async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastGroupId', group[index]['groupe_id']);
  Provider.of<TimetableData>(context, listen: false).setGroupId(group[index]['groupe_id']);

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TimeTablePage(groupId: group[index]['groupe_id'])),
  );
  print("Selected Group ID: ${group[index]['groupe_id']}");
}

  
  //             onTap: () async {
  //                 SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setString('lastGroupId', group[index]['groupe_id']);
  // Provider.of<TimetableData>(context, listen: false).setGroupId(group[index]['groupe_id']);
 
  //                Navigator.of(context).push(MaterialPageRoute(
  //                 builder: (context) => TimeTablePage(groupId: group[index]['groupe_id']),
  //               ));
  //             },
            );
          }
        },
      ),
    );
  }
}
