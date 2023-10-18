class ResponseModel {
  final String id;
  final int created;
  final String root;

  ResponseModel({required this.id, required this.created, required this.root});

  factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(
      id: json["id"], created: json["created"], root: json["root"]);

  static List<ResponseModel> modelsFromSnapshot(List modelSnapshot) {
    return modelSnapshot.map((data) => ResponseModel.fromJson(data)).toList();
  }
}
