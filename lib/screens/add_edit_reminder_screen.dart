import 'package:flutter_markdown/flutter_markdown.dart';
import '../utils/string_extension.dart';
import 'package:flutter/material.dart';
import '../models/reminder.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  const AddEditReminderScreen({super.key, this.reminder});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  ReminderLocation? _location;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  bool _showPreview = false;
  List<Subtask> _subtasks = [];
  final TextEditingController _subtaskController = TextEditingController();
  List<String> _attachments = [];
  ReminderPriority _priority = ReminderPriority.medium;
  bool _isCompleted = false;
  List<String> _tags = [];
  final TextEditingController _tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  DateTime _dateTime = DateTime.now();
  RecurrenceType _recurrenceType = RecurrenceType.none;
  String? _recurrenceRule;

  @override
  void initState() {
    if (widget.reminder?.location != null) {
      _location = widget.reminder!.location;
      _latController.text = _location!.latitude.toString();
      _lngController.text = _location!.longitude.toString();
      _radiusController.text = _location!.radius.toString();
      _placeController.text = _location!.placeName ?? '';
    }
    // If no location, leave fields empty
    super.initState();
    if (widget.reminder != null) {
      _title = widget.reminder!.title;
      _description = widget.reminder!.description;
      _dateTime = widget.reminder!.dateTime;
      _recurrenceType = widget.reminder!.recurrenceType;
      _recurrenceRule = widget.reminder!.recurrenceRule;
      _tags = List<String>.from(widget.reminder!.tags);
      _tagsController.text = _tags.join(', ');
      _isCompleted = widget.reminder!.isCompleted;
      _priority = widget.reminder!.priority;
      _attachments = List<String>.from(widget.reminder!.attachments);
      _subtasks = List<Subtask>.from(widget.reminder!.subtasks);
    } else {
      _title = '';
      _description = '';
      _recurrenceType = RecurrenceType.none;
      _recurrenceRule = null;
      _tags = [];
      _tagsController.text = '';
      _isCompleted = false;
      _priority = ReminderPriority.medium;
      _attachments = [];
      _subtasks = [];
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              Row(
                children: [
                  const Text('Description (Markdown supported)'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showPreview = !_showPreview;
                      });
                    },
                    child: Text(_showPreview ? 'Edit' : 'Preview'),
                  ),
                ],
              ),
              _showPreview
                  ? Container(
                      height: 120,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: MarkdownBody(data: _description),
                    )
                  : TextFormField(
                      initialValue: _description,
                      minLines: 3,
                      maxLines: 8,
                      decoration: const InputDecoration(labelText: 'Description'),
                      onChanged: (value) => setState(() => _description = value),
                      onSaved: (value) => _description = value ?? '',
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Location-based Reminder'),
                  const Spacer(),
                  Switch(
                    value: _location != null,
                    onChanged: (val) {
                      setState(() {
                        if (val) {
                          _location = ReminderLocation(latitude: 0, longitude: 0);
                        } else {
                          _location = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              if (_location != null)
                Column(
                  children: [
                    TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      onChanged: (val) {
                        final d = double.tryParse(val);
                        if (d != null) _location = _location!.copyWith(latitude: d);
                      },
                    ),
                    TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      onChanged: (val) {
                        final d = double.tryParse(val);
                        if (d != null) _location = _location!.copyWith(longitude: d);
                      },
                    ),
                    TextFormField(
                      controller: _radiusController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Radius (meters)'),
                      onChanged: (val) {
                        final d = double.tryParse(val);
                        if (d != null) _location = _location!.copyWith(radius: d);
                      },
                    ),
                    TextFormField(
                      controller: _placeController,
                      decoration: const InputDecoration(labelText: 'Place Name (optional)'),
                      onChanged: (val) {
                        _location = _location!.copyWith(placeName: val);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Subtasks:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(hintText: 'Add subtask'),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            _subtasks.add(Subtask(title: val.trim()));
                            _subtaskController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final val = _subtaskController.text.trim();
                      if (val.isNotEmpty) {
                        setState(() {
                          _subtasks.add(Subtask(title: val));
                          _subtaskController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_subtasks.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subtasks.length,
                  itemBuilder: (context, idx) {
                    final sub = _subtasks[idx];
                    return ListTile(
                      dense: true,
                      leading: Checkbox(
                        value: sub.isCompleted,
                        onChanged: (val) {
                          setState(() {
                            _subtasks[idx] = sub.copyWith(isCompleted: val ?? false);
                          });
                        },
                      ),
                      title: TextFormField(
                        initialValue: sub.title,
                        decoration: const InputDecoration(border: InputBorder.none),
                        onChanged: (val) {
                          setState(() {
                            _subtasks[idx] = sub.copyWith(title: val);
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _subtasks.removeAt(idx);
                          });
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Attachments:'),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Add'),
                    onPressed: () async {
                      // Use file_picker for all files, image_picker for images, etc.
                      // For demo, just pick a file path (implement with file_picker in real app)
                      // final result = await FilePicker.platform.pickFiles();
                      // if (result != null && result.files.single.path != null) {
                      //   setState(() {
                      //     _attachments.add(result.files.single.path!);
                      //   });
                      // }
                    },
                  ),
                ],
              ),
              if (_attachments.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _attachments.map((path) => Chip(
                    label: Text(path.split('/').last),
                    onDeleted: () {
                      setState(() {
                        _attachments.remove(path);
                      });
                    },
                  )).toList(),
                ),
              DropdownButtonFormField<ReminderPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ReminderPriority.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.toString().split('.').last.capitalize()),
                  );
                }).toList(),
                onChanged: (p) {
                  setState(() {
                    _priority = p!;
                  });
                },
                onSaved: (p) => _priority = p!,
              ),
              const SizedBox(height: 16),
              // Tags input
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                onChanged: (value) {
                  setState(() {
                    _tags = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  });
                },
                onSaved: (value) {
                  _tags = value!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                },
              ),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                      _tagsController.text = _tags.join(', ');
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isCompleted,
                    onChanged: (val) {
                      setState(() {
                        _isCompleted = val ?? false;
                      });
                    },
                  ),
                  const Text('Completed'),
                ],
              ),
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrenceType,
                decoration: const InputDecoration(labelText: 'Recurrence'),
                items: RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.capitalize()),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    _recurrenceType = type!;
                  });
                },
                onSaved: (type) => _recurrenceType = type!,
              ),
              if (_recurrenceType == RecurrenceType.custom)
                TextFormField(
                  initialValue: _recurrenceRule,
                  decoration: const InputDecoration(labelText: 'Custom Rule (e.g., RRULE)'),
                  onSaved: (value) => _recurrenceRule = value,
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Date & Time: ${_dateTime.toString().substring(0, 16)}'),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _pickDateTime,
                    child: const Text('Pick'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final reminder = Reminder(
                      id: widget.reminder?.id,
                      title: _title,
                      description: _description,
                      dateTime: _dateTime,
                      isCompleted: _isCompleted,
                      recurrenceType: _recurrenceType,
                      recurrenceRule: _recurrenceRule,
                      tags: _tags,
                      priority: _priority,
                      attachments: _attachments,
                      subtasks: _subtasks,
                      location: _location != null && _latController.text.isNotEmpty && _lngController.text.isNotEmpty
                          ? ReminderLocation(
                              latitude: double.tryParse(_latController.text) ?? 0,
                              longitude: double.tryParse(_lngController.text) ?? 0,
                              radius: double.tryParse(_radiusController.text) ?? 100,
                              placeName: _placeController.text.isNotEmpty ? _placeController.text : null,
                            )
                          : null,
                    );
                    Navigator.of(context).pop(reminder);
                  }
                },
                child: Text(widget.reminder == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
