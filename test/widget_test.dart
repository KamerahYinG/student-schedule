import 'package:flutter_test/flutter_test.dart';

import 'package:student_schedule/app/app.dart';

void main() {
  testWidgets('shows the Week section by default', (tester) async {
    await tester.pumpWidget(const StudentScheduleApp());
    expect(find.text('Week'), findsOneWidget);
  });
}
