 import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
 

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:timo/Management/storage.dart';
import 'package:timo/Services/cls.dart';
import 'package:timo/offEntry.dart';
import 'package:timo/pages/FacultiesPage.dart';
import 'package:timo/pages/offlineTimetableFromFilePage%20.dart';
import 'package:timo/pages/week_days_analyse.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/TimetableEntry.dart'; // Update the import path
  
 
class TimeTablePage extends StatefulWidget {
  final String? groupId;  // Make groupId nullable

  // Make groupId optional in the constructor
  TimeTablePage({this.groupId});

  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  Future<Map<String, List<TimetableEntry>>>? groupedTimetableFuture;
final List<String> daysOfWeek = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];
  GlobalKey _speedDialKey = GlobalKey();
  GlobalKey _offlinelKey = GlobalKey();
  GlobalKey _analyselKey = GlobalKey();
  GlobalKey _facScrKey = GlobalKey();
  GlobalKey _cls = GlobalKey();
  GlobalKey _downloadPdf = GlobalKey(); 
@override
void initState() {
  super.initState();
  loadDataAndFetchTimetable();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    checkFirstRunAndShowcase();
  });
}

void checkFirstRunAndShowcase() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('first_launch') ?? true;
  if (isFirstRun) {
    ShowCaseWidget.of(context)?.startShowCase([_speedDialKey,_offlinelKey,_facScrKey,_downloadPdf,_analyselKey,_cls]);
    prefs.setBool('first_launch', false);
  }
}









 

Future<void> generateAndSavePdf(List<offEntry> entries) async {
final pdf = pw.Document();

// Generate the PDF content using your entries...
pdf.addPage(
pw.MultiPage(
build: (context) => [
pw.Table.fromTextArray(
context: context,
headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
headers: ['Class Name', 'Professor', 'Time Slot', 'Location', 'Type', 'Level'],
data: entries.map((e) => [
e.className,
'${e.professorFirstName} ${e.professorLastName}',
'${e.getSlotTime()['start']} - ${e.getSlotTime()['end']}',
e.location,
e.courseType,
e.level,
]).toList(),
),
],
),
);

final fileManager = FileManager();
final pdfBytes = await pdf.save();

// Save the PDF to the Documents directory
final fileName = "timetable.pdf"; // You can use a more descriptive name or include a timestamp
final file = await fileManager.savePdfToDocuments(pdfBytes, fileName);

if (await file.exists()) {
print("PDF saved successfully at ${file.path}");
// Optionally, you can add a feature to open the file automatically after saving
// openFile(file.path);
} else {
print("Failed to save PDF.");
}
}

Future<void> checkPermissionAndGeneratePdf(List<offEntry> entries) async {
var status = await Permission.storage.status;
if (!status.isGranted) {
// Requesting permission
status = await Permission.storage.request();
}

if (status.isGranted) {
// Proceed to generate and save PDF if permission is granted
final pdf = pw.Document();
pdf.addPage(
pw.MultiPage(
build: (context) => [
pw.Table.fromTextArray(
context: context,
headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
headers: ['Class Name', 'Professor', 'Time Slot', 'Location', 'Type', 'Level'],
data: entries.map((e) => [
e.className,
'${e.professorFirstName} ${e.professorLastName}',
'${e.getSlotTime()['start']} - ${e.getSlotTime()['end']}',
e.location,
e.courseType,
e.level,
]).toList(),
),
],
),
);


final fileManager = FileManager();
final pdfBytes = await pdf.save();
final fileName = "timetable.pdf";
final file = await fileManager.savePdfToDocuments(pdfBytes, fileName);

if (await file.exists()) {
  print("PDF saved successfully at ${file.path}");
} else {
  print("Failed to save PDF.");
}
} else {
// Handle the case when the user denies the permission
print("Storage permission not granted");
}
}

 
 







  Future<void> loadDataAndFetchTimetable() async {
    await Provider.of<TimetableData>(context, listen: false).loadPreferences();
    fetchTimetable();
  }
Future<void> saveTimetableDataToFile(List<TimetableEntry> entries) async {
  if (!(await requestStoragePermission())) {
    print("Storage permission not granted.");
    return;
  }

  FileManager fileManager = FileManager();
  try {
    String jsonData = jsonEncode(entries.map((e) => e.toJson()).toList());
    await fileManager.writeTimetable(jsonData);
    print("Data saved successfully to the file.");
  } catch (e) {
    print("Error saving timetable data to file: $e");
  }
}

void fetchTimetable() async {
  final timetableData = Provider.of<TimetableData>(context, listen: false);
  try {
    List<TimetableEntry> entries = await fetchTimetableService(
      timetableData.specialtyId,
      timetableData.levelId,
      timetableData.sectionId,
      timetableData.groupId!
    );

    Map<String, List<TimetableEntry>> groupedByDay = {};
    for (var entry in entries) {
      groupedByDay.putIfAbsent(entry.dayName, () => []).add(entry);
    }

    // Sort each day's entries by time slot
    groupedByDay.forEach((day, list) {
      list.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
    });

    // Sort days of the week
    var sortedKeys = groupedByDay.keys.toList()
      ..sort((a, b) => daysOfWeek.indexOf(a).compareTo(daysOfWeek.indexOf(b)));
    Map<String, List<TimetableEntry>> sortedMap = {};
    for (var key in sortedKeys) {
      sortedMap[key] = groupedByDay[key]!;
    }

    // Save the data to a file
    FileManager fileManager = FileManager();
    String jsonData = jsonEncode(entries.map((e) => e.toJson()).toList());
    await fileManager.writeTimetable(jsonData);

    setState(() {
      groupedTimetableFuture = Future.value(sortedMap);
    });
  } catch (e) {
    print("Error fetching or saving timetable: $e");
    setState(() {});
  }
}

 












Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
  }
  return status.isGranted;
}

@override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Timetable'),
    ),
    body: FutureBuilder<Map<String, List<TimetableEntry>>>(
      future: groupedTimetableFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Text("No timetable entries found."),
          );
        } else {
          return ListView(
            children: snapshot.data!.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal[800],
                      ),
                    ),
                  ),
                  ...entry.value.map((timetableEntry) {
                    var slotTime = timetableEntry.getSlotTime();
                  Color cardColor; // Define a variable for the card color
                 Color? textColor;
                  TextStyle(color: textColor);
          switch (timetableEntry.courseType) {
            case 'TP':
              cardColor = Color.fromARGB(255, 14, 255, 255);
              textColor = Colors.amber;
              break;
            case 'Cours':
                          textColor = Colors.blueAccent;

              cardColor = Color.fromARGB(255, 14, 255, 195);
              break;
            case 'TD':
                          textColor = Colors.red;

              cardColor = Color.fromARGB(255, 10, 239, 124);// Set to purple for 'TD'
              break;
            default:
              cardColor = Colors.white; // Default color if none of the conditions are met
          }

                    return Card(
            color: cardColor,  
                      
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 2.0,
                      child: ListTile(
                        title: Text(
                          "${timetableEntry.courseType} :     ${timetableEntry.moduleCode}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                        ),
                        subtitle: Text(
                          '${timetableEntry.dayName}: ${slotTime['start']} - ${slotTime['end']}',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                    
                        onTap: () => _showTimetableEntryDialog(context, timetableEntry),
                      ),
                    );
                 
                  }).toList(),
                  SizedBox(height: 16.0),
                ],
              );
            }).toList(),
          );
        }
      },
    ),

   floatingActionButton: Showcase(
  key: _speedDialKey,
  title: 'Expand',
  description: 'Tap here to Show hidden buttons.',
  child: SpeedDial(
  icon: Icons.add,
  activeIcon: Icons.close,
  buttonSize:Size(56, 56),
  visible: true,
  curve: Curves.bounceIn,
  overlayColor: Colors.black,
  overlayOpacity: 0.5,
  tooltip: 'Speed Dial',
  heroTag: 'speed-dial-hero-tag',
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 8.0,
  shape: CircleBorder(),
  children: [
    SpeedDialChild(
      child: Showcase(

      key: _analyselKey,
      description: 'for this can show whats study each day ,this is Beta not stabel',
      title: 'Anayser Week days',
      child: Icon(Icons.accessibility)),
      backgroundColor: Colors.red,
      label: 'analyse',
     
    ),
    SpeedDialChild(
      child: Showcase(
        title: 'Offline Mode',
        key:_offlinelKey ,
        description: 'If not have an internet can use this to show timetabel ofline but for better use internet',
        child: Icon(Icons.brush)),
      backgroundColor: Colors.blue,
      label: 'offline',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CourseSchedule()),
      ),
    ),
    SpeedDialChild(
      child: Showcase(
        key: _facScrKey,
        description: 'this buttons is back to faculties screen',
        title: 'Back to main page',
        child: Icon(Icons.keyboard_voice)),
      backgroundColor: Colors.green,
      label: 'fac',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FacultiesPage()),
      ),
    ),
   SpeedDialChild(
  child: Showcase(
    key: _downloadPdf,
    description: 'Tap to download the timetable as a PDF.',
    title: 'Download PDF',
    child: Icon(Icons.download),
  ),
  backgroundColor: Colors.green,
  label: 'Download PDF',
  onTap: () async {
    try {
      
      // استخدام FileManager لقراءة البيانات من الملف
      final fileManager = FileManager();
      final jsonString = await fileManager.readTimetable();
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final entries = jsonData.map((item) => offEntry.fromJson(item)).toList();
      
      // توليد الـ PDF
 await checkPermissionAndGeneratePdf(entries);
      // إظهار رسالة نجاح أو فتح الملف تلقائيًا إذا تم الحفظ بنجاح
      print('PDF generated successfully!');
    } catch (e) {
      print('Error generating PDF: $e');
      // إظهار رسالة خطأ إذا حدث خطأ
    }
  },
),

 
   ],
),

  )
  );
  
}

  
   final Dio _dio = Dio();

  Future<List<TimetableEntry>> fetchTimetableService(String specialtyId, String levelId, String sectionId, String groupeId) async {
   
    final String requestUrl = 'https://num.univ-biskra.dz/psp/emploi/section2_public?select_spec=$specialtyId&niveau=$levelId&section=$sectionId&groupe=$groupeId&sg=0&langu=fr&sem=2&id_year=2';
    
print('section = $sectionId  group = $groupeId');
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await _dio.get(requestUrl);
      if (response.statusCode == 200) {
        // Save the response data to SharedPreferences
        await prefs.setString('timetableData', response.data.toString());
        return _parseTimetableData(response.data);
      } else {
        throw Exception('Failed to fetch data from server');
      }
    } 
  // Modify the catch block to return null or an empty list when there's no cached data
catch (e) {
  print('Error fetching timetable: $e');
  String? cachedData = prefs.getString('timetableData');
  if (cachedData != null) {
    return _parseTimetableData(jsonDecode(cachedData));
  } else {
    // No data available
    return [];
  }
}

  }

  // Helper function to parse timetable data
  List<TimetableEntry> _parseTimetableData(dynamic data) {
    final List<dynamic> jsonData = json.decode(data);
    return jsonData.map<TimetableEntry>((json) => TimetableEntry.fromJson(json)).toList();
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
