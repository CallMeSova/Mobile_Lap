import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'quote.dart';

/// ติดต่อ API คำคม และแปลงข้อผิดพลาดทางเทคนิคให้ผู้ใช้เข้าใจได้
class ApiService {
  int id = Random().nextInt(151) + 1;
  static Future<Quote> fetchQuote() async {
    try {
      // ใส่ timestamp เพื่อไม่ให้ browser/proxy ส่งคำตอบเก่าจาก cache
      // เมื่อผู้ใช้กดรีเฟรช จะได้เรียกคำคมใหม่จริง ๆ ทุกครั้ง
      final url = Uri.https('pokeapi.co', '/api/v2/pokemon/1', {
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
