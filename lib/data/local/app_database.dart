import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/category_table.dart';
import 'tables/event_table.dart';
import 'tables/task_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [EventRows, CategoryRows, TaskRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'student_schedule'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) await m.createTable(taskRows);
        },
      );
}
