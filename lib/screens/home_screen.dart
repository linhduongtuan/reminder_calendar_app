import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import '../utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/reminder.dart';
import '../models/reminder_repository.dart';
import '../notification_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _showCompleted = true;
  String? _selectedTag;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Reminder> _reminders = [];
  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _reminders = ReminderRepository.getAll();
    });
  }

  List<Reminder> get _remindersForSelectedDay {
    if (_selectedDay == null) return _reminders;
    return _reminders.where((r) {
      if (!_showCompleted && r.isCompleted) return false;
      if (_searchQuery.isNotEmpty &&
          !r.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !r.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedTag != null && _selectedTag!.isNotEmpty && !(r.tags.contains(_selectedTag!))) {
        return false;
      }
      if (isSameDay(r.dateTime, _selectedDay!)) return true;
      switch (r.recurrenceType) {
        case RecurrenceType.daily:
          return r.dateTime.isBefore(_selectedDay!);
        case RecurrenceType.weekly:
          return r.dateTime.isBefore(_selectedDay!) && r.dateTime.weekday == _selectedDay!.weekday;
        case RecurrenceType.monthly:
          return r.dateTime.isBefore(_selectedDay!) && r.dateTime.day == _selectedDay!.day;
        case RecurrenceType.custom:
          // TODO: Parse and match custom rule (e.g., RRULE)
          return false;
        case RecurrenceType.none:
        default:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = _reminders.expand((r) => r.tags).toSet().toList()..sort();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.color_lens),
            tooltip: 'Theme',
            onSelected: (value) {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              switch (value) {
                case 0:
                  themeProvider.setTheme(AppThemeMode.system);
                  break;
                case 1:
                  themeProvider.setTheme(AppThemeMode.light);
                  break;
                case 2:
                  themeProvider.setTheme(AppThemeMode.dark);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('System Theme')),
              const PopupMenuItem(value: 1, child: Text('Light Theme')),
              const PopupMenuItem(value: 2, child: Text('Dark Theme')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search reminders',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _showCompleted,
                      onChanged: (val) {
                        setState(() {
                          _showCompleted = val ?? true;
                        });
                      },
                    ),
                    const Text('Show completed'),
                  ],
                ),
              ],
            ),
          ),
          if (allTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: const InputDecoration(labelText: 'Filter by Tag'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...allTags.map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                ],
                onChanged: (tag) {
                  setState(() {
                    _selectedTag = tag;
                  });
                },
              ),
            ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _remindersForSelectedDay.isEmpty
                ? const Center(child: Text('No reminders for this day.'))
                : ListView.builder(
                    itemCount: _remindersForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final reminder = _remindersForSelectedDay[index];
                      Color? priorityColor;
                      IconData? priorityIcon;
                      switch (reminder.priority) {
                        case ReminderPriority.high:
                          priorityColor = Colors.red;
                          priorityIcon = Icons.priority_high;
                          break;
                        case ReminderPriority.medium:
                          priorityColor = Colors.orange;
                          priorityIcon = Icons.flag;
                          break;
                        case ReminderPriority.low:
                          priorityColor = Colors.green;
                          priorityIcon = Icons.low_priority;
                          break;
                      }
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: reminder.isCompleted,
                              onChanged: (val) async {
                                final key = reminder.key as int?;
                                if (key != null) {
                                  final updated = reminder.copyWith(isCompleted: val ?? false);
                                  await ReminderRepository.update(key, updated);
                                  setState(() {
                                    _reminders[_reminders.indexWhere((r) => r.key == key)] = updated;
                                  });
                                }
                              },
                            ),
                            Icon(priorityIcon, color: priorityColor),
                          ],
                        ),
                        title: Text(
                          reminder.title,
                          style: reminder.isCompleted
                              ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                              : null,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarkdownBody(
                              data: reminder.description,
                              shrinkWrap: true,
                              styleSheet: MarkdownStyleSheet(
                                p: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            if (reminder.tags.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: reminder.tags.map((tag) => Chip(label: Text(tag), visualDensity: VisualDensity.compact)).toList(),
                              ),
                            if (reminder.attachments.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Wrap(
                                  spacing: 6,
                                  children: reminder.attachments.map((path) {
                                    final isImage = path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.gif');
                                    if (isImage) {
                                      return SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Image.file(
                                          File(path),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                        ),
                                      );
                                    } else {
                                      return Chip(
                                        avatar: const Icon(Icons.attach_file, size: 18),
                                        label: Text(path.split('/').last, overflow: TextOverflow.ellipsis),
                                        visualDensity: VisualDensity.compact,
                                      );
                                    }
                                  }).toList(),
                                ),
                              ),
                            if (reminder.subtasks.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: reminder.subtasks.map((sub) => Row(
                                    children: [
                                      Checkbox(
                                        value: sub.isCompleted,
                                        onChanged: null,
                                      ),
                                      Expanded(
                                        child: Text(
                                          sub.title,
                                          style: sub.isCompleted
                                              ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          '${reminder.dateTime.hour.toString().padLeft(2, '0')}:${reminder.dateTime.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () async {
                          final edited = await Navigator.of(context).pushNamed(
                            '/edit',
                            arguments: reminder,
                          ) as Reminder?;
                          if (edited != null) {
                            // Update in Hive
                            final key = reminder.key as int?;
                            if (key != null) {
                              await ReminderRepository.update(key, edited);
                              await NotificationHelper.scheduleReminder(edited);
                              await _loadReminders();
                            }
                          }
                        },
                        onLongPress: () async {
                          final key = reminder.key as int?;
                          if (key != null) {
                            await ReminderRepository.delete(key);
                            await NotificationHelper.cancelReminder(reminder);
                            await _loadReminders();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newReminder = await Navigator.of(context).pushNamed('/add') as Reminder?;
          if (newReminder != null) {
            await ReminderRepository.add(newReminder);
            await NotificationHelper.scheduleReminder(newReminder);
            await _loadReminders();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
