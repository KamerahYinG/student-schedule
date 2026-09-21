import 'package:drift/drift.dart';

class TaskRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get projectId => text().nullable()();
  TextColumn get parentTaskId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get status => integer()();
  BoolColumn get isInbox => boolean()();
  IntColumn get dueKind => integer()();
  TextColumn get dueDate => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  IntColumn get estimateMinutes => integer().nullable()();
  RealColumn get sortOrder => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
