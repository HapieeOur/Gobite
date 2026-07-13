class MejaModel {
  final int id;
  final int nomorMeja;
  final String status;

  MejaModel({
    required this.id,
    required this.nomorMeja,
    required this.status,
  });

  factory MejaModel.fromJson(Map<String, dynamic> json) {
    return MejaModel(
      id: json['id'],
      nomorMeja: json['nomor_meja'],
      status: json['status'],
    );
  }
}