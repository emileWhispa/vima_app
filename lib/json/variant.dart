import 'category.dart';
import 'product.dart';
import 'sub_category.dart';

class Variant {
  int id;
  String name;
  List<VariantValue> list = [];



  String? selected;

  Variant.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
  list = skuList(json['valueList']);

  static List<VariantValue> skuList(Iterable? iterable){
    if( iterable == null ) return [];

    return iterable.map((f)=>VariantValue.fromJson(f)).toList();
  }

}


class VariantValue{

  int id;
  String name;
  String? description;


  VariantValue.fromJson(Map<String, dynamic> json)
      :name = json['name'],
  id = json['id'],
        description = json['description'];
}

class VariantPrice{

  int id;
  String name;
  String? description;
  String? image;
  double price;
  int quantity;


  VariantPrice.fromJson(Map<String, dynamic> json)
      :name = json['name'],
        id = json['id'],
        quantity = json['quantity'],
        price = (json['price'] as num).toDouble(),
        description = json['description'];
}


class Extra{
  Category? category;
  SubCategory? subCategory;
  Product product;
  int likesCount;
  bool liked;
  Extra({this.category,this.subCategory,this.liked = false,this.likesCount = 0,required this.product});
}