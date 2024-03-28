class TimetableEntry {
  String className;
  String location;
  String courseType;
  String level;
  String field;
  String professorLastName;
  String professorFirstName;
  String moduleCode;
  int dayOfWeek;
  int timeSlot;
  String subGroup;
  bool isOnline;
  bool isBiweekly;
  String onlineLink;
  String gpsLocation;

  TimetableEntry({
    required this.className,
    required this.location,
    required this.courseType,
    required this.level,
    required this.field,
    required this.professorLastName,
    required this.professorFirstName,
    required this.moduleCode,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.subGroup,
    required this.isOnline,
    required this.isBiweekly,
    required this.onlineLink,
    required this.gpsLocation,
  });

factory TimetableEntry.fromJson(List<dynamic> json) {
  return TimetableEntry(
    className: json[0] as String,
    location: json[1] as String,
    courseType: json[2] as String,
    level: json[3] as String,
    field: json[4] as String,
    professorLastName: json[5] as String,
    professorFirstName: json[6] as String,
    moduleCode: json[8] as String,
    dayOfWeek: int.tryParse(json[12].toString()) ?? 0,
    timeSlot: int.tryParse(json[13].toString()) ?? 0,
    subGroup: json.length > 20 ? json[20] as String : "",
    isOnline: json[19] == "1",
    isBiweekly: json[20] == "1",
    onlineLink: json.length > 21 ? json[21] as String : "",
    gpsLocation: json.length > 22 ? json[22] as String : "",
  );
}


  // Getter for dayName based on dayOfWeek
  String get dayName {
    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayOfWeek >= 1 && dayOfWeek <= days.length ? days[dayOfWeek - 1] : 'Unknown';
  }

  // Getter for classTime based on timeSlot
  String get classTime {
    // Assuming each time slot is 1 hour and starts at 8:00 AM
    DateTime startTime = DateTime(2024, 1, 1, 8 + timeSlot - 1); // Adjust the base time as needed
    DateTime endTime = startTime.add(Duration(hours: 1)); // Adjust duration as needed

    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  // Helper method to format time
  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
