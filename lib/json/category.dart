import 'sub_category.dart';

class Category {
  int? id;
  String name;
  String icon;

  List<SubCategory> subs = [];

  Category.fromJson(Map<String, dynamic> map)
      : name = map['name'],
        icon = map['image'],
        id = map['id'],
        subs = (map['subCategoryList'] as Iterable?)?.map((e) => SubCategory.fromJson(e)).toList() ?? [];

  Category(this.name, this.icon, {this.selected = false});

  bool selected = false;
}
