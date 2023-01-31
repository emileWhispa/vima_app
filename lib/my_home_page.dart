import 'package:flutter/material.dart';
import 'package:vima_app/account_screen.dart';
import 'package:vima_app/cart_screen.dart';
import 'package:vima_app/home_screen.dart';
import 'package:vima_app/json/user.dart';
import 'package:vima_app/place_ad_screen.dart';
import 'package:vima_app/wish_list_screen.dart';

class Homepage extends StatefulWidget{
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {

  void goToLogin(){

  }

  void refresh(User? user){
    setState(() {
      User.user = user;
    });
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