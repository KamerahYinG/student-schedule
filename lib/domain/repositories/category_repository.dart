import '../models.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();
  Future<Category?> getById(String id);
  Future<void> save(Category category);
  Future<void> delete(String id, DateTime deletedAt);
}
