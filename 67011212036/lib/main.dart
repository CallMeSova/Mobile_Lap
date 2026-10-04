import 'package:flutter/material.dart';

import 'add_diary_page.dart';
import 'database_helper.dart';
import 'diary.dart';
import 'diary_detail_page.dart';
import 'api_service.dart';
import 'quote.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyDiary',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF7F7FC),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Diary> diaries = [];
  late Future<Quote> _quoteFuture;
  int _quoteVersion = 0;
  bool _isLoading = true;
  String? _errorMessage;

  final List<Color> _colors = const [
    Colors.indigo,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _quoteFuture = ApiService.fetchQuote();
    _watchQuoteFuture(_quoteFuture);
    _loadDiaries();
  }

  // FutureBuilder ปกติจะ rebuild เองเมื่อ Future จบ แต่ callback นี้ทำให้
  // หน้าหลัก rebuild ซ้ำอย่างแน่นอน แม้บน emulator ที่ไม่ repaint ทันที.
  void _watchQuoteFuture(Future<Quote> future) {
    future.then<void>(
      (_) {
        if (mounted) setState(() {});
      },
      onError: (Object _, StackTrace _) {
        if (mounted) setState(() {});
      },
    );
  }

  void _refreshQuote() {
    final future = ApiService.fetchQuote();
    _watchQuoteFuture(future);
    setState(() {
      _quoteFuture = future;
      _quoteVersion++;
    });
  }

  String _formatToday() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _saveQuote(Quote quote) async {
    try {
      await DatabaseHelper.insert(
        Diary(
          title: 'โปเกม่อนนน',
          content: quote.text,
          quote: quote.text,
          date: _formatToday(),
          mood: 'แรงบันดาลใจ',
        ),
      );
      await _loadDiaries();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกโปเกมอนแล้ว')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกโปเกมอนไม่สำเร็จ กรุณาลองใหม่')),
      );
    }
  }

  Widget _buildQuotePanel() {
    return FutureBuilder<Quote>(
      key: ValueKey(_quoteVersion),
      future: _quoteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text(
                  'กำลังโหลดโปเกเดกซ์...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          final message = snapshot.error.toString();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    const Text('โหลดโปเกมอนไม่ได้'),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      key: const Key('retry-quote-button'),
                      onPressed: _refreshQuote,
                      icon: const Icon(Icons.refresh),
                      label: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final quote = snapshot.data;
        if (quote == null) return const SizedBox.shrink();
        return Container(
          key: const Key('quote-card'),
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.format_quote, color: Colors.indigo),
              Text(
                '"${quote.text}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                // '— ${quote.author}',
                '—',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('save-quote-button'),
                onPressed: () => _saveQuote(quote),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('บันทึกโปเกมอนนี้'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadDiaries() async {
    try {
      final data = await DatabaseHelper.getAll();
      if (!mounted) return;
      setState(() {
        diaries = data;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'ไม่สามารถโหลดบันทึกได้';
      });
    }
  }

  Future<void> _addDiary(Diary diary) async {
    await DatabaseHelper.insert(diary);
    await _loadDiaries();
  }

  Future<void> _updateDiary(Diary diary) async {
    await DatabaseHelper.update(diary);
    await _loadDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await DatabaseHelper.delete(id);
    await _loadDiaries();
  }

  Future<void> _openAddDiary() async {
    final result = await Navigator.push<Diary>(
      context,
      MaterialPageRoute(builder: (context) => const AddDiaryPage()),
    );
    if (result != null) {
      await _addDiary(result);
    }
  }

  Future<void> _openEditDiary(Diary diary) async {
    final result = await Navigator.push<Diary>(
      context,
      MaterialPageRoute(builder: (context) => AddDiaryPage(existing: diary)),
    );
    if (result != null) {
      await _updateDiary(result);
    }
  }

  Future<void> _confirmDelete(Diary diary) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบบันทึก?'),
        content: Text('ต้องการลบ "${diary.title}" ใช่ไหม'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && diary.id != null) {
      await _deleteDiary(diary.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบบันทึกแล้ว')));
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage!),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadDiaries();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    if (diaries.isEmpty) {
      return const Center(
        key: Key('empty-diary-state'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ยังไม่มีบันทึก',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'กดปุ่ม + เพื่อเขียนบันทึกแรก',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const Key('diary-list'),
      padding: const EdgeInsets.all(12),
      itemCount: diaries.length,
      itemBuilder: (context, index) {
        final diary = diaries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            leading: CircleAvatar(
              backgroundColor: _colors[index % _colors.length],
              child: const Icon(Icons.book, color: Colors.white),
            ),
            title: Text(
              diary.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${diary.mood} • ${diary.date}'),
                Text(
                  diary.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: Key('edit-diary-${diary.id}'),
                  tooltip: 'แก้ไข',
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _openEditDiary(diary),
                ),
                IconButton(
                  key: Key('delete-diary-${diary.id}'),
                  tooltip: 'ลบ',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(diary),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailPage(diary: diary),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เปเกเดกซ์ (${diaries.length})'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('refresh-quote-button'),
            tooltip: 'รีเฟรชโปเกดกซ์',
            onPressed: _refreshQuote,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuotePanel(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-diary-button'),
        onPressed: _openAddDiary,
        tooltip: 'เพิ่มบันทึก',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับแอป'), centerTitle: true),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.book, size: 50, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'MyDiary',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('แอปสมุดบันทึกที่เก็บข้อมูลด้วย SQLite'),
              SizedBox(height: 4),
              Text('สร้างโดย นายธีรพัฒน์ ผากาเขียว'),
              Text('รหัสนักศึกษา 67011212036'),
              SizedBox(height: 16),
              Text('เวอร์ชัน 2.0', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  final List<Widget> pages = const [DiaryListPage(), AboutPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'โปเกดกซ์',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'เกี่ยวกับ'),
        ],
      ),
    );
  }
}
