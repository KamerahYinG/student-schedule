import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';
import 'course_import.dart';

class WeekPage extends ConsumerWidget {
  const WeekPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final categories = ref.watch(categoriesProvider);
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('无法加载日程：$error')),
      data: (items) => categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('无法加载分类：$error')),
        data: (values) => _WeekCalendar(
          events: items,
          categories: {for (final value in values) value.id: value},
        ),
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({required this.events, required this.categories});
  final List<Event> events;
  final Map<String, Category> categories;

  @override
  Widget build(BuildContext context) {
    final monday = _monday(DateTime.now());
    final days = List.generate(7, (index) => monday.add(Duration(days: index)));
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 700) {
        return Center(
            child: FilledButton.icon(
                onPressed: () => _showImport(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Import Courses')));
      }
      return Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(children: [
              Text('Week of ${_dateLabel(monday)}',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilledButton.icon(
                  onPressed: () => _showImport(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import Courses')),
            ])),
        _DayHeader(days: days),
        Expanded(
            child: _Grid(days: days, events: events, categories: categories)),
      ]);
    });
  }

  Future<void> _showImport(BuildContext context) async {
    await showDialog<void>(
        context: context, builder: (_) => const CourseImportDialog());
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.days});
  final List<DateTime> days;
  @override
  Widget build(BuildContext context) => Row(children: [
        const SizedBox(width: 64),
        ...days.map((day) => Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('${_weekday(day.weekday)}\n${day.day}',
                  textAlign: TextAlign.center),
            ))),
      ]);
}

class _Grid extends StatelessWidget {
  const _Grid(
      {required this.days, required this.events, required this.categories});
  final List<DateTime> days;
  final List<Event> events;
  final Map<String, Category> categories;
  @override
  Widget build(BuildContext context) {
    const startHour = 8;
    const endHour = 22;
    const hourHeight = 64.0;
    final today = DateTime.now();
    return SingleChildScrollView(
        child: SizedBox(
            height: (endHour - startHour) * hourHeight,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                  width: 64,
                  child: Column(
                      children: List.generate(
                          endHour - startHour,
                          (index) => SizedBox(
                              height: hourHeight,
                              child: Text(
                                  '${(startHour + index).toString().padLeft(2, '0')}:00',
                                  textAlign: TextAlign.right))))),
              ...days.map((day) {
                final dayEvents = events
                    .where((event) => _sameDate(event.startAt, day))
                    .toList();
                return Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      color: _sameDate(day, today)
                          ? Colors.indigo.withOpacity(.035)
                          : null,
                      border: Border(
                          left: BorderSide(color: Colors.grey.shade200))),
                  child: Stack(children: [
                    for (var hour = startHour; hour <= endHour; hour++)
                      Positioned(
                          top: (hour - startHour) * hourHeight,
                          left: 0,
                          right: 0,
                          child:
                              Divider(height: 1, color: Colors.grey.shade200)),
                    ..._eventCards(dayEvents, hourHeight, startHour),
                  ]),
                ));
              }),
            ])));
  }

  List<Widget> _eventCards(
          List<Event> events, double hourHeight, int startHour) =>
      events.map((event) {
        final top =
            (event.startAt.hour + event.startAt.minute / 60 - startHour) *
                hourHeight;
        final height =
            event.endAt.difference(event.startAt).inMinutes / 60 * hourHeight;
        final color = event.categoryId == null
            ? Colors.grey.shade200
            : Color(categories[event.categoryId]?.color ?? Colors.grey.value);
        return Positioned(
            top: top.clamp(0, double.infinity),
            left: 4,
            right: 4,
            height: height.clamp(28, double.infinity),
            child: Card(
                color: color,
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                        '${event.title}\n${_time(event.startAt)}–${_time(event.endAt)}${event.location == null ? '' : '\n${event.location}'}',
                        overflow: TextOverflow.ellipsis))));
      }).toList();
}

class CourseImportDialog extends ConsumerStatefulWidget {
  const CourseImportDialog({super.key});
  @override
  ConsumerState<CourseImportDialog> createState() => _CourseImportDialogState();
}

class _CourseImportDialogState extends ConsumerState<CourseImportDialog> {
  final monday = TextEditingController(text: '2026-09-07');
  final csv = TextEditingController();
  CourseImportPlan? plan;
  String? error;
  @override
  void dispose() {
    monday.dispose();
    csv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Import Courses'),
        content: SizedBox(
            width: 620,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: monday,
                  decoration: const InputDecoration(
                      labelText: 'First Monday (YYYY-MM-DD)')),
              const SizedBox(height: 12),
              TextField(
                  controller: csv,
                  minLines: 7,
                  maxLines: 12,
                  decoration: const InputDecoration(
                      labelText: 'CSV',
                      hintText:
                          'title,weekday,startTime,endTime,startWeek,endWeek,location,category')),
              if (error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              if (plan != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        '解析到 ${plan!.courses.length} 门课程，将生成 ${plan!.events.length} 个 Event')),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(onPressed: _preview, child: const Text('Preview')),
          FilledButton(
              onPressed: plan == null ? null : _import,
              child: const Text('Import')),
        ],
      );
  void _preview() {
    try {
      setState(() {
        plan = parseCourseCsv(firstMondayText: monday.text, csv: csv.text);
        error = null;
      });
    } on CourseImportException catch (e) {
      setState(() {
        error = e.message;
        plan = null;
      });
    }
  }

  Future<void> _import() async {
    final current = plan!;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final eventRepo = ref.read(eventRepositoryProvider);
    final existing = await categoryRepo.watchAll().first;
    final categories = {
      for (final category in existing) category.name: category.id
    };
    for (final course in current.courses) {
      final name = course.category;
      if (name == null || categories.containsKey(name)) continue;
      final now = DateTime.now();
      final id = 'category-${now.microsecondsSinceEpoch}-${categories.length}';
      await categoryRepo.save(Category(
          id: id,
          name: name,
          color: Colors.indigo.value,
          sortOrder: categories.length.toDouble(),
          createdAt: now,
          updatedAt: now));
      categories[name] = id;
    }
    for (var index = 0; index < current.events.length; index++) {
      final categoryName = current.eventCategoryNames[index];
      await eventRepo.save(current.events[index].copyWith(
        categoryId: categoryName == null ? null : categories[categoryName],
      ));
    }
    if (mounted) Navigator.pop(context);
  }
}

DateTime _monday(DateTime date) =>
    DateTime(date.year, date.month, date.day - (date.weekday - 1));
bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
String _dateLabel(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
String _time(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String _weekday(int day) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
