
class Issue {
  final String id;
  final String name;
  String content;
  final int isArchived;
  final int createdAt;
  int updatedAt;

  Issue({required this.id, required this.name, required this.content, required this.isArchived, required this.createdAt, required this.updatedAt});

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
    id: json['id'], name: json['name'] ?? '', content: json['content'] ?? '',
    isArchived: (json['isArchived'] == true || json['isArchived'] == 1) ? 1 : 0,
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'content': content, 'isArchived': isArchived, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory Issue.fromMap(Map<String, dynamic> m) => Issue.fromJson(m);
}
