import 'package:flutter/material.dart';
import 'package:vima_app/account_screen.dart';
import 'package:vima_app/cart_screen.dart';
import 'package:vima_app/home_screen.dart';
import 'package:vima_app/json/user.dart';
import 'package:vima_app/place_ad_screen.dart';
import 'package:vima_app/product_details.dart';
import 'package:vima_app/super_base.dart';
import 'package:vima_app/wish_list_screen.dart';

import 'life_cycle.dart';

class Homepage extends StatefulWidget{
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends Superbase<Homepage> {
  LifecycleEventHandler? eventHandler;

  void goToLogin(){

  }

  void refreshUser(User? user){
    setState(() {
      User.user = user;
    });
  }

  @override
  void initState() {
    eventHandler = LifecycleEventHandler(resumeCallBack: () {
      getSharedText();

      return Future.value();
    });
    WidgetsBinding.instance
        .addObserver(eventHandler!);
    super.initState();

  }


  void getSharedText()async{

    try{
      var deep = await platform.invokeMethod("deep-link");

      var done = false;
      if(deep != null){
        var uri = Uri.parse(deep);
        showMd();
        getDetails(int.parse(uri.pathSegments.last),error: closeMd,callback: (prices,values,extra){
          if(!done) {
            done = true;
            push(ProductDetails(product: extra.product), replace: true);
          }
        });
      }
    }catch(_){

    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(eventHandler!);
    super.dispose();
  }

  int _index = 0;

  var key0 = GlobalKey();
  var key1 = GlobalKey();
  var key2 = GlobalKey();
  var key3 = GlobalKey();
  var key4 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(key: key0,),
          WishListScreen(key: key1,),
          PlaceAdScreen(key: key2,),
          CartScreen(key: key3,),
          AccountScreen(key: key4,),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (index){
          setState(() {
            _index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border),label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline),label: "Place Ad"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart),label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.menu),label: "Menu"),
        ],
      ),
    );
  }
}