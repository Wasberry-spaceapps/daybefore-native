
class JournalEntry {
  final String id;
  String content;
  final int createdAt;
  int updatedAt;

  JournalEntry({required this.id, required this.content, required this.createdAt, required this.updatedAt});

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'], content: json['content'] ?? '',
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'content': content, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry.fromJson(m);
}
