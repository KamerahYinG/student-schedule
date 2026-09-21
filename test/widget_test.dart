import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_schedule/app/providers.dart';
import 'package:student_schedule/app/app.dart';
import 'package:student_schedule/data/local/app_database.dart';

void main() {
  testWidgets('shows the Week section by default', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const StudentScheduleApp(),
    ));
    expect(find.text('Week'), findsWidgets);
    await database.close();
  });
}
