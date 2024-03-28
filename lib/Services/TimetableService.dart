import 'dart:convert';
import 'package:dio/dio.dart';
import 'TimetableEntry.dart'; // Update the import path







class TimetableService {
  final Dio _dio = Dio();

  Future<List<TimetableEntry>> fetchTimetable(String specialtyId, String levelId, String sectionId) async {
    // Include the levelId in the request URL
    String requestUrl = 'https://num.univ-biskra.dz/psp/emploi/section2_public?select_spec=$specialtyId&niveau=$levelId&section=$sectionId&groupe=null&sg=0&langu=fr&sem=2&id_year=2';
    
    // Log the request URL for debugging
    print('Requesting Timetable with URL: $requestUrl');

    try {
      final response = await _dio.get(requestUrl);

      // Log the raw response for debugging
      print('Response: ${response.data}');

      final List<dynamic> data = json.decode(response.data);
      return data.map((entry) => TimetableEntry.fromJson(entry)).toList();
    } catch (e) {
      print('Error fetching timetable: $e');
      return [];
    }
  }
}
