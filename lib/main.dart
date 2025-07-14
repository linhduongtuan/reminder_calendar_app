import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_reminder_screen.dart';
import 'models/reminder.dart';
import 'models/reminder_repository.dart';
import 'models/theme_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_helper.dart';
import 'package:hive/hive.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(RecurrenceTypeAdapter());
  Hive.registerAdapter(ReminderPriorityAdapter());
  Hive.registerAdapter(SubtaskAdapter());
  Hive.registerAdapter(ReminderLocationAdapter());
  await ReminderRepository.init();
  await NotificationHelper.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ReminderApp(),
    ),
  );
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Reminder Calendar',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: themeProvider.materialThemeMode,
      home: const HomeScreen(),
      routes: {
        '/add': (context) => const AddEditReminderScreen(),
        '/edit': (context) {
          final reminder = ModalRoute.of(context)!.settings.arguments as Reminder?;
          return AddEditReminderScreen(reminder: reminder);
        },
      },
    );
  }
}

