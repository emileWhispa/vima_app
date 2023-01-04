import 'dart:io';

import 'payment_modal.dart';
import 'product_item.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';

import 'json/order.dart';

class OrderHistoryScreen extends StatefulWidget{
  final String? status;
  const OrderHistoryScreen({Key? key, this.status}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends Superbase<OrderHistoryScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>refreshList());
    super.initState();
  }


  void refreshList()=>_key.currentState?.show();

  final _key = GlobalKey<RefreshIndicatorState>();

  List<Order> _list = [];
  
  Future<void> loadData(){
    return ajax(url: "order/list?status=${widget.status??""}",onValue: (source,url){
      setState(() {
        _list = (source['data'] as Iterable?)?.map((e) => Order.fromJson(e)).toList() ?? [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: Platform.isAndroid ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
             Text(widget.status ?? "My Orders",style: const TextStyle(
                fontSize: 17
            ),),
            Text("${_list.length} products",style: const TextStyle(
                fontSize: 13
            ),)
          ],
        ),
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: loadData,
        child: _list.isEmpty ? Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(50.0).copyWith(left: 100),
                child: Image.asset("assets/empty.png"),
              ),
              Text("No Orders found !",style: Theme.of(context).textTheme.headline6,textAlign: TextAlign.center,)
            ],
          ),
        ) : ListView.builder(itemCount: _list.length,itemBuilder: (context,index){
          var item = _list[index];
          return Card(
            elevation: 3.0,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text("Date: "),
                        Text(fmtDate(item.dateTime),style: const TextStyle(
                          fontWeight: FontWeight.bold
                        ),),
                        const Spacer(),
                        Container(decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(5)
                        ),padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),child: Text(item.status,))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 320,
                    child: item.list.isEmpty ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Image.asset("assets/empty.png"),
                      ),
                    ) : ListView.builder(scrollDirection: Axis.horizontal,itemCount: item.list.length,itemBuilder: (context,index){
                      var sub = item.list[index];
                      return ProductItem(product: sub.product);
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("RWF ${fmtNbr(item.total)}",style: Theme.of(context).textTheme.subtitle2,),
                      ),
                      const SizedBox(width: 10),
                      item.status == "Pending" ?ElevatedButton(onPressed: () async {
                        await showModalBottomSheet(context: context, builder: (context){
                          return PaymentModal(order: item);
                        });
                        refreshList();
                      }, child: const Text("Pay Now")) : const SizedBox.shrink()
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}