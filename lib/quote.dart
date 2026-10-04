class Quote {
  final String text;
  final String author;

  const Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] as String? ?? '',
      author: json['author'] as String? ?? 'ไม่ทราบชื่อผู้เขียน',
    );
  }
}
