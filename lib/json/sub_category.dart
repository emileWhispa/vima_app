import 'job.dart';
import 'product.dart';

class SubCategory{
  int? id;
  String name;
  String? icon;

  SubCategory.fromJson(Map<String,dynamic> map):name = (map['name'] as String).trim(),id = map['id'],icon = map['image'];


  SubCategory(this.name,{this.selected=false});



  bool selected = false;

  bool loading = false;


  List<Product> products = [];
  List<Job> jobs = [];
}