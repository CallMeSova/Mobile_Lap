class Diary {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final String? quote;

  const Diary({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.quote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'quote': quote,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      date: map['date'] as String,
      mood: map['mood'] as String? ?? 'เฉยๆ',
      quote: map['quote'] as String?,
    );
  }
}
