import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/event_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/event_repository.dart';
import '../domain/models.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final eventRepositoryProvider = Provider<EventRepository>(
    (ref) => DriftEventRepository(ref.watch(databaseProvider)));

final categoryRepositoryProvider = Provider<CategoryRepository>(
    (ref) => DriftCategoryRepository(ref.watch(databaseProvider)));

final eventsProvider = StreamProvider<List<Event>>(
    (ref) => ref.watch(eventRepositoryProvider).watchAll());

final categoriesProvider = StreamProvider<List<Category>>(
    (ref) => ref.watch(categoryRepositoryProvider).watchAll());
