import '../models.dart';

abstract interface class EventRepository {
  Stream<List<Event>> watchAll();
  Future<Event?> getById(String id);
  Future<void> save(Event event);
  Future<void> delete(String id, DateTime deletedAt);
}
