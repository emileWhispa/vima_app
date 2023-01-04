import 'package:flutter/material.dart';
import 'package:vima_app/account_screen.dart';
import 'package:vima_app/home_screen.dart';
import 'package:vima_app/json/user.dart';
import 'package:vima_app/place_ad_screen.dart';

class Homepage extends StatefulWidget{
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {

  void goToLogin(){

  }

  void refresh(User? user){

  }


  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          Center(),
          PlaceAdScreen(),
          Center(),
          AccountScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.chat),label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.menu),label: "Menu"),
        ],
      ),
    );
  }
}