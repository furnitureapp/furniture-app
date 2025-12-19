class GstModel {
  final String gstin;
  final String tradeName;
  final String address;
  final Map<String, dynamic> raw; 

  GstModel({
    required this.gstin,
    required this.tradeName,
    required this.address,
    required this.raw,
  });

  factory GstModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final pradr = data['pradr'] ?? {};
    final adrString = pradr['adr'] ??
        (pradr['addr'] != null
            ? [
                pradr['addr']['bno'] ?? '',
                pradr['addr']['bnm'] ?? '',
                pradr['addr']['st'] ?? '',
                pradr['addr']['loc'] ?? '',
                pradr['addr']['dst'] ?? '',
                pradr['addr']['stcd'] ?? '',
                pradr['addr']['pncd'] ?? '',
              ].where((s) => (s ?? '').toString().isNotEmpty).join(', ')
            : '');

    return GstModel(
gstin: data['gstin'] ?? '',
tradeName: data['tradeNam'] ?? '',
      address: adrString as String,
      raw: data as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'tradeName': tradeName,
      'address': address,
      'raw': raw,
    };
  }
}


class DealerModel {
  final String id;
  final String companyName;
  final String phoneNumber;
  final String gstNumber;
  final String address;
  final String email;
  final String username;

  DealerModel({
    required this.id,
    required this.companyName,
    required this.phoneNumber,
    required this.gstNumber,
    required this.address,
    required this.email,
    required this.username,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
    );
  }
}
