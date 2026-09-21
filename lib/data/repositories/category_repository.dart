import 'package:drift/drift.dart';

import '../../domain/models.dart';
import '../../domain/repositories/category_repository.dart';
import '../local/app_database.dart';
import '../mappers/category_mapper.dart';

class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<Category>> watchAll() => (database.select(database.categoryRows)
        ..where((row) => row.deletedAt.isNull()))
      .watch()
      .map((rows) => rows.map((row) => row.toDomain()).toList());

  @override
  Future<Category?> getById(String id) async {
    final row = await (database.select(database.categoryRows)
          ..where((category) =>
              category.id.equals(id) & category.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<void> save(Category category) => database
      .into(database.categoryRows)
      .insertOnConflictUpdate(categoryCompanion(category));

  @override
  Future<void> delete(String id, DateTime deletedAt) =>
      (database.update(database.categoryRows)
            ..where((category) => category.id.equals(id)))
          .write(CategoryRowsCompanion(
              deletedAt: Value(deletedAt), updatedAt: Value(deletedAt)));
}
