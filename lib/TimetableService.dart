import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TimetableEntry.dart'; // Ensure this path is correct

class TimetableService {
  final Dio _dio = Dio();

  Future<List<TimetableEntry>> fetchTimetable(String specialtyId, String levelId, String sectionId) async {
    final String requestUrl = 'https://num.univ-biskra.dz/psp/emploi/section2_public?select_spec=$specialtyId&niveau=$levelId&section=$sectionId&groupe=null&sg=0&langu=fr&sem=2&id_year=2';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await _dio.get(requestUrl);
      if (response.statusCode == 200) {
        // Save the JSON data as a string
        await prefs.setString('timetableData', json.encode(response.data)); // Make sure to encode the data to a string
        return _parseTimetableData(json.encode(response.data)); // Parse the data after encoding it
      } else {
        throw Exception('Failed to fetch data from server');
      }
    } catch (e) {
      print('Error fetching timetable: $e');
      String? cachedData = prefs.getString('timetableData');
      if (cachedData != null) {
        return _parseTimetableData(cachedData); // Parse the cached data
      } else {
        // No cached data available, handle accordingly
        return [];
      }
    }
  }

  List<TimetableEntry> _parseTimetableData(String data) {
    final List<dynamic> jsonData = json.decode(data); // Decode the string back into JSON
    return jsonData.map<TimetableEntry>((json) => TimetableEntry.fromJson(json as List<dynamic>)).toList(); // Parse into TimetableEntry objects
  }
}
