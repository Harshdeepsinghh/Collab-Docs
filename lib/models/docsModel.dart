import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class DocumentModel {
  String title;
  String docId;
  List content;
  String uid;
  DocumentModel({
    required this.title,
    required this.docId,
    required this.content,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      '_id': docId,
      'content': content,
      'uid': uid,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      title: map['title'] ?? '',
      docId: map['_id'] ?? '',
      content: map['content'] ?? [],
      uid: map['uid'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) =>
      DocumentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant DocumentModel other) {
    if (identical(this, other)) return true;

    return other.title == title;
  }

  @override
  int get hashCode => title.hashCode;

  DocumentModel copyWith(
      {String? title, String? docId, List? content, String? uid}) {
    return DocumentModel(
      title: title ?? this.title,
      docId: docId ?? this.docId,
      content: content ?? this.content,
      uid: uid ?? this.uid,
    );
  }

  @override
  String toString() => 'DocumentModel(title: $title)';
}
