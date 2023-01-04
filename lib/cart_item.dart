import 'package:cached_network_image/cached_network_image.dart';
import 'json/cart.dart';
import 'product_details.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';

class CartItem extends StatefulWidget{
  final Cart cart;
  final bool selectionMode;
  const CartItem({Key? key, required this.cart, this.selectionMode=false}) : super(key: key);

  @override
  Superbase<CartItem> createState() => _CartItemState();
}

class _CartItemState extends Superbase<CartItem> {

  Cart get item =>widget.cart;


  Future<void> updateQty(Cart cart){
    return ajax(url: "cart/update/${cart.id}/${cart.quantity}",onValue: (s,v){

    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        push(ProductDetails(product: item.product));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 14),
        child: Row(
          children: [
            widget.selectionMode ? Checkbox(value: item.selected, onChanged: (v){
              setState(() {
                item.selected  = v!;
              });
            }) : const SizedBox.shrink(),
            Container(clipBehavior: Clip.hardEdge,decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade400,
                      offset: const Offset(0.4,0.6),
                      blurRadius: 2
                  )
                ]
            ),child: Image(image: CachedNetworkImageProvider(item.product.image),frameBuilder: frameBuilder,width: 80,fit: BoxFit.cover,)),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                  ),),
                  Container(decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5)
                  ),margin: const EdgeInsets.symmetric(vertical: 10),padding: const EdgeInsets.all(3),child: Text(item.desc,style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 13
                  ),)),

                  Row(
                    children: [
                      Expanded(
                        child: Text("RWF ${fmtNbr(item.total)}",style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700
                        ),),
                      ),
                      Container(
                        height: 23,
                        width: 23,
                        decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: InkWell(onTap:(){
                          if(item.quantity <= 1) return;
                          setState(() {
                            item.quantity--;
                            updateQty(item);
                          });
                        },child: const Center(child: Icon(Icons.remove,size: 15,))),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text("${item.quantity}",style: const TextStyle(
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
                            item.quantity++;
                            updateQty(item);
                          });
                        },child: const Center(child: Icon(Icons.add,size: 15,))),
                      ),
                    ],
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}