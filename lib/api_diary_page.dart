import 'package:flutter/material.dart';

import 'api_form_page.dart';
import 'api_service.dart';

class ApiDiaryPage extends StatefulWidget {
  const ApiDiaryPage({super.key});

  @override
  State<ApiDiaryPage> createState() => _ApiDiaryPageState();
}

class _ApiDiaryPageState extends State<ApiDiaryPage> {
  late Future<List<dynamic>> _diariesFuture;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  void _loadDiaries() {
    setState(() {
      _diariesFuture = ApiService.getDiaries();
    });
  }

  Future<void> _addDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    try {
      await ApiService.createDiary(title, content, mood, date);
      _loadDiaries();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('เพิ่มบันทึกสำเร็จ')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateDiary(
    String id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    try {
      await ApiService.updateDiary(id, title, content, mood, date);
      _loadDiaries();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('แก้ไขบันทึกสำเร็จ')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('แก้ไขไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDiary(String id) async {
    try {
      await ApiService.deleteDiary(id);
      _loadDiaries();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบบันทึกสำเร็จ')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกบน Cloud (REST API)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'รีเฟรช',
            onPressed: _loadDiaries,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDiaries(),
        child: FutureBuilder<List<dynamic>>(
          future: _diariesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตแล้วลองใหม่อีกครั้ง',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadDiaries,
                        icon: const Icon(Icons.refresh),
                        label: const Text('ลองใหม่อีกครั้ง'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final diaries = snapshot.data ?? [];
            if (diaries.isEmpty) {
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_queue, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'ยังไม่มีบันทึกบน Cloud',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'กดปุ่ม + ด้านล่างเพื่อเพิ่มบันทึก',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: diaries.length,
              itemBuilder: (context, i) {
                final obj = diaries[i];
                final id = (obj['id'] ?? obj['_id'] ?? '').toString();
                final title = obj['title']?.toString() ?? '';
                final content = obj['content']?.toString() ?? '';
                final mood = obj['mood']?.toString() ?? '';
                final date = obj['date']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 1.5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: const Icon(Icons.cloud, color: Colors.indigo),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$mood • $date\n$content',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // ให้ Row กว้างเท่าที่จำเป็น
                      children: [
                        // ── แก้ไข (Update) ──
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'แก้ไข',
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ApiFormPage(existing: obj as Map?),
                              ),
                            );
                            if (result is Map) {
                              await _updateDiary(
                                id,
                                result['title']?.toString() ?? '',
                                result['content']?.toString() ?? '',
                                result['mood']?.toString() ?? '',
                                result['date']?.toString() ?? '',
                              );
                            }
                          },
                        ),
                        // ── ลบ (Delete) + ยืนยันก่อนลบ ──
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'ลบ',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('ลบบันทึก?'),
                                content: Text('ต้องการลบ "$title" ใช่ไหม'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('ยกเลิก'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'ลบ',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deleteDiary(id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      // ── ปุ่มเพิ่ม: เปิดฟอร์มโหมดเพิ่ม แล้วรับค่ากลับมา createDiary ──
      floatingActionButton: FloatingActionButton(
        tooltip: 'เพิ่มบันทึกบน Cloud',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApiFormPage()),
          );
          if (result is Map) {
            await _addDiary(
              result['title']?.toString() ?? '',
              result['content']?.toString() ?? '',
              result['mood']?.toString() ?? '',
              result['date']?.toString() ?? '',
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
