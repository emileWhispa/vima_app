import 'gallery.dart';

class Product {
  int id;
  String name;
  String image;
  String? description;
  int quantity;
  int sold;
  double price;
  double discount;
  String? location;
  String? locationId;

  List<Gallery> images = [];

  int activeSlide = 0;

  Product.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        image = map['image'],
        name = map['name'],
        sold = map['sold'] ?? 0,
        quantity = map['quantity'],
        location = map['location'],
        locationId = map['locationId'],
        description = map['description'],
        discount = (map['discountPrice'] as num).toDouble(),
        images = (map['galleryList'] as Iterable).map((e) => Gallery.fromJson(e)).toList(),
        price = (map['originalPrice'] as num).toDouble();


  bool get hasDiscount=>price > discount;


  double get percentDiscount=> (price-discount) * 100 / price;

  String get percentDiscountStr=>percentDiscount.toStringAsFixed(2);
}
