import 'package:flutter/material.dart';
import 'package:vima_app/sub_category_screen.dart';
import 'package:vima_app/super_base.dart';

import 'json/product.dart';

class MyProductScreen extends StatefulWidget{
  const MyProductScreen({super.key});

  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends Superbase<MyProductScreen> {

  List<Product> _list = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData();
    });
    super.initState();
  }

  Future<void> loadData(){
    return ajax(url: "user/products",onValue: (s,v){
      setState(() {
        _list = (s['data'] as Iterable).map((e) => Product.fromJson(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadData,
      child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),itemCount: _list.length, itemBuilder: (context,index){
        return ProductItem(pro: _list[index]);
      }),
    );
  }
}