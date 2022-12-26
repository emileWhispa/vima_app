class User {
  int id;
  String? username;
  String? email;
  String? profile;
  String? firebaseUid;
  String? providerId;

  User.fromJson(Map<String, dynamic> map)
      : username = map['username'],
        id = map['id'],
        email = map['email'],
        profile = map['profile'],
        providerId = map['providerId'],
        firebaseUid = map['firebaseUid'];


  static User? user;
}
