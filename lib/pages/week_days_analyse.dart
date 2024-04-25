// import 'dart:convert';
// import 'dart:math';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:badges/badges.dart' as badges;  // Add prefix to badges package
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timo/Services/cls.dart';
// import 'package:timo/Services/TimetableEntry.dart';
 
// class WeekdayAnalysisPage extends StatefulWidget {
//   @override
//   _WeekdayAnalysisPageState createState() => _WeekdayAnalysisPageState();
// }

// class _WeekdayAnalysisPageState extends State<WeekdayAnalysisPage> {
//   String? selectedDay;
//   List<String> daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
//   Future<Map<String, List<TimetableEntry>>>? groupedTimetableFuture;

//   @override
//   void initState() {
//     super.initState();
//     fetchTimetable();
//   }

//   void fetchTimetable() {
//     final timetableData = Provider.of<TimetableData>(context, listen: false);
//     groupedTimetableFuture = fetchTimetableService(
//       timetableData.specialtyId,
//       timetableData.levelId,
//       timetableData.sectionId,
//       timetableData.groupId
//     ).then((entries) {
//       Map<String, List<TimetableEntry>> groupedByDay = {};
//       for (var entry in entries) {
//         groupedByDay.putIfAbsent(entry.dayName, () => []).add(entry);
//       }
//       return groupedByDay;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Weekday Analysis'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: DropdownButton<String>(
//               value: selectedDay,
//               hint: Text("Select a day"),
//               items: daysOfWeek.map((String day) {
//                 return DropdownMenuItem<String>(
//                   value: day,
//                   child: Text(day),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedDay = value;
//                 });
//               },
//             ),
//           ),
//           if (selectedDay != null)
//             FutureBuilder<Map<String, List<TimetableEntry>>>(
//               future: groupedTimetableFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text("Error: ${snapshot.error}");
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Text("No timetable entries found.");
//                 } else {
//                   return Container(
//                     height: 300,
//                     child: _buildPieChartWithAnnotations(snapshot.data![selectedDay]!),
//                   );
//                 }
//               },
//             ),
//           Expanded(
//             child: selectedDay != null
//                 ? FutureBuilder<Map<String, List<TimetableEntry>>>(
//                     future: groupedTimetableFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return CircularProgressIndicator();
//                       } else if (snapshot.hasError) {
//                         return Text("Error: ${snapshot.error}");
//                       } else if (!snapshot.hasData || snapshot.data!.isEmpty || !snapshot.data!.containsKey(selectedDay)) {
//                         return Text("No entries for $selectedDay.");
//                       } else {
//                         var entries = snapshot.data![selectedDay]!;
//                         return ListView(
//                           children: entries.map((entry) {
//                             return ListTile(
//                               title: Text('${entry.className}'),
//                               subtitle: Text('${entry.classTime}'),
//                             );
//                           }).toList(),
//                         );
//                       }
//                     },
//                   )
//                 : Center(child: Text('Please select a day.')),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPieChartWithAnnotations(List<TimetableEntry> entries) {
//     double totalMinutes = entries.fold(0.0, (sum, entry) => sum + entry.timeSlot.toDouble());
//     List<PieChartSectionData> sections = [];
//     List<Widget> annotations = [];
//     double currentAngle = -90.0;

//     for (var entry in entries) {
//       double sectionSize = (entry.timeSlot / totalMinutes) * 360;
//       sections.add(PieChartSectionData(
//         color: _randomColor(),
//         value: entry.timeSlot.toDouble(),
//         radius: 50.0,
//       ));

//       // Calculate the middle of each section
//       double middleAngle = currentAngle + sectionSize / 2;
//       currentAngle += sectionSize;

//       // Calculate position for the badges
//       double xPos = 150 + 100 * cos(middleAngle * pi / 180);
//       double yPos = 150 + 100 * sin(middleAngle * pi / 180);

//       // Add badge widget
//       annotations.add(Positioned(
//         left: xPos,
//         top: yPos,
//         child: badges.Badge(
//           badgeContent: Text(entry.className),
//           position: badges.BadgePosition.topEnd(top: -12, end: -20),
//           child: Icon(Icons.arrow_right, size: 24),
//         ),
//       ));
//     }

//     return Stack(
//       children: [
//         PieChart(PieChartData(sections: sections)),
//         ...annotations,
//       ],
//     );
//   }

//   Color _randomColor() {
//     Random random = Random();
//     return Color.fromRGBO(
//       random.nextInt(256),
//       random.nextInt(256),
//       random.nextInt(256),
//       1,
//     );
//   }

//   final Dio _dio = Dio();

//   Future<List<TimetableEntry>> fetchTimetableService(String specialtyId, String levelId, String sectionId , String groupId) async {
//     final String requestUrl = 'https://num.univ-biskra.dz/psp/emploi/section2_public?select_spec=$specialtyId&niveau=$levelId&section=$sectionId&groupe=$groupId&sg=0&langu=fr&sem=2&id_year=2';
    

    
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     try {
//       final response = await _dio.get(requestUrl);
//       if (response.statusCode == 200) {
//         // Save the response data to SharedPreferences
//         await prefs.setString('timetableData', response.data.toString());
//         return _parseTimetableData(response.data);
//       } else {
//         throw Exception('Failed to fetch data from server');
//       }
//     } 
//   // Modify the catch block to return null or an empty list when there's no cached data
// catch (e) {
//   print('Error fetching timetable: $e');
//   String? cachedData = prefs.getString('timetableData');
//   if (cachedData != null) {
//     return _parseTimetableData(jsonDecode(cachedData));
//   } else {
//     // No data available
//     return [];
//   }
// }

//   }

//   // Helper function to parse timetable data
//   List<TimetableEntry> _parseTimetableData(dynamic data) {
//     final List<dynamic> jsonData = json.decode(data);
//     return jsonData.map<TimetableEntry>((json) => TimetableEntry.fromJson(json)).toList();
//   }

// }
