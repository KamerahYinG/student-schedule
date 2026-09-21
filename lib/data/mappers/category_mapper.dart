import 'package:drift/drift.dart';

import '../../domain/models.dart';
import '../local/app_database.dart';

extension CategoryRowMapper on CategoryRow {
  Category toDomain() => Category(
        id: id,
        name: name,
        color: color,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}

CategoryRowsCompanion categoryCompanion(Category category) =>
    CategoryRowsCompanion.insert(
      id: category.id,
      name: category.name,
      color: category.color,
      sortOrder: category.sortOrder,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      deletedAt: Value(category.deletedAt),
    );
