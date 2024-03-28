import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/pages/TimetableAnalysisPage.dart';
import '../Services/TimetableEntry.dart'; // Update the import path
import '../Services/TimetableService.dart'; // Update the import path
import 'package:url_launcher/url_launcher.dart';

class TimeTablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String specialtyId = Provider.of<TimetableData>(context).specialtyId;
    String levelId = Provider.of<TimetableData>(context).niveau;
    String sectionId = Provider.of<TimetableData>(context).sectionId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
      ),
      body: FutureBuilder<List<TimetableEntry>>(
        future: TimetableService().fetchTimetable(specialtyId, levelId, sectionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            // Sort entries by dayOfWeek
            snapshot.data?.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                TimetableEntry entry = snapshot.data![index];
                // Use the first entry of each new day to display the day name
                bool isFirstOfTheDay = index == 0 || snapshot.data![index - 1].dayOfWeek != entry.dayOfWeek;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirstOfTheDay) Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        entry.dayName, // Ensure dayName getter returns the name of the day
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    ListTile(
title: Text(entry.moduleCode != '' ? entry.moduleCode : entry.className),
                      subtitle: Text('${entry.dayName}: ${entry.classTime}'),
                      trailing: entry.isOnline 
                        ? Icon(FontAwesomeIcons.video, color: Colors.green)
                        : Icon(FontAwesomeIcons.university, color: Colors.red),
                      onTap: () => _showTimetableEntryDialog(context, entry),
                    ),
                    Divider(),
                  ],
                );
              },
            );
          }
        },
      ),
      // The floating action button should be within the Scaffold
      floatingActionButton: FloatingActionButton(
        
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TimetableAnalysisPage(timetableEntries: [],)), // Pass the required data if necessary
          );
        },
        child: Icon(Icons.analytics),
      ),
    );
  }

 void _showTimetableEntryDialog(BuildContext context, TimetableEntry entry) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(entry.className, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              ListTile(
                leading: Icon(FontAwesomeIcons.chalkboardTeacher),
                title: Text('Professor: ${entry.professorFirstName} ${entry.professorLastName}'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.clock),
                title: Text('Time: ${entry.classTime}'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.building),
                title: Text('Location: ${entry.location}'),
              ),
              if (entry.isOnline && entry.onlineLink.isNotEmpty) 
                TextButton(
                  child: Text('Join Online Class', style: TextStyle(decoration: TextDecoration.underline)),
                  onPressed: () async {
                    final Uri url = Uri.parse(entry.onlineLink);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open the link')));
                    }
                  },
                ),
              if (entry.gpsLocation.isNotEmpty) 
                TextButton(
                  child: Text('View Location', style: TextStyle(decoration: TextDecoration.underline)),
                  onPressed: () async {
                    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${entry.gpsLocation}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch Google Maps')));
                    }
                  }, 

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

}
