import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:vima_app/authentication.dart';
import 'package:vima_app/json/user.dart';
import 'package:vima_app/json/variant.dart';
import 'package:vima_app/super_base.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show IterableExtension;

import 'json/product.dart';

class AddCartScreen extends StatefulWidget{
  final Product product;
  final List<VariantPrice>? prices;
  final List<Variant>? variants;
  final bool buyNow;

  const AddCartScreen({Key? key, required this.product, this.prices, this.variants, this.buyNow = false}) : super(key: key);

  @override
  Superbase<AddCartScreen> createState() => _AddCartScreenState();
}

class _AddCartScreenState extends Superbase<AddCartScreen> {

  List<VariantPrice>? prices;
  List<Variant>? variants;

  bool loading = false;

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if(widget.variants == null || widget.prices == null) {
        setState(() {
          loading = true;
        });
        await getDetails(widget.product.id, callback: (pr, v,extra) {
          setState(() {
            loading = false;
            prices = pr;
            variants = v.where((element) => !element.property).toList();
          });
        });
        setState(() {
          loading = false;
        });
      }else{
        setState(() {
          variants = widget.variants?.where((element) => !element.property).toList();
          prices = widget.prices;
        });
      }
    });
    super.initState();
  }

  VariantPrice? get variant =>prices?.firstWhereOrNull((element) => variants?.map((e) => e.selected).join("/") == element.name);

  void addToCart()async{

    if(User.user == null){
      await push( Authentication(fromAdd: true,loginSuccessCallback: goBack,));

      if(User.user == null){
        showSnack("Login first");
        return;
      }

    }

    var price = variant?.price ?? widget.product.price;
    var desc = variants?.map((e) => e.selected).join("/")??"";

    if(widget.buyNow){
      // await push(OrderDetailScreen(list: [
      //   Cart(quantity, desc, price, widget.product, 0)
      // ],buyNow: true,));
      return;
    }

    setState(() {
      loading = true;
    });
    await ajax(url: "cart/add",method: "POST",data: FormData.fromMap({
      "product":widget.product.id,
      "description":desc,
      "price":price,
      "quantity":quantity,
    }),onValue: (object,url){
      goBack();
showSnack("Added To Cart");
    },error: (s,v){
    });
    setState(() {
      loading = false;
    });
  }

  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10),child: Image(image: CachedNetworkImageProvider(variant?.image ?? widget.product.image),width: 120,frameBuilder: frameBuilder,)),
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text("RWF ${fmtNbr(variant?.price ?? widget.product.discount)}",style: Theme.of(context).textTheme.titleLarge,),
                          const SizedBox(width: 10),
                          !widget.product.hasDiscount ? const SizedBox() : Text("RWF ${fmtNbr(widget.product.price)}",style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough
                          ),),
                        ],
                      ),
                      Text("In Stock. Only ${fmtNbr(variant?.quantity ?? widget.product.quantity)} Items left.",style: TextStyle(
                        color: Colors.grey.shade500
                      ),)
                    ],
                  ),
                ))
              ],
            ),

             Expanded(
              child: loading ? const Center(
                child: CircularProgressIndicator(),
              ) : ListView(
                children: variants?.map((e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(e.name,style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22
                      ),),
                    ),
                    Wrap(
                      children: e.list.map((ex) => GestureDetector(
                        onTap: (){
                          setState(() {
                            e.selected = ex.name;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 13),
                          decoration: BoxDecoration(
                              color: e.selected == ex.name ? Theme.of(context).colorScheme.secondary : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(7)
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 5).copyWith(top: 5),
                          child: Text(ex.name,style: TextStyle(
                            color: e.selected == ex.name ? Theme.of(context).colorScheme.onSecondary : null
                          ),),
                        ),
                      )).toList(),
                    ),
                  ],
                )).toList() ?? [],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text("Quantity",style: Theme.of(context).textTheme.titleLarge,)),
                  Container(
                    height: 23,
                    width: 23,
                    decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: InkWell(onTap: (){
                      if(quantity <= 1) return;
                      setState(() {
                        quantity--;
                      });
                    },child: const Center(child: Icon(Icons.remove,size: 15,))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("$quantity",style: const TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    height: 23,
                    width: 23,
                    decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: InkWell(onTap: (){
                      setState(() {
                        quantity++;
                      });
                    },child: const Center(child: Icon(Icons.add,size: 15,))),
                  ),
                ],
              ),
            ),

            loading ? const SizedBox.shrink() : ElevatedButton(onPressed: (){

              if(variants == null){
                return;
              }

              if(variants?.any((element) => element.selected == null) == true){
                showDialog(context: context, builder: (context)=>AlertDialog(
                  title: const Text("Alert"),
                  content: const Text("Select all options"),
                  actions: [
                    TextButton(onPressed: goBack, child: const Text("Ok")),
                  ],
                ));
                return;
              }


              addToCart();
            },style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
              elevation: MaterialStateProperty.all(1.0)
            ), child: Text(widget.buyNow ? "Buy Now" : "Add To Cart"),)
          ],
        ),
      ),
    );
  }
}