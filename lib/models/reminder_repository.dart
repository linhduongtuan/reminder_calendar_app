import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/reminder.dart';

class ReminderRepository {
  static const String boxName = 'reminders';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReminderAdapter());
    }
    await Hive.openBox<Reminder>(boxName);
  }

  static Box<Reminder> get _box => Hive.box<Reminder>(boxName);

  static List<Reminder> getAll() => _box.values.toList();

  static Future<void> add(Reminder reminder) async {
    await _box.add(reminder);
  }

  static Future<void> update(int key, Reminder reminder) async {
    await _box.put(key, reminder);
  }

  static Future<void> delete(int key) async {
    await _box.delete(key);
  }
}
