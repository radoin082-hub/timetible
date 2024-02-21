
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:timo/d.dart';

class TimetableService {
  final Dio _dio = Dio();

  Future<List<TimetableEntry>> fetchTimetable() async {
    try {
      final response = await _dio.get('https://num.univ-biskra.dz/psp/emploi/section2_public?select_spec=109&niveau=3&section=521&groupe=null&sg=0&langu=fr&sem=2&id_year=2');
      final List<dynamic> data = json.decode(response.data); // Assuming the response is properly formatted JSON.
      List<TimetableEntry> entries = data.map((entry) => TimetableEntry.fromJson(entry)).toList();

      // Sort entries by dayOfWeek and then by timeSlot
      entries.sort((a, b) {
        int compareDay = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (compareDay == 0) {
          return a.timeSlot.compareTo(b.timeSlot);
        }
        return compareDay;
      });

      return entries;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
