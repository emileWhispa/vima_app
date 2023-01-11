class Company {
  int id;
  String? companySize;
  String companyType;
  String companyName;
  String? companyBio;
  String? phone;
  String? email;
  String? address;

  Company.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        companySize = map['companySize'],
        companyBio = map['companyBio'],
        companyName = map['companyName'],
        email = map['email'],
        address = map['address'],
        phone = map['phone'],
        companyType = map['companyType'];
}
