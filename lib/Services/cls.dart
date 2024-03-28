import 'package:flutter/material.dart';

class TimetableData with ChangeNotifier {
  String specialtyId = '';
    String sectionId = '';
      String niveau = '';



  void setSpecialtyId(String id) {
    specialtyId = id;
    notifyListeners();
  }

void setNiveau(String value) {
    niveau = value;
    notifyListeners();
  }

    void setSectionId(String id) {
    sectionId = id;
    notifyListeners();
  }

  // يمكن إضافة المزيد من الوظائف حسب الحاجة
}
