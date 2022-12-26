import 'address.dart';
import 'order_item.dart';

class Order {
  int id;
  Address address;
  double price;
  int quantity;
  DateTime dateTime;
  String status;

  List<OrderItem> list = [];

  Order.fromJson(Map<String, dynamic> map)
      : id = map['id'],
  quantity = map['quantity'] ?? 0,
  status = map['status'] ?? "",
  dateTime = DateTime.fromMillisecondsSinceEpoch(map['date']),
  price = (map['total'] as num).toDouble(),
  address = Address.fromJson(map['address']),
        list = (map['itemList'] as Iterable?)
                ?.map((e) => OrderItem.fromJson(e))
                .toList() ??
            [];


  double get total =>price;
}
