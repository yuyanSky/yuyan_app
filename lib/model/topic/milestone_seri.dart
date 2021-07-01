class MilestoneSeri {
  int id;
  int iid;
  int groupId;
  String title;
  dynamic dueOn;
  int userId;
  int status;
  int topicsCount;
  int closedTopicsCount;
  String createdAt;
  String updatedAt;
  String serializer;

  MilestoneSeri({
    this.id,
    this.iid,
    this.groupId,
    this.title,
    this.dueOn,
    this.userId,
    this.status,
    this.topicsCount,
    this.closedTopicsCount,
    this.createdAt,
    this.updatedAt,
    this.serializer,
  });

  MilestoneSeri.fromJson(dynamic json) {
    id = json["id"];
    iid = json["iid"];
    groupId = json["group_id"];
    title = json["title"];
    dueOn = json["due_on"];
    userId = json["user_id"];
    status = json["status"];
    topicsCount = json["topics_count"];
    closedTopicsCount = json["closed_topics_count"];
    createdAt = json["created_at"];
    updatedAt = json["updated_at"];
    serializer = json["_serializer"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["iid"] = iid;
    map["group_id"] = groupId;
    map["title"] = title;
    map["due_on"] = dueOn;
    map["user_id"] = userId;
    map["status"] = status;
    map["topics_count"] = topicsCount;
    map["closed_topics_count"] = closedTopicsCount;
    map["created_at"] = createdAt;
    map["updated_at"] = updatedAt;
    map["_serializer"] = serializer;
    return map;
  }
}
