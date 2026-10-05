
class IssueEntry {
  final String id;
  final String issueId;
  String content;
  final int createdAt;
  int updatedAt;

  IssueEntry({required this.id, required this.issueId, required this.content, required this.createdAt, required this.updatedAt});

  factory IssueEntry.fromJson(Map<String, dynamic> json) => IssueEntry(
    id: json['id'], issueId: json['issueId'] ?? '', content: json['content'] ?? '',
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'issueId': issueId, 'content': content, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory IssueEntry.fromMap(Map<String, dynamic> m) => IssueEntry.fromJson(m);
}
