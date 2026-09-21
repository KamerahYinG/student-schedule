import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_schedule/data/local/app_database.dart';
import 'package:student_schedule/data/repositories/category_repository.dart';
import 'package:student_schedule/data/repositories/event_repository.dart';
import 'package:student_schedule/domain/models.dart';

void main() {
  late AppDatabase database;
  late DriftCategoryRepository categories;
  late DriftEventRepository events;
  final now = DateTime(2026, 10, 16, 12);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    categories = DriftCategoryRepository(database);
    events = DriftEventRepository(database);
  });

  tearDown(() => database.close());

  test('repositories create, update, get and soft delete', () async {
    final category = Category(
      id: 'cat',
      name: 'Course',
      color: 0xff336699,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
    await categories.save(category);
    expect((await categories.getById('cat'))?.name, 'Course');
    await categories.save(Category(
      id: category.id,
      name: 'Updated',
      color: category.color,
      sortOrder: category.sortOrder,
      createdAt: category.createdAt,
      updatedAt: now.add(const Duration(minutes: 1)),
    ));
    expect((await categories.getById('cat'))?.name, 'Updated');
    await categories.delete('cat', now.add(const Duration(minutes: 2)));
    expect(await categories.getById('cat'), isNull);

    final event = Event(
      id: 'event',
      title: 'Lecture',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      createdAt: now,
      updatedAt: now,
    );
    await events.save(event);
    expect((await events.getById('event'))?.title, 'Lecture');
    await events.delete('event', now.add(const Duration(minutes: 2)));
    expect(await events.getById('event'), isNull);
  });

  test('watch streams exclude soft-deleted rows', () async {
    final stream = events.watchAll();
    await events.save(Event(
      id: 'event',
      title: 'Lecture',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      createdAt: now,
      updatedAt: now,
    ));
    expect((await stream.first).map((event) => event.id), contains('event'));
    await events.delete('event', now);
    expect(await stream.first, isEmpty);
  });
}
