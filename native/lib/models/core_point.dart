
class CorePoint {
  final String id;
  final String name;
  String content;
  final int createdAt;
  int updatedAt;

  CorePoint({required this.id, required this.name, required this.content, required this.createdAt, required this.updatedAt});

  factory CorePoint.fromJson(Map<String, dynamic> json) => CorePoint(
    id: json['id'], name: json['name'] ?? '', content: json['content'] ?? '',
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'content': content, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory CorePoint.fromMap(Map<String, dynamic> m) => CorePoint.fromJson(m);
}
