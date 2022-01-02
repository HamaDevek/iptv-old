import 'dart:convert';

class PlayListModel {
  int id;
  String link;
  String name;
  int type;
  PlayListModel({this.id, this.link,this. name, this.type});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'link': link,
      'name': name,
      'type': type,
    };
    return map;
  }
  factory PlayListModel.fromMap(Map<String, dynamic> map) => new PlayListModel(
      id: map['id'], link: map['link'], name: map['name'], type: map["type"]);
}

PlayListModel playListModelFromJson(String str) {
  final jsonData = json.decode(str);
  return PlayListModel.fromMap(jsonData);
}

String playListModelToJson(PlayListModel data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}
