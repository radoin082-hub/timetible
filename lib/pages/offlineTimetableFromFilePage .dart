
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timo/offEntry.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseSchedule extends StatefulWidget {
  @override
  _CourseScheduleState createState() => _CourseScheduleState();
}

class _CourseScheduleState extends State<CourseSchedule> {
  late Future<List<offEntry>> entries;

  @override
  void initState() {
    super.initState();
    entries = loadEntries();
  }

  Future<List<offEntry>> loadEntries() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '/data/user/0/com.example.timo/app_flutter/timetable.json'; // Ensure this path is correct
    final file = File(filePath);
    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);
    return jsonData.map((item) => offEntry.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Course Schedule")),
      body: FutureBuilder<List<offEntry>>(
        future: entries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              return Center(child: Text("Error loading data."));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                offEntry entry = snapshot.data![index];
                return ListTile(
                  title: Text(entry.className),
                  subtitle: Text('${entry.professorFirstName} ${entry.professorLastName}'),
                  onTap: () => _showoffEntryDialog(context, entry),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showoffEntryDialog(BuildContext context, offEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(entry.className, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Professor: ${entry.professorFirstName} ${entry.professorLastName}'),
                Text('Location: ${entry.location}'),
                Text('Day: ${entry.dayName}'),
                Text('Time: ${entry.classTime}'),
                if (entry.isOnline)
                  TextButton(
                    child: Text('Join Online Class'),
                    onPressed: () => _launchURL(entry.onlineLink),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
