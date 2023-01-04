import 'dart:async';
import 'dart:io';

import 'address_detail_screen.dart';
import 'json/address.dart';
import 'json/cart.dart';
import 'json/order.dart';
import 'payment_modal.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';

import 'cart_item.dart';

class OrderDetailScreen extends StatefulWidget {
  final List<Cart> list;
  final bool buyNow;

  const OrderDetailScreen({Key? key, required this.list, this.buyNow = false}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends Superbase<OrderDetailScreen> {
  Address? _address;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getDefaultAddress().then((value){
        setState(() {
          _address = value;
        });

        if(value == null){
          getDefault();
        }
      });
    });
    super.initState();
  }

  void getDefault({bool server =false}) {
    ajax(
        url: "address/default",
        auth: true,
        server: server,
        onValue: (source, url) {
          var data = source['data'];
          if (data == null) return;
          setState(() {
            _address = Address.fromJson(data);
          });
        });
  }

  Order? _order;

  Future<Order?> createOrder()async{
    showMd();
    var complete = Completer<Order?>();
    await ajax(url: "order/create",method: "POST",map: widget.buyNow ? {
      "deliveryAddressId":_address?.addressId,
      "price":widget.list.first.price,
      "quantity":widget.list.first.quantity,
      "productId":widget.list.first.product.id,
      "specs":widget.list.first.desc,
    } : {
      "ids":widget.list.map((e) => e.id).toList(),
      "deliveryAddressId":_address?.addressId
    },onValue: (obj,url){
      setState(() {
        _order = Order.fromJson(obj['data']);
        complete.complete(_order);
      });
    },error: (s,v){

      complete.complete(null);
    });
    closeMd();
    return complete.future;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context,_order);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(title: Column(
          crossAxisAlignment: Platform.isAndroid ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            const Text("Complete Order",style: TextStyle(
              fontSize: 17
            ),),
            Text("${widget.list.length} products",style: const TextStyle(
              fontSize: 13
            ),)
          ],
        ),),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: widget.list.length + 1,
                  itemBuilder: (context, index) {
                    index = index - 1;

                    if (index < 0) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 6),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColorLight),
                            borderRadius: BorderRadius.circular(5)),
                        child: InkWell(
                          onTap: () async {
                            _address = await push(const AddressDetailScreen(
                              select: true,
                            ));
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          _address?.address ??
                                              "You Have No Address",
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: _address != null
                                            ? RichText(
                                                text: TextSpan(
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge
                                                            ?.color),
                                                    children: [
                                                    TextSpan(
                                                        text:
                                                            "(${_address!.delivery}) ",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold)),
                                                    TextSpan(
                                                        text: _address!.email),
                                                    TextSpan(
                                                        text:
                                                            " / ${_address!.phone}",
                                                        style: TextStyle(
                                                            color:
                                                                Theme.of(context)
                                                                    .primaryColor,
                                                            fontWeight:
                                                                FontWeight.bold)),
                                                  ]))
                                            : const Text(
                                                "Please Fill in The Address (Click it To Edit)"),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    var item = widget.list[index];
                    return CartItem(cart: item);
                  }),
            ),
            SafeArea(
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                      "(RWF ${fmtNbr(widget.list.fold<double>(0.0, (previousValue, element) => previousValue + element.total))})"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {

                          if(_address == null){
                            return showSnack("Select address to continue");
                          }


                          _order = _order ?? await createOrder();

                          if(_order == null){
                            return;
                          }

                          if(mounted){
                            showModalBottomSheet(context: context, builder: (context){
                              return PaymentModal(order: _order!,);
                            });
                          }


                        }, child: const Text("Complete Order")),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
