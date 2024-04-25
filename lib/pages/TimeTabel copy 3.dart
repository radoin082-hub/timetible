// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'package:timo/Management/storage.dart';
// import 'package:timo/Services/cls.dart';
// import 'package:timo/pages/FacultiesPage.dart';
// import 'package:timo/pages/offlineTimetableFromFilePage%20.dart';
// import 'package:timo/pages/week_days_analyse.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../Services/TimetableEntry.dart'; // Update the import path
// import '../Services/TimetableService.dart'; // Update the import path
 
 
// class TimeTablePage extends StatefulWidget {
//   @override
//   _TimeTablePageState createState() => _TimeTablePageState();
// }

// class _TimeTablePageState extends State<TimeTablePage> {
//   Future<Map<String, List<TimetableEntry>>>? groupedTimetableFuture;
// final List<String> daysOfWeek = [
//     'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
//   ];
//   GlobalKey _speedDialKey = GlobalKey();
// @override
// void initState() {
//   super.initState();
//   loadDataAndFetchTimetable();
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     checkFirstRunAndShowcase();
//   });
// }

// void checkFirstRunAndShowcase() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isFirstRun = prefs.getBool('first_launch') ?? true;
//   if (isFirstRun) {
//     ShowCaseWidget.of(context)?.startShowCase([_speedDialKey]);
//     prefs.setBool('first_launch', false);
//   }
// }

//   Future<void> loadDataAndFetchTimetable() async {
//     await Provider.of<TimetableData>(context, listen: false).loadPreferences();
//     fetchTimetable();
//   }
// Future<void> saveTimetableDataToFile(List<TimetableEntry> entries) async {
//   if (!(await requestStoragePermission())) {
//     print("Storage permission not granted.");
//     return;
//   }

//   FileManager fileManager = FileManager();
//   try {
//     String jsonData = jsonEncode(entries.map((e) => e.toJson()).toList());
//     await fileManager.writeTimetable(jsonData);
//     print("Data saved successfully to the file.");
//   } catch (e) {
//     print("Error saving timetable data to file: $e");
//   }
// }

// void fetchTimetable() async {
//   final timetableData = Provider.of<TimetableData>(context, listen: false);
//   try {
//     List<TimetableEntry> entries = await TimetableService().fetchTimetable(
//       timetableData.specialtyId,
//       timetableData.levelId,
//       timetableData.sectionId
//     );

//     Map<String, List<TimetableEntry>> groupedByDay = {};
//     for (var entry in entries) {
//       groupedByDay.putIfAbsent(entry.dayName, () => []).add(entry);
//     }

//     // Sort each day's entries by time slot
//     groupedByDay.forEach((day, list) {
//       list.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
//     });

//     // Sort days of the week
//     var sortedKeys = groupedByDay.keys.toList()
//       ..sort((a, b) => daysOfWeek.indexOf(a).compareTo(daysOfWeek.indexOf(b)));
//     Map<String, List<TimetableEntry>> sortedMap = {};
//     for (var key in sortedKeys) {
//       sortedMap[key] = groupedByDay[key]!;
//     }

//     // Save the data to a file
//     FileManager fileManager = FileManager();
//     String jsonData = jsonEncode(entries.map((e) => e.toJson()).toList());
//     await fileManager.writeTimetable(jsonData);

//     setState(() {
//       groupedTimetableFuture = Future.value(sortedMap);
//     });
//   } catch (e) {
//     print("Error fetching or saving timetable: $e");
//     setState(() {});
//   }
// }

// Future<bool> requestStoragePermission() async {
//   var status = await Permission.storage.status;
//   if (!status.isGranted) {
//     status = await Permission.storage.request();
//   }
//   return status.isGranted;
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('Timetable'),
//     ),
//    body: FutureBuilder<Map<String, List<TimetableEntry>>>(
//   future: groupedTimetableFuture,
//   builder: (context, snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return CircularProgressIndicator();
//     } else if (snapshot.hasError) {
//       return Text("Error: ${snapshot.error}");
//     } else if (snapshot.data == null || snapshot.data!.isEmpty) {  // Check if data is null or empty
//       return Text("No timetable entries found.");
//     } else {
//       return ListView(
//         children: snapshot.data!.entries.map((entry) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   entry.key,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//               ),
//               ...entry.value.map((timetableEntry) {
//                 var slotTime = timetableEntry.getSlotTime(); // Get the custom slot time
//                 return ListTile(
//                   title: Text("${timetableEntry.moduleCode} - ${timetableEntry.className}"),
//                   subtitle: Text('${timetableEntry.dayName}: ${slotTime['start']} - ${slotTime['end']}'),
//                   onTap: () => _showTimetableEntryDialog(context, timetableEntry),
//                 );
//               }).toList(),
//               Divider(),
//             ],
//           );
//         }).toList(),
//       );
//     }
//   },
// ),

//    floatingActionButton: Showcase(
//   key: _speedDialKey,
//   title: 'Add New Items',
//   description: 'Tap here to add new items or manage existing ones.',
//   child: SpeedDial(
//   icon: Icons.add,
//   activeIcon: Icons.close,
//   buttonSize:Size(56, 56),
//   visible: true,
//   curve: Curves.bounceIn,
//   overlayColor: Colors.black,
//   overlayOpacity: 0.5,
//   tooltip: 'Speed Dial',
//   heroTag: 'speed-dial-hero-tag',
//   backgroundColor: Colors.white,
//   foregroundColor: Colors.black,
//   elevation: 8.0,
//   shape: CircleBorder(),
//   children: [
//     SpeedDialChild(
//       child: Icon(Icons.accessibility),
//       backgroundColor: Colors.red,
//       label: 'analyse',
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => WeekdayAnalysisPage()),
//       ),
//     ),
//     SpeedDialChild(
//       child: Icon(Icons.brush),
//       backgroundColor: Colors.blue,
//       label: 'offline',
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => CourseSchedule()),
//       ),
//     ),
//     SpeedDialChild(
//       child: Icon(Icons.keyboard_voice),
//       backgroundColor: Colors.green,
//       label: 'fac',
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => FacultiesPage()),
//       ),
//     ),
//   ],
// ),

//   ));
// }

//   void _showTimetableEntryDialog(BuildContext context, TimetableEntry entry) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(entry.className, style: TextStyle(fontWeight: FontWeight.bold)),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 ListTile(
//                   leading: Icon(FontAwesomeIcons.chalkboardTeacher),
//                   title: Text('Professor: ${entry.professorFirstName} ${entry.professorLastName}'),
//                 ),
//                 ListTile(
//                   leading: Icon(FontAwesomeIcons.clock),
//                   title: Text('Time: ${entry.classTime}'),
//                 ),
//                 ListTile(
//                   leading: Icon(FontAwesomeIcons.building),
//                   title: Text('Location: ${entry.location}'),
//                 ),
//                 if (entry.isOnline && entry.onlineLink.isNotEmpty)
//                   TextButton(
//                     child: Text('Join Online Class', style: TextStyle(decoration: TextDecoration.underline)),
//                     onPressed: () async {
//                       final Uri url = Uri.parse(entry.onlineLink);
//                       if (await canLaunchUrl(url)) {
//                         await launchUrl(url);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open the link')));
//                       }
//                     },
//                   ),
//                 if (entry.gpsLocation.isNotEmpty)
//                   TextButton(
//                     child: Text('View Location', style: TextStyle(decoration: TextDecoration.underline)),
//                     onPressed: () async {
//                       final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${entry.gpsLocation}');
//                       if (await canLaunchUrl(url)) {
//                         await launchUrl(url);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch Google Maps')));
//                       }
//                     },
//                   ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Close'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }