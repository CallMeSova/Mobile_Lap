import 'package:flutter/material.dart';

import 'diary.dart';

class AddDiaryPage extends StatefulWidget {
  final Diary? existing;

  const AddDiaryPage({super.key, this.existing});

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final List<String> _moods = const [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
    'แรงบันดาลใจ',
  ];

  String _selectedMood = 'มีความสุข';
  DateTime _selectedDate = DateTime.now();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing.title;
      _contentController.text = existing.content;
      _selectedMood = existing.mood;
      _selectedDate = DateTime.tryParse(existing.date) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final diary = Diary(
      id: widget.existing?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: _formatDate(_selectedDate),
      mood: _selectedMood,
    );
    Navigator.pop(context, diary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขบันทึก' : 'เขียนบันทึกใหม่'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('title-field'),
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อโปเกม่อน',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อโปเกม่อน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('content-field'),
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อโปเกม่อน',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรอกชื่อโปเกม่อน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: const Key('mood-field'),
                  initialValue: _selectedMood,
                  decoration: const InputDecoration(
                    labelText: 'อารมณ์โปเกมอน',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods.map((mood) {
                    return DropdownMenuItem(value: mood, child: Text(mood));
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedMood = value);
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    key: const Key('date-field'),
                    leading: const Icon(Icons.calendar_today),
                    title: Text('วันที่: ${_formatDate(_selectedDate)}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    key: const Key('save-diary-button'),
                    onPressed: _save,
                    icon: Icon(_isEditing ? Icons.save : Icons.add),
                    label: Text(_isEditing ? 'บันทึกการแก้ไข' : 'บันทึก'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
