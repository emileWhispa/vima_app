import 'dart:async';

import 'success_screen.dart';
import 'super_base.dart';
import 'transaction_failed_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'json/order.dart';

class PaymentModal extends StatefulWidget {
  final Order order;

  const PaymentModal({Key? key, required this.order}) : super(key: key);

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends Superbase<PaymentModal> {
  String _mode = "momo";
  bool _sending = false;
  bool _loadingMomo = false;


  bool _success = false;
  bool _failed = false;
  
  

  void checkStatus(){
    setState(() {
      _loadingMomo = true;
    });
    ajax(url: "order/status/${widget.order.id}",server: true,onValue: (ob,v){
      if(ob['code'] == 1) {
        var order = Order.fromJson(ob['data']);
        if (order.status == "Pending") {
          Timer(const Duration(seconds: 5), checkStatus);
          Timer(const Duration(minutes: 5), () {
            if (_loadingMomo) {
              setState(() {
                _failed = true;
                _loadingMomo = false;
                _success = false;
              });
            }
          });
        } else if (order.status == "Paid") {
          setState(() {
            _success = true;
            _loadingMomo = false;
            _failed = false;
          });
        } else {
          setState(() {
            _failed = true;
            _loadingMomo = false;
            _success = false;
          });
        }
      }
    },error: (s,v){
      Timer(const Duration(seconds: 5), checkStatus);
    }
    );
  }


  Future<String?> getPhoneNumber()async{
    String? res;
    return await showDialog<String?>(context: context,builder: (context)=>AlertDialog(
      title: const Text("Enter Phone number"),
      content: TextFormField(initialValue: "250",onChanged: (s){
        res = s;
      },onFieldSubmitted: (s)=>Navigator.pop(context,s),),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("CANCEL")),
        TextButton(onPressed: ()=>Navigator.pop(context,res), child: const Text("OK")),
      ],
    ));
  }

  Future<void> complete() async {
    
    
    String? phone;
    if(_mode == 'momo'){
      phone = await getPhoneNumber();
      if(phone == null || validateMobile(phone) != null){
        showSnack("Enter phone number first");
        return Future.value();
      }
    }
    
    setState(() {
      _sending = true;
    });
    
    
    await ajax(url: "order/pay/${widget.order.id}?type=$_mode&phone=${Uri.encodeComponent(phone??"")}",method: "POST",onValue: (s,v){

      if(_mode != "momo") {
        Navigator.push(context,CupertinoPageRoute(builder: (context)=>WebViewPayment(order: widget.order, initialUrl: s['data'])));
      }
      else{
        setState((){
          _loadingMomo = true;
        });
        checkStatus();
      }
    },error: (s,v){

    });
    setState(() {
    _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loadingMomo
        ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          Text("Waiting for momo payment confirmation !",style: Theme.of(context).textTheme.headline6,),
        ),
        const CircularProgressIndicator(),
      ],
    ) : _success ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle,color: Colors.green,size: 80,),
        Text("Payment success",style: Theme.of(context).textTheme.headline6,)
      ],
    )  : _failed ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle,color: Colors.red,size: 80,),
        Text("Payment failed",style: Theme.of(context).textTheme.headline6,)
      ],
    ) : SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${fmtNbr(widget.order.list.length)} items",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      "RWF ${fmtNbr(widget.order.total)}",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.headline4!.color),
                    ),
                  ],
                )),
                Icon(
                  Icons.shopping_cart,
                  size: 50,
                  color: Theme.of(context).colorScheme.secondary,
                )
              ],
            ),
          ),
          Card(
            color:
                _mode == "k_pay" ? Theme.of(context).secondaryHeaderColor : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  _mode = "k_pay";
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/mastercard.png"),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Visa and Mastercard",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const Text("Pay"),
                          ],
                        ),
                      ),
                    ),
                    Radio(
                      onChanged: (String? v) {
                        setState(() {
                          _mode = v!;
                        });
                      },
                      value: "k_pay",
                      groupValue: _mode,
                      activeColor: Theme.of(context).colorScheme.secondary,
                    )
                  ],
                ),
              ),
            ),
          ),
          Card(
            color: _mode == "equity"
                ? Theme.of(context).secondaryHeaderColor
                : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  _mode = "equity";
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/mastercard.png"),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Pay in Installments",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const Text("Mastercard & Visa"),
                          ],
                        ),
                      ),
                    ),
                    Radio(
                        onChanged: (String? v) {
                          setState(() {
                            _mode = v!;
                          });
                        },
                        value: "equity",
                        groupValue: _mode,
                        activeColor: Theme.of(context).colorScheme.secondary)
                  ],
                ),
              ),
            ),
          ),
          Card(
            color: _mode == "momo"
                ? Theme.of(context).secondaryHeaderColor
                : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  _mode = "momo";
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/mtn_logo.jpeg"),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Mobile money",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const Text("Momo payments"),
                          ],
                        ),
                      ),
                    ),
                    Radio(
                        onChanged: (String? v) {
                          setState(() {
                            _mode = v!;
                          });
                        },
                        value: "momo",
                        groupValue: _mode,
                        activeColor: Theme.of(context).colorScheme.secondary)
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _sending
                ? Column(
                    children: const [
                      CircularProgressIndicator(),
                    ],
                  )
                : Row(
                    children: [
                      const Spacer(),
                      OutlinedButton(
                          onPressed: complete, child: const Text("Complete Payment")),
                    ],
                  ),
          ))
        ],
      ),
    );
  }
}


class WebViewPayment extends StatefulWidget{
  final Order order;
  final String initialUrl;
  const WebViewPayment({Key? key, required this.order,required this.initialUrl}) : super(key: key);


  @override
  State<WebViewPayment> createState() => _WebViewPaymentState();
}

class _WebViewPaymentState extends Superbase<WebViewPayment> {

  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (url) {
            if (url.contains("e-gura.com")) {
              showMd(context: context);

              ajax(url: "order/find/${widget.order.id}", onValue: (obj, url) {
                var mb = Order.fromJson(obj['data']);

                if (mb.status == "Paid") {
                  push(const SuccessScreen(), replaceAllExceptOne: true,context: context);
                }
                else if (mb.status == "Failed") {
                  push(const TransactionFailedScreen(),
                      replaceAllExceptOne: true,context: context);
                }
                else {
                  // closeMd();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  showSnack("Order not paid",context: context);
                }
              }, error: (s, v) {
                closeMd();
              });
            }
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        title: const Text("Complete payment"),
        titleTextStyle: Theme
            .of(context)
            .textTheme
            .titleLarge,
        iconTheme: IconThemeData(
            color: Theme
                .of(context)
                .textTheme
                .titleLarge
                ?.color
        ),
        elevation: 1.0,
      ),
      body: SafeArea(top: false, child: WebViewWidget(controller: controller)),
    );
  }
}