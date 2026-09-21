import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_shell.dart';

class StudentScheduleApp extends StatelessWidget {
  const StudentScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        title: 'Student Schedule',
        home: AppShell(),
      ),
    );
  }
}
