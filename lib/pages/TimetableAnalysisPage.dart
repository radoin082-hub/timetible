import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timo/Services/TimetableEntry.dart';

class TimetableAnalysisPage extends StatefulWidget {
  final List<TimetableEntry> timetableEntries;

  TimetableAnalysisPage({Key? key, required this.timetableEntries}) : super(key: key);

  @override
  _TimetableAnalysisPageState createState() => _TimetableAnalysisPageState();
}

class _TimetableAnalysisPageState extends State<TimetableAnalysisPage> {
  String selectedDay = 'Sunday';
  Map<String, double> durationPerSubject = {};
  List<PieChartSectionData> sections = [];

  @override
  void initState() {
    super.initState();
    updateSectionsForDay(selectedDay);
  }

  void updateSectionsForDay(String day) {
  print('Updating sections for day: $day');
  print('Timetable Entries: ${widget.timetableEntries.map((e) => e.dayName)}'); // Add this line to print all day names

  durationPerSubject.clear(); // Clear previous data

  final dailyEntries = widget.timetableEntries.where((entry) => entry.dayName == day);
  print('Daily entries count: ${dailyEntries.length}');

    print('Updating sections for day: $day');


    print('Daily entries count: ${dailyEntries.length}');

    for (var entry in dailyEntries) {
      durationPerSubject.update(
        entry.className,
        (existingDuration) => existingDuration + 90, // Add 90 minutes for each class
        ifAbsent: () => 90, // If it's the first class, start with 90 minutes
      );
    }

    print('Durations per subject: $durationPerSubject');

    // Now create the sections for the pie chart based on the calculated durations
    sections = durationPerSubject.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        color: Colors.primaries[durationPerSubject.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        // Apply other formatting styles as needed
      );
    }).toList();

    print('Sections count: ${sections.length}');

    setState(() {
      print('setState called');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building Widget');
    return Scaffold(
      appBar: AppBar(title: Text('Timetable Analysis')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedDay,
            items: <String>['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  selectedDay = newValue;
                  updateSectionsForDay(newValue); // Update sections when a new day is selected
                });
              }
            },
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                // Configure the rest of your chart styling as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
