import 'cart_item.dart';
import 'json/cart.dart';
import 'order_detail_screen.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class CartScreen extends StatefulWidget{
  const CartScreen({Key? key}) : super(key: key);

  @override
  Superbase<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends Superbase<CartScreen>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      key.currentState?.show();
    });
  }

  var key = GlobalKey<RefreshIndicatorState>();

  List<Cart> _list = [];

  Future<void> loadCart(){
    return ajax(url: "cart/list",onValue: (object,url){
      setState(() {
        _list = (object['data'] as Iterable).map((e) => Cart.fromJson(e)).toList();
      });
    });
  }

  bool selectMode = false;


  void refreshScreen(){
    key.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text("Cart(${_list.length})",style: Theme.of(context).textTheme.titleLarge,),
        // actions: [
        //   IconButton(onPressed: (){},color: Theme.of(context).colorScheme.secondary,iconSize: 30, icon: const Icon(Icons.search))
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              key: key,
              onRefresh: loadCart,
              child: ListView.separated(separatorBuilder: (context,index)=>const Divider(height: 1,),itemBuilder: (context,index){
                var item = _list[index];
                return CartItem(cart: item,selectionMode: selectMode,);
              }, itemCount: _list.length,),
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                selectMode ? Checkbox(value: _list.every((element) => element.selected), onChanged: (v){
                  setState(() {
                    for (var element in _list) {
                      element.selected = v!;
                    }
                  });
                }) :
                IconButton(onPressed: (){
                  setState(() {
                    selectMode = true;
                  });
                }, icon: const Icon(Feather.edit)),
                selectMode ? const Text("Select All") : const SizedBox.shrink(),
                const Spacer(),
                Text("(RWF ${fmtNbr(_list.fold<double>(0.0, (previousValue, element) => previousValue + element.total))})"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: () async {

                    if(!_list.any((element) => element.selected)){
                      setState(() {
                        selectMode = true;
                      });
                      return showSnack("Select items on list");
                    }
                    var list = _list.where((element) => element.selected).toList();
                    var order = await push(OrderDetailScreen(list: list));

                    if( order != null){
                      setState(() {
                        _list.removeWhere((xi) => list.any((x) => x.id == xi.id));
                      });
                    }
                  }, child: const Text("Complete Order")),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}