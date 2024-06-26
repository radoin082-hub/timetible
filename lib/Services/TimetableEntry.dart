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

  String get dayName {
    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayOfWeek >= 1 && dayOfWeek <= 7 ? days[dayOfWeek - 1] : 'Week-end';
  }

  String get classTime {
    List<Duration> startTimes = [
      Duration(hours: 8, minutes: 0),
      Duration(hours: 9, minutes: 40),
      Duration(hours: 11, minutes: 20),
      Duration(hours: 13, minutes: 10),
      Duration(hours: 14, minutes: 50),
      Duration(hours: 16, minutes: 30)
    ];

    List<Duration> endTimes = [
      Duration(hours: 9, minutes: 30),
      Duration(hours: 11, minutes: 10),
      Duration(hours: 12, minutes: 50),
      Duration(hours: 14, minutes: 40),
      Duration(hours: 16, minutes: 20),
      Duration(hours: 18, minutes: 0)
    ];

    if (timeSlot >= 1 && timeSlot <= startTimes.length) {
      var startTime = startTimes[timeSlot - 1];
      var endTime = endTimes[timeSlot - 1];
      return '${formatTime(startTime)} - ${formatTime(endTime)}';
    } else {
      return 'Unknown time';
    }
  }
  
Map<String, String> getSlotTime() {
    Map<int, List<String>> slotTimes = {
      1: ['08:00', '09:30'],
      2: ['09:40', '11:10'],
      3: ['11:20', '12:50'],
      4: ['13:10', '14:40'],
      5: ['14:50', '16:20'],
      6: ['16:30', '18:00'],
    };
    var times = slotTimes[timeSlot];
    return {
      'start': times![0],
      'end': times[1],
    };
  }

  
  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'location': location,
      'courseType': courseType,
      'level': level,
      'field': field,
      'professorLastName': professorLastName,
      'professorFirstName': professorFirstName,
      'moduleCode': moduleCode,
      'dayOfWeek': dayOfWeek,
      'timeSlot': timeSlot,
      'subGroup': subGroup,
      'isOnline': isOnline ? '1' : '0',
      'isBiweekly': isBiweekly ? '1' : '0',
      'onlineLink': onlineLink,
      'gpsLocation': gpsLocation,
    };
  }
}

  String formatTime(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
  }
  
