class Address {
  int addressId;
  String address;
  String delivery;
  String phone;
  String email;

  bool sending = false;


  Address.fromJson(Map<String, dynamic> json)
      : delivery = json['deliveryName'],
        address = json['addressDetail'],
        addressId = json['id'],
        phone = json['phone'],
        email = json['email'];


  Map<String,dynamic> toJson()=>{
    "deliveryName":delivery,
    "addressDetail":address,
    "id":addressId,
    "phone":phone,
    "email":email,
  };


  String get combined =>"$delivery $email";
}
