import 'orgs.dart';

class MetaSeri {
  Map raw;
  String ip;
  String ua;
  List<MetaOrg> orgs;

  MetaSeri({this.ip, this.ua, this.orgs});

  MetaSeri.fromJson(dynamic json) {
    if (json != null) {
      raw = json;
      ip = json["ip"];
      ua = json["ua"];
      if (json["orgs"] != null) {
        orgs = [];
        json["orgs"].forEach((v) {
          orgs.add(MetaOrg.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() => raw;
}
