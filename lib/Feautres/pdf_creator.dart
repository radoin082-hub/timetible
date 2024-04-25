import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:timo/Services/TimetableEntry.dart';

class PdfCreator {
  Future<void> createAndSavePdfTimetable(List<TimetableEntry> entries) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load("fonts/noto.ttf")); // Load the font

    // Sort entries by day and time for accurate layout
    entries.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek) != 0 ? a.dayOfWeek.compareTo(b.dayOfWeek) : a.timeSlot.compareTo(b.timeSlot));

    // Group entries by day
    final entriesByDay = <String, List<TimetableEntry>>{};
    for (var entry in entries) {
      (entriesByDay[entry.dayName] ??= []).add(entry);
    }

    // Extract unique time slots
    var timeSlots = entries.map((e) => e.getSlotTime()).toSet().toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Container(), // Empty top-left cell
                  ...timeSlots.map((slot) => 
                    pw.Center(child: pw.Text('${slot['start']} - ${slot['end']}', style: pw.TextStyle(font: font)))
                  ),
                ]
              ),
              ...entriesByDay.entries.map(
                (entry) => pw.TableRow(
                  children: [
                    pw.Center(child: pw.Text(entry.key, style: pw.TextStyle(font: font))),
                    ...timeSlots.map((slot) {
                      // Filter entries that fit this time slot
                      var relevantEntries = entry.value.where((e) => 
                        e.getSlotTime()['start'] == slot['start'] && e.getSlotTime()['end'] == slot['end']).toList();
                      return pw.Text(relevantEntries.map((e) => '${e.moduleCode}\n${e.location}').join('\n'), style: pw.TextStyle(font: font));
                    }),
                  ],
                )
              ),
            ],
          ),
        ],
      ),
    );

    // Ensure the permission to save the file
    if (await requestAllFilesAccessPermission()) {
      final directory = Directory("/storage/emulated/0/timo33");
      if (!directory.existsSync()) {
        directory.createSync(recursive: true); // Create the directory if it doesn't exist
      }
      final file = File('${directory.path}/timetable.pdf');
      await file.writeAsBytes(await pdf.save());
      print('PDF saved to ${file.path}');
    } else {
      print('Permission to write in storage denied');
    }
  }

  Future<bool> requestAllFilesAccessPermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }
}
