import 'product.dart';

class Cart {
  int id;
  String desc;
  Product product;
  int quantity;
  double price;


  bool selected = false;

  Cart(this.quantity,this.desc,this.price,this.product,this.id);

  Cart.fromJson(Map<String, dynamic> map)
      : id = map['id'],
  quantity = map['quantity'],
  product = Product.fromJson(map['product']),
  price = (map['price'] as num).toDouble(),
        desc = map['description'];

  double get total=>price*quantity;
}
