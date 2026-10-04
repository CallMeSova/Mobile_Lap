class Quote {
  final String text;

  const Quote({required this.text});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(text: json['name'] as String? ?? '');
  }
}
