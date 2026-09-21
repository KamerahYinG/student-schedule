import 'package:flutter_test/flutter_test.dart';
import 'package:student_schedule/data/local/app_database.dart';
import 'package:student_schedule/data/repositories/event_repository.dart';
import 'package:student_schedule/features/week/course_import.dart';
import 'package:drift/native.dart';

const csv =
    '''title,weekday,startTime,endTime,startWeek,endWeek,location,category
高等数学,1,08:00,09:40,1,2,A301,Course
大学物理,2,10:00,11:40,1,1,B204,Course''';

void main() {
  test('parses CSV and expands inclusive weeks and weekdays', () {
    final plan = parseCourseCsv(
        firstMondayText: '2026-09-07', csv: csv, now: DateTime(2026));
    expect(plan.courses.length, 2);
    expect(plan.events.length, 3);
    expect(plan.events[0].startAt, DateTime(2026, 9, 7, 8));
    expect(plan.events[1].startAt, DateTime(2026, 9, 14, 8));
    expect(plan.events[2].startAt, DateTime(2026, 9, 8, 10));
  });

  test('rejects invalid weekday, time and week range', () {
    expect(
        () => parseCourseCsv(
            firstMondayText: '2026-09-07',
            csv: csv.replaceFirst(',1,08', ',8,08')),
        throwsA(isA<CourseImportException>()));
    expect(
        () => parseCourseCsv(
            firstMondayText: '2026-09-07',
            csv: csv.replaceFirst('08:00', '25:00')),
        throwsA(isA<CourseImportException>()));
    expect(
        () => parseCourseCsv(
            firstMondayText: '2026-09-07',
            csv: csv.replaceFirst(',1,2,A301', ',2,1,A301')),
        throwsA(isA<CourseImportException>()));
  });

  test('expanded events can be stored and read from repository', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = DriftEventRepository(database);
    final plan = parseCourseCsv(
        firstMondayText: '2026-09-07', csv: csv, now: DateTime(2026));
    for (final event in plan.events) await repository.save(event);
    expect((await repository.watchAll().first).length, 3);
    await database.close();
  });
}
