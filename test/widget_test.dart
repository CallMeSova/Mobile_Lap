import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lap_03092569/add_diary_page.dart';
import 'package:lap_03092569/diary.dart';

void main() {
  test('Diary แปลงเป็น Map และแปลงกลับได้ครบ รวม mood', () {
    const diary = Diary(
      id: 7,
      title: 'วันที่ดี',
      content: 'วันนี้ทำ Lab สำเร็จ',
      date: '2026-09-14',
      mood: 'มีความสุข',
      quote: 'วันนี้เป็นวันที่ดี',
    );

    final restored = Diary.fromMap(diary.toMap());

    expect(restored.id, 7);
    expect(restored.title, 'วันที่ดี');
    expect(restored.content, 'วันนี้ทำ Lab สำเร็จ');
    expect(restored.date, '2026-09-14');
    expect(restored.mood, 'มีความสุข');
    expect(restored.quote, 'วันนี้เป็นวันที่ดี');
  });

  testWidgets('ฟอร์มแก้ไขแสดงข้อมูลเดิมครบ', (tester) async {
    const existing = Diary(
      id: 3,
      title: 'บันทึกเดิม',
      content: 'เนื้อหาเดิม',
      date: '2026-09-10',
      mood: 'ตื่นเต้น',
    );

    await tester.pumpWidget(
      const MaterialApp(home: AddDiaryPage(existing: existing)),
    );

    expect(find.text('แก้ไขบันทึก'), findsOneWidget);
    expect(find.text('บันทึกเดิม'), findsOneWidget);
    expect(find.text('เนื้อหาเดิม'), findsOneWidget);
    expect(find.text('ตื่นเต้น'), findsOneWidget);
    expect(find.text('วันที่: 2026-09-10'), findsOneWidget);
  });

  testWidgets('ฟอร์มแจ้งเตือนเมื่อชื่อเรื่องและเนื้อหาว่าง', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddDiaryPage()));

    await tester.tap(find.byKey(const Key('save-diary-button')));
    await tester.pump();

    expect(find.text('กรุณากรอกชื่อเรื่อง'), findsOneWidget);
    expect(find.text('กรุณากรอกเนื้อหา'), findsOneWidget);
  });
}
