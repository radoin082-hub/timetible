class offEntry {
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

  offEntry({
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

  factory offEntry.fromJson(Map<String, dynamic> json) {
    return offEntry(
      className: json['className'],
      location: json['location'],
      courseType: json['courseType'],
      level: json['level'],
      field: json['field'],
      professorLastName: json['professorLastName'],
      professorFirstName: json['professorFirstName'],
      moduleCode: json['moduleCode'],
      dayOfWeek: json['dayOfWeek'],
      timeSlot: json['timeSlot'],
      subGroup: json['subGroup'],
      isOnline: json['isOnline'].toString() == "1",
      isBiweekly: json['isBiweekly'].toString() == "1",
      onlineLink: json['onlineLink'],
      gpsLocation: json['gpsLocation'],
    );
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
  
  String formatTime(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
  }
   String get dayName {
    List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayOfWeek >= 1 && dayOfWeek <= 7 ? days[dayOfWeek - 1] : 'Unknown';
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

}
