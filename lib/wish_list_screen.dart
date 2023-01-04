import 'json/product.dart';
import 'product_item.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';

class WishListScreen extends StatefulWidget{
  const WishListScreen({Key? key}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends Superbase<WishListScreen> {

  final _key = GlobalKey<RefreshIndicatorState>();

  List<Product> _list = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _key.currentState?.show();
    });
  }


  Future<void> loadData(){
    return ajax(url: "wish/list",onValue: (s,v){
      setState(() {
        _list = (s['data'] as Iterable).map((e) => Product.fromJson(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wish List"),
      ),
      body: RefreshIndicator(key: _key,onRefresh:loadData,
      child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8
      ),itemBuilder: (context,index){
        return ProductItem(product: _list[index]);
      },itemCount: _list.length,)),
    );
  }
}