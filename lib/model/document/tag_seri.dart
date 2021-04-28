class TagSeri {
  int id;
  String title;
  int docId;
  int userId;
  int bookId;
  String serializer;

  TagSeri({
    this.id,
    this.title,
    this.docId,
    this.userId,
    this.bookId,
    this.serializer,
  });

  factory TagSeri.fromJson(Map<String, dynamic> json) {
    return TagSeri(
      id: json['id'],
      title: json['title'],
      docId: json['doc_id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      serializer: json['_serializer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'doc_id': docId,
      'user_id': userId,
      'book_id': bookId,
      '_serializer': serializer,
    };
  }
}
