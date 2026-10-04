import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'quote.dart';

/// ติดต่อ API คำคม และแปลงข้อผิดพลาดทางเทคนิคให้ผู้ใช้เข้าใจได้
class ApiService {
  // รหัสนักศึกษา: 67011212036
  static const String studentId = '67011212036';
  static const String baseUrl =
      'https://thipwimon.comsciproject.net/mydiary/api.php/$studentId';

  // CREATE — เพิ่มบันทึก (POST)
  static Future<void> createDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse(baseUrl);
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': title,
            'content': content,
            'mood': mood,
            'date': date,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('เพิ่มไม่สำเร็จ (${response.statusCode})');
    }
  }

  // READ — อ่านบันทึกทั้งหมด (GET)
  static Future<List<dynamic>> getDiaries() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> all = jsonDecode(response.body);
      return all;
    }
    throw Exception('โหลดไม่สำเร็จ (${response.statusCode})');
  }

  // UPDATE — แก้ไขบันทึก (PUT)
  static Future<void> updateDiary(
    String id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http
        .put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': title,
            'content': content,
            'mood': mood,
            'date': date,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('แก้ไขไม่สำเร็จ (${response.statusCode})');
    }
  }

  // DELETE — ลบบันทึก (DELETE)
  static Future<void> deleteDiary(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('ลบไม่สำเร็จ (${response.statusCode})');
    }
  }

  static Future<Quote> fetchQuote() async {
    try {
      // ใส่ timestamp เพื่อไม่ให้ browser/proxy ส่งคำตอบเก่าจาก cache
      // เมื่อผู้ใช้กดรีเฟรช จะได้เรียกคำคมใหม่จริง ๆ ทุกครั้ง
      final url = Uri.https('dummyjson.com', '/quotes/random', {
        '_': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      final response = await http
          .get(url, headers: const {'Cache-Control': 'no-cache'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Quote.fromJson(data);
      }

      throw QuoteFetchException(
        'เซิร์ฟเวอร์ตอบผิดพลาด (${response.statusCode}) ลองใหม่อีกครั้ง',
      );
    } on TimeoutException {
      throw QuoteFetchException('การเชื่อมต่อใช้เวลานานเกินไป กรุณาลองใหม่');
    } on SocketException {
      throw QuoteFetchException('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ต');
    } on FormatException {
      throw QuoteFetchException('ข้อมูลคำคมไม่ถูกต้อง กรุณาลองใหม่');
    } on QuoteFetchException {
      rethrow;
    } catch (_) {
      throw QuoteFetchException('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ต');
    }
  }
}

class QuoteFetchException implements Exception {
  final String message;

  const QuoteFetchException(this.message);

  @override
  String toString() => message;
}
