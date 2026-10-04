class Pokemon {
  final int? id;
  final int number;
  final String name;
  final String remark;
  final String date;

  const Pokemon({
    this.id,
    required this.number,
    required this.name,
    required this.remark,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'remark': remark,
      'date': date,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'] as int?,
      number: map['number'] as int,
      name: map['name'] as String,
      remark: map['remark'] as String,
      date: map['date'] as String,
    );
  }
}
