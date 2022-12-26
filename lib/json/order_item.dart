import 'product.dart';

class OrderItem{
  int id;
  String desc;
  Product product;
  int quantity;
  double price;

  OrderItem.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        quantity = map['quantity'],
        product = Product.fromJson(map['product']),
        price = (map['price'] as num).toDouble(),
        desc = map['description'];
}