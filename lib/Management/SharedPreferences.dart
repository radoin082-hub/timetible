
import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:timo/Services/TimetableEntry.dart';

class PreferencesManager {
  static SharedPreferences? _prefs;

 

static Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> isFirstLoad() async {
    return _prefs?.getBool('firstLoad') ?? true;
  }

  static Future<void> setFirstLoadComplete() async {
    await _prefs?.setBool('firstLoad', false);
  }
void saveTimetableData(List<TimetableEntry> entries) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // تحويل كل المدخلات إلى نص JSON وحفظها
  String encodedData = jsonEncode(entries.map((e) => e.toJson()).toList());
  await prefs.setString('timetableData', encodedData);
}


  static Future<void> saveFacultyId(String facultyId) async {
    await _prefs?.setString('facultyId', facultyId);
  }
  static String? getFacultyId() {
    return _prefs?.getString('facultyId');
  }
  

    static Future<void> saveGroupId(String groupId) async {
    await _prefs?.setString('groupId', groupId);
  }
  static String? getGroupId() {
    return _prefs?.getString('groupId');
  }
  
  
}
