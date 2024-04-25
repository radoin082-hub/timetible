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
  String gpsLocation; // Add this line

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
    required this.gpsLocation, // Add this
  });

  factory TimetableEntry.fromJson(List<dynamic> json) {
    return TimetableEntry(
      className: json[0],
      location: json[1],
      courseType: json[2],
      level: json[3],
      field: json[4],
      professorLastName: json[5],
      professorFirstName: json[6],
      moduleCode: json[8],
      dayOfWeek: int.tryParse(json[12]) ?? 0,
      timeSlot: int.tryParse(json[13]) ?? 0,
      subGroup: json.length > 20 ? json[20] : "",
      isOnline: json[19] == "1",
      isBiweekly: json[20] == "1",
      onlineLink: json.length > 21 ? json[21] : "",
      gpsLocation: json.length > 22 ? json[22] : "", // Add this
    );
  }


String get dayName {
    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayOfWeek >= 1 && dayOfWeek <= days.length ? days[dayOfWeek - 1] : 'Unknown';
  }
String get classTime {
    DateTime startTime = DateTime(2024, 1, 1, 8, 0); // Base start time for slot 1
    final int slotDurationMinutes = 90; // Duration of each slot
    final int breakDurationMinutes = 10; // Duration of breaks between slots

    // Calculate the start time for the given slot
    DateTime slotStartTime = startTime.add(Duration(
      minutes: ((timeSlot - 1) * (slotDurationMinutes + breakDurationMinutes)),
    ));

    // Calculate the end time by adding the slot duration to the start time
    DateTime slotEndTime = slotStartTime.add(Duration(minutes: slotDurationMinutes));

    // Format times to string
    return '${formatTime(slotStartTime)} - ${formatTime(slotEndTime)}';
  }

  // Helper function to format DateTime objects to time strings
  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

}
