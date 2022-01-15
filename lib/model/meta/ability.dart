class MetaAbilitySeri {
  bool? read;
  bool? update;
  bool? assign;
  bool? block;
  bool? destroy;
  bool? pin;

  MetaAbilitySeri.fromJson(dynamic json) {
    read = json["read"];
    update = json["update"];
    assign = json["assign"];
    block = json["block"];
    destroy = json["destroy"];
    pin = json["pin"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["read"] = read;
    map["update"] = update;
    map["assign"] = assign;
    map["block"] = block;
    map["destroy"] = destroy;
    map["pin"] = pin;
    return map;
  }
}
