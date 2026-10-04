import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lap_03092569/database_helper.dart';
import 'package:lap_03092569/main.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> addDiary(
    WidgetTester tester, {
    required String title,
    required String content,
    required String mood,
  }) async {
    await tester.tap(find.byKey(const Key('add-diary-button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('title-field')), title);
    await tester.enterText(find.byKey(const Key('content-field')), content);
    await tester.tap(find.byKey(const Key('mood-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(mood).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-diary-button')));
    await tester.pumpAndSettle();
  }

  testWidgets('MyDiary ทำ CRUD, รายละเอียด, ยืนยันลบ และเก็บ SQLite ครบ', (
    tester,
  ) async {
    final databasePath = join(await getDatabasesPath(), 'mydiary.db');
    await deleteDatabase(databasePath);

    await tester.pumpWidget(const MyDiaryApp());
    await tester.pumpAndSettle();

    expect(find.text('ยังไม่มีบันทึก'), findsOneWidget);

    await addDiary(
      tester,
      title: 'SQLite Lab',
      content: 'Mood persists after restart',
      mood: 'มีความสุข',
    );

    expect(find.text('SQLite Lab'), findsOneWidget);
    expect(find.textContaining('มีความสุข'), findsOneWidget);

    await tester.tap(find.text('SQLite Lab'));
    await tester.pumpAndSettle();
    expect(find.text('รายละเอียดบันทึก'), findsOneWidget);
    expect(find.text('Mood persists after restart'), findsOneWidget);
    expect(find.text('มีความสุข'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();
    expect(find.text('แก้ไขบันทึก'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('title-field')),
      'SQLite Lab Updated',
    );
    await tester.enterText(
      find.byKey(const Key('content-field')),
      'Updated content stays in SQLite',
    );
    await tester.tap(find.byKey(const Key('mood-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ตื่นเต้น').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-diary-button')));
    await tester.pumpAndSettle();

    expect(find.text('SQLite Lab Updated'), findsOneWidget);
    expect(find.textContaining('ตื่นเต้น'), findsOneWidget);

    await addDiary(
      tester,
      title: 'Delete Me',
      content: 'Used to test delete confirmation',
      mood: 'เฉยๆ',
    );

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    expect(find.text('ลบบันทึก?'), findsOneWidget);
    expect(find.text('ต้องการลบ "Delete Me" ใช่ไหม'), findsOneWidget);
    await tester.tap(find.text('ยกเลิก'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Me'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Me'), findsNothing);
    expect(find.text('SQLite Lab Updated'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await DatabaseHelper.close();
    await tester.pumpWidget(const MyDiaryApp());
    await tester.pumpAndSettle();

    expect(find.text('SQLite Lab Updated'), findsOneWidget);
    expect(find.textContaining('ตื่นเต้น'), findsOneWidget);
    expect(find.text('บันทึกของฉัน (1)'), findsOneWidget);
  });
}
