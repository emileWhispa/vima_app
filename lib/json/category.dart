import 'sub_category.dart';

class Category {
  int? id;
  String name;
  String icon;
  bool job = false;
  bool allowCart = false;

  List<SubCategory> subs = [];

  Category.fromJson(Map<String, dynamic> map)
      : name = map['name'],
        icon = map['image'],
        id = map['id'],
        job = map['job'],
  allowCart = map['allowCart'],
        subs = (map['subCategoryList'] as Iterable?)?.map((e) => SubCategory.fromJson(e)).toList() ?? [];

  Category(this.name, this.icon, {this.selected = false});

  bool selected = false;
}
