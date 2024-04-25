import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class TimetableData with ChangeNotifier {
   // Define keys as static const to avoid mismatches
   static const keySpecialtyId = 'id_specialty';
  static const keyLevelId = 'id_niv_spec';
  static const keySectionId = 'sectionn_id';
  static const keyGroupId = 'groupe_id';

  String facultyId = '';
  String departmentId = '';
  String specialtyId = '';
  String levelId = '';
  String sectionId = '';
  String? groupId;

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySpecialtyId, specialtyId);
    await prefs.setString(keyLevelId, levelId);
    await prefs.setString(keySectionId, sectionId);
    if (groupId != null) {
      await prefs.setString(keyGroupId, groupId!);
    }
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    specialtyId = prefs.getString(keySpecialtyId) ?? '';
    levelId = prefs.getString(keyLevelId) ?? '';
    sectionId = prefs.getString(keySectionId) ?? '';
    groupId = prefs.getString(keyGroupId);
    notifyListeners();
  }

  void setGroupId(String? id) {
    groupId = id;
    notifyListeners();
    savePreferences();
  }
  void setFacultyId(String id) {
    facultyId = id;
    notifyListeners();
    savePreferences();
  }

  void setDepartmentId(String id) {
    departmentId = id;
    notifyListeners();
    savePreferences();
  }

  void setSpecialtyId(String id) {
    specialtyId = id;
    notifyListeners();
    savePreferences();
  }

  void setLevelId(String id) {
    levelId = id;
    notifyListeners();
    savePreferences();
  }

  void setSectionId(String id) {
    sectionId = id;
    notifyListeners();
    savePreferences();
  }
 

  bool get isSetupComplete {
  return facultyId.isNotEmpty && 
         departmentId.isNotEmpty &&
         specialtyId.isNotEmpty && 
         levelId.isNotEmpty && 
         sectionId.isNotEmpty &&
         (groupId?.isNotEmpty ?? false); // Safe check for non-null and non-empty
}
}
