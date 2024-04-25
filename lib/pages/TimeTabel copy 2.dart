 
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'package:timo/Management/SharedPreferences.dart';
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
//   final GlobalKey _className = GlobalKey();
//   final GlobalKey _speedDialKey = GlobalKey();
//   final GlobalKey _offlineKey = GlobalKey();
//   final GlobalKey _analyserKey = GlobalKey();
//   final GlobalKey _returnToFacScr = GlobalKey();
//   final GlobalKey _viewLocationKey = GlobalKey();
// final GlobalKey _joinOnlineClassKey = GlobalKey();

 



//   Future<Map<String, List<TimetableEntry>>>? groupedTimetableFuture;
// final List<String> daysOfWeek = [
//     'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
//   ];


// bool _isFirstLaunch = true;

// void initState() {

//     super.initState();
//         Prefs.init().then((_) {
//         print("Is first run from FacultiesPage: ${Prefs.isFirstRun}");
//         if (Prefs.isFirstRun) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//                 ShowCaseWidget.of(context)?.startShowCase([_className,
//         _speedDialKey,
//         _offlineKey,
//         _analyserKey,
//         _returnToFacScr]);
//             });
//         }
//     });
//     loadDataAndFetchTimetable();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ShowCaseWidget.of(context)?.startShowCase([
//         _className,
//         _speedDialKey,
//         _offlineKey,
//         _analyserKey,
//         _returnToFacScr
//       ]);
//     });
//   }
 
// void checkFirstRunAndShowcase() async {
//     await Prefs.init();
//     print("Showcase check - Is first run: ${Prefs.isFirstRun}");

//     if (Prefs.isFirstRun) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//             ShowCaseWidget.of(context)?.startShowCase([_className,
//         _speedDialKey,
//         _offlineKey,
//         _analyserKey,
//         _returnToFacScr]);
//             // Optionally, consider setting it false here after showing, to avoid re-showing if not needed.
//         });
//     }
// }

//   void checkFirstLaunch() async {
//     _isFirstLaunch = await PreferencesManager.isFirstLoad();
//     if (_isFirstLaunch) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ShowCaseWidget.of(context)?.startShowCase([_className,
//         _speedDialKey,
//         _offlineKey,
//         _analyserKey,
//         _returnToFacScr]);
//         PreferencesManager.setFirstLoadComplete();
//       });
//     }
//   }


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
//     } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//       return Text("No timetable entries found.");
//     } else {
//       bool isFirst = true; // To track the first item
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
//                 if (isFirst) {
//                   isFirst = false; // Set to false after showcasing the first item
//                   return Showcase(
//                     key: _className,
//                     description: 'This is the first class of the week',
//                     child: ListTile(
//                       title: Text("${timetableEntry.moduleCode} - ${timetableEntry.className}"),
//                       subtitle: Text('${timetableEntry.dayName}: ${slotTime['start']} - ${slotTime['end']}'),
//                       onTap: () => _showTimetableEntryDialog(context, timetableEntry),
//                     ),
//                   );
//                 }
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

    
//       floatingActionButton: Showcase(
//         key: _speedDialKey,
//         description: 'Tap here to open speed dial options',
//         child: buildSpeedDial(
          
//         ),
//       ),
    
//     );
//   }

//   SpeedDial buildSpeedDial() {
//     return SpeedDial(
//       icon: Icons.add,
//       activeIcon: Icons.close,
//       buttonSize: Size(56, 56),
//       visible: true,
//       curve: Curves.bounceIn,
//       overlayColor: Colors.black,
//       overlayOpacity: 0.5,
//       tooltip: 'Speed Dial',
//       heroTag: 'speed-dial-hero-tag',
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       elevation: 8.0,
//       shape: CircleBorder(),
//       children: [
//         SpeedDialChild(
//           child: Showcase(
//             title: 'Offline',
//             key: _offlineKey,
//             description: 'Tap to display time taebl offline mode , but for better use internet',
//             child: Icon(Icons.wifi_off_outlined),
//           ),
//           backgroundColor: Colors.red,
//           label: 'Offline',
//           onTap: () {
//             // Action for the first button
//           },
//         ),
//         SpeedDialChild(
//           child: Showcase(
//             key: _analyserKey,
//             description: 'Tap to analyse your week days',
//             child: Icon(Icons.analytics_outlined),
//           ),
//           backgroundColor: Colors.blue,
//           label: 'Option 2',
//           onTap: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>WeekdayAnalysisPage()));
//           },
//         ),
//         SpeedDialChild(
//           child: Showcase(
//             key: _returnToFacScr,
//             description: 'Tap to return to faculties page(main page)',
//             child: Icon(Icons.home),
//           ),
//           backgroundColor: Colors.green,
//           label: 'Main Page',
//           onTap: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>FacultiesPage()));
//           },
//         ),
//       ],
//     );


//   }


//  void _showTimetableEntryDialog(BuildContext context, TimetableEntry entry) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       // Determine if we should showcase the online join button
//       bool shouldShowcaseOnline = entry.isOnline && entry.onlineLink.isNotEmpty;
      
//       // Optional: Start the showcase when the dialog is opened
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         List<GlobalKey> showcaseKeys = [_viewLocationKey];
//         if (shouldShowcaseOnline) {
//           showcaseKeys.add(_joinOnlineClassKey);
//         }
//         ShowCaseWidget.of(context)?.startShowCase(showcaseKeys);
//       });

//       return AlertDialog(
//         title: Text(entry.className, style: TextStyle(fontWeight: FontWeight.bold)),
//         content: SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               ListTile(
//                 leading: Icon(FontAwesomeIcons.chalkboardTeacher),
//                 title: Text('Professor: ${entry.professorFirstName} ${entry.professorLastName}'),
//               ),
//               ListTile(
//                 leading: Icon(FontAwesomeIcons.clock),
//                 title: Text('Time: ${entry.classTime}'),
//               ),
//               ListTile(
//                 leading: Icon(FontAwesomeIcons.building),
//                 title: Text('Location: ${entry.location}'),
//               ),
//               if (shouldShowcaseOnline)
//                 Showcase(
//                   key: _joinOnlineClassKey,
//                   description: 'Join the online class here.',
//                   child: TextButton(
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
//                 ),
//               Showcase(
//                 key: _viewLocationKey,
//                 description: 'View the location on Google Maps.',
//                 child: TextButton(
//                   child: Text('View Location', style: TextStyle(decoration: TextDecoration.underline)),
//                   onPressed: () async {
//                     final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${entry.gpsLocation}');
//                     if (await canLaunchUrl(url)) {
//                       await launchUrl(url);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch Google Maps')));
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Close'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       );
//     },
//   );
// }

// }