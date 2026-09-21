import '../../domain/models.dart';

class CourseImportException implements Exception {
  const CourseImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseDefinition {
  const CourseDefinition({
    required this.title,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.startWeek,
    required this.endWeek,
    this.location,
    this.category,
  });

  final String title;
  final int weekday;
  final TimeOfDayValue startTime;
  final TimeOfDayValue endTime;
  final int startWeek;
  final int endWeek;
  final String? location;
  final String? category;
}

class TimeOfDayValue {
  const TimeOfDayValue(this.hour, this.minute);

  final int hour;
  final int minute;
}

class CourseImportPlan {
  const CourseImportPlan(this.courses, this.events, this.eventCategoryNames);

  final List<CourseDefinition> courses;
  final List<Event> events;
  final List<String?> eventCategoryNames;
}

CourseImportPlan parseCourseCsv({
  required String firstMondayText,
  required String csv,
  DateTime? now,
}) {
  final monday = _parseMonday(firstMondayText);
  final lines = csv.split(RegExp(r'\r?\n'));
  if (lines.isEmpty ||
      lines.first.trim().toLowerCase() !=
          'title,weekday,starttime,endtime,startweek,endweek,location,category') {
    throw const CourseImportException('CSV 第一行必须是指定 header');
  }
  final courses = <CourseDefinition>[];
  for (var index = 1; index < lines.length; index++) {
    final line = lines[index].trim();
    if (line.isEmpty) continue;
    final fields = line.split(',').map((field) => field.trim()).toList();
    if (fields.length != 8) {
      throw CourseImportException('第 ${index + 1} 行字段数量无效');
    }
    final weekday = _parseInt(fields[1], 'weekday', index + 1);
    if (weekday < 1 || weekday > 7) {
      throw CourseImportException('第 ${index + 1} 行 weekday 无效');
    }
    final startTime = _parseTime(fields[2], index + 1);
    final endTime = _parseTime(fields[3], index + 1);
    final startWeek = _parseInt(fields[4], 'startWeek', index + 1);
    final endWeek = _parseInt(fields[5], 'endWeek', index + 1);
    if (startWeek < 1 || endWeek < 1 || startWeek > endWeek) {
      throw CourseImportException('第 ${index + 1} 行周次无效');
    }
    final course = CourseDefinition(
      title: fields[0],
      weekday: weekday,
      startTime: startTime,
      endTime: endTime,
      startWeek: startWeek,
      endWeek: endWeek,
      location: fields[6].isEmpty ? null : fields[6],
      category: fields[7].isEmpty ? null : fields[7],
    );
    courses.add(course);
  }
  final timestamp = now ?? DateTime.now();
  final events = <Event>[];
  final eventCategoryNames = <String?>[];
  for (var courseIndex = 0; courseIndex < courses.length; courseIndex++) {
    final course = courses[courseIndex];
    for (var week = course.startWeek; week <= course.endWeek; week++) {
      final date =
          monday.add(Duration(days: (week - 1) * 7 + course.weekday - 1));
      final start = DateTime(date.year, date.month, date.day,
          course.startTime.hour, course.startTime.minute);
      final end = DateTime(date.year, date.month, date.day, course.endTime.hour,
          course.endTime.minute);
      if (!end.isAfter(start)) {
        throw CourseImportException('第 ${courseIndex + 2} 行结束时间必须晚于开始时间');
      }
      events.add(Event(
        id: 'course-${timestamp.microsecondsSinceEpoch}-$courseIndex-$week',
        title: course.title,
        location: course.location,
        startAt: start,
        endAt: end,
        createdAt: timestamp,
        updatedAt: timestamp,
      ));
      eventCategoryNames.add(course.category);
    }
  }
  return CourseImportPlan(courses, events, eventCategoryNames);
}

DateTime _parseMonday(String text) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text.trim());
  if (match == null) throw const CourseImportException('第一周周一必须是 YYYY-MM-DD');
  final date = DateTime(int.parse(match.group(1)!), int.parse(match.group(2)!),
      int.parse(match.group(3)!));
  if (date.weekday != DateTime.monday ||
      date.year != int.parse(match.group(1)!) ||
      date.month != int.parse(match.group(2)!) ||
      date.day != int.parse(match.group(3)!)) {
    throw const CourseImportException('第一周日期必须是有效的周一');
  }
  return date;
}

int _parseInt(String text, String name, int line) {
  final value = int.tryParse(text);
  if (value == null) throw CourseImportException('第 $line 行 $name 无效');
  return value;
}

TimeOfDayValue _parseTime(String text, int line) {
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(text);
  final hour = match == null ? null : int.tryParse(match.group(1)!);
  final minute = match == null ? null : int.tryParse(match.group(2)!);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    throw CourseImportException('第 $line 行时间格式错误');
  }
  return TimeOfDayValue(hour, minute);
}
