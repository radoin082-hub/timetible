import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class TimeTablePage extends StatefulWidget {
  final String selectSpec;
  final String niveau;
  final String section;
  final String semester;
  final String idYear;

  TimeTablePage({
    required this.selectSpec,
    required this.niveau,
    required this.section,
    required this.semester,
    required this.idYear,
  });

  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  List<List<String>> timetable = [];

  @override
  void initState() {
    super.initState();
    fetchTimetable();
  }

  fetchTimetable() async {
    try {
      var response = await Dio().get(
          'https://num.univ-biskra.dz/psp/emploi/section2_public?select_spec=${widget.selectSpec}&niveau=${widget.niveau}&section=${widget.section}&groupe=null&sg=0&langu=fr&sem=${widget.semester}&id_year=${widget.idYear}');
      setState(() {
        timetable = List<List<String>>.from(json.decode(response.data));
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
      ),
      body: ListView.builder(
        itemCount: timetable.length,
        itemBuilder: (context, index) {
          var session = timetable[index];
          return Card(
            child: ListTile(
              title: Text(session[0]), // Class name
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location: ${session[1]}"),
                  Text("Type: ${session[2]}"),
                  
                  // Add more fields as necessary
                ],
                
              ),
              
            ),
          );
        },
      ),
    );
  }
}
