import 'package:drift/drift.dart';

import '../../domain/models.dart';
import '../local/app_database.dart';

extension EventRowMapper on EventRow {
  Event toDomain() => Event(
        id: id,
        title: title,
        notes: notes,
        projectId: projectId,
        categoryId: categoryId,
        startAt: startAt,
        endAt: endAt,
        location: location,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}

EventRowsCompanion eventCompanion(Event event) => EventRowsCompanion.insert(
      id: event.id,
      title: event.title,
      notes: Value(event.notes),
      projectId: Value(event.projectId),
      categoryId: Value(event.categoryId),
      startAt: event.startAt,
      endAt: event.endAt,
      location: Value(event.location),
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      deletedAt: Value(event.deletedAt),
    );
