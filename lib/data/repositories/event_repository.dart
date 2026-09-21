import 'package:drift/drift.dart';

import '../../domain/models.dart';
import '../../domain/repositories/event_repository.dart';
import '../local/app_database.dart';
import '../mappers/event_mapper.dart';

class DriftEventRepository implements EventRepository {
  DriftEventRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<Event>> watchAll() => (database.select(database.eventRows)
        ..where((row) => row.deletedAt.isNull()))
      .watch()
      .map((rows) => rows.map((row) => row.toDomain()).toList());

  @override
  Future<Event?> getById(String id) async {
    final row = await (database.select(database.eventRows)
          ..where((event) => event.id.equals(id) & event.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<void> save(Event event) => database
      .into(database.eventRows)
      .insertOnConflictUpdate(eventCompanion(event));

  @override
  Future<void> delete(String id, DateTime deletedAt) =>
      (database.update(database.eventRows)
            ..where((event) => event.id.equals(id)))
          .write(EventRowsCompanion(
              deletedAt: Value(deletedAt), updatedAt: Value(deletedAt)));
}
