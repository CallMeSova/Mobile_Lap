import 'package:flutter/material.dart';

class ApiFormPage extends StatefulWidget {
  final Map? existing; // ส่ง obj เดิมมา = โหมดแก้ / null = เพิ่มใหม่

  const ApiFormPage({super.key, this.existing});

  @override
  State<ApiFormPage> createState() => _ApiFormPageState();
}

class _ApiFormPageState extends State<ApiFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _mood = 'มีความสุข';
  final List<String> _moods = ['มีความสุข', 'เฉยๆ', 'เศร้า', 'เหนื่อย', 'ตื่นเต้น'];
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      // โหมดแก้: เติมค่าเดิมลงฟอร์ม
      _titleController.text = widget.existing!['title']?.toString() ?? '';
      _contentController.text = widget.existing!['content']?.toString() ?? '';
      _mood = widget.existing!['mood']?.toString() ?? 'มีความสุข';
      if (!_moods.contains(_mood)) {
        _mood = 'มีความสุข';
      }
      _date = DateTime.tryParse(widget.existing!['date']?.toString() ?? '') ??
          DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'เพิ่มบันทึก' : 'แก้ไขบันทึก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อเรื่อง',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อเรื่อง' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'เนื้อหา',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'กรุณากรอกเนื้อหา' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _mood,
                  decoration: const InputDecoration(
                    labelText: 'อารมณ์',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _mood = v);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'วันที่: ${_date.toIso8601String().substring(0, 10)}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // ส่งค่ากลับเป็น Map ให้หน้ารายการเอาไปเรียก API
                        Navigator.pop(context, {
                          'title': _titleController.text.trim(),
                          'content': _contentController.text.trim(),
                          'mood': _mood,
                          'date': _date.toIso8601String().substring(0, 10),
                        });
                      }
                    },
                    child: const Text('บันทึก', style: TextStyle(fontSize: 16)),
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
