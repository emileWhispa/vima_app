import 'package:flutter/material.dart';
import 'package:vima_app/json/sub_category.dart';
import 'package:vima_app/super_base.dart';

import 'json/category.dart';

class ProductRegistration extends StatefulWidget{
  const ProductRegistration({super.key});

  @override
  State<ProductRegistration> createState() => _ProductRegistrationState();
}

class _ProductRegistrationState extends Superbase<ProductRegistration> {

  List<Category> _list = [];

  Category? _category;
  SubCategory? _subCategory;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadCategories();
    });
    super.initState();
  }

  void loadCategories(){
    ajax(url: "public/categories/all",server: false,onValue: (source,url){
      setState(() {
        _category = null;
        _subCategory = null;
        _list = (source['data'] as Iterable).map((e) => Category.fromJson(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Product"),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 15)
          )
        ),
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Center(
              child: Stack(
                children: [
                  const Card(
                    margin: EdgeInsets.only(bottom: 10,right: 10),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Positioned(bottom: 0,right: 0,child: Icon(Icons.add_box_rounded,color: Theme.of(context).primaryColor,),)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Product Name"
              ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Price"
                    ),
                  )),
                  const SizedBox(width: 10,),
                  Expanded(child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Discounted Price"
                    ),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<Category>(
                value: _category,
                onChanged: (v){
                  setState(() {
                    _subCategory = null;
                    _category = v;
                  });
                },
                items: _list.map((e) => DropdownMenuItem(value: e,child: Text(e.name,overflow: TextOverflow.ellipsis,),)).toList(),
                decoration: const InputDecoration(
                    labelText: "Category"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<SubCategory>(
                value: _subCategory,
                onChanged: (v){
                  setState(() {
                    _subCategory = v;
                  });
                },
                items: _category?.subs.map((e) => DropdownMenuItem(value: e,child: Text(e.name,overflow: TextOverflow.ellipsis,),)).toList(),
                decoration: const InputDecoration(
                    labelText: "Sub Category"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                decoration: const InputDecoration(
                    labelText: "Product Initial Quantity"
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                maxLines: 5,
                minLines: 4,
                decoration: const InputDecoration(
                    labelText: "Product Description"
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}