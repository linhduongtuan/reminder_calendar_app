import 'package:hive/hive.dart';
part 'reminder.g.dart';

@HiveType(typeId: 4)
class ReminderLocation {
  @HiveField(0)
  double latitude;
  @HiveField(1)
  double longitude;
  @HiveField(2)
  double radius;
  @HiveField(3)
  String? placeName;

  ReminderLocation({
    required this.latitude,
    required this.longitude,
    this.radius = 100,
    this.placeName,
  });

  ReminderLocation copyWith({double? latitude, double? longitude, double? radius, String? placeName}) {
    return ReminderLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      placeName: placeName ?? this.placeName,
    );
  }
}
@HiveType(typeId: 3)
class Subtask {
  @HiveField(0)
  String title;
  @HiveField(1)
  bool isCompleted;

  Subtask({required this.title, this.isCompleted = false});

  Subtask copyWith({String? title, bool? isCompleted}) {
    return Subtask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
@HiveType(typeId: 2)
enum ReminderPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}


@HiveType(typeId: 0)
enum RecurrenceType {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  custom,
}

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  RecurrenceType recurrenceType;


  @HiveField(6)
  String? recurrenceRule; // For custom rules (e.g., cron, RRULE, etc.)

  @HiveField(7)
  List<String> tags;



  @HiveField(8)
  ReminderPriority priority;

  @HiveField(9)
  List<String> attachments;

  @HiveField(10)
  List<Subtask> subtasks;

  @HiveField(11)
  ReminderLocation? location;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceRule,
    this.tags = const [],
    this.priority = ReminderPriority.medium,
    this.attachments = const [],
    this.subtasks = const [],
    this.location,
  });

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    RecurrenceType? recurrenceType,
    String? recurrenceRule,
    List<String>? tags,
    ReminderPriority? priority,
    List<String>? attachments,
    List<Subtask>? subtasks,
    ReminderLocation? location,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      subtasks: subtasks ?? this.subtasks,
      location: location ?? this.location,
    );
  }
}
