import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vima_app/authentication.dart';
import 'package:vima_app/my_home_page.dart';
import 'package:vima_app/product_details.dart';
import 'package:vima_app/super_base.dart';

import 'json/user.dart';
import 'life_cycle.dart';
import 'navigation_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        tabBarTheme: const TabBarTheme(
          unselectedLabelColor: Colors.black87,
          labelColor: Colors.black87
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2.0,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black87),
          toolbarTextStyle: TextStyle(color: Colors.black87),
          iconTheme: IconThemeData(
            color: Colors.black87
          )
        )
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends Superbase<MyHomePage> {

  bool loading = true;
  LifecycleEventHandler? eventHandler;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var string = (await prefs).getString("user");
      if(string != null){
        Superbase.tokenValue = (await prefs).getString("token");
          User.user = User.fromJson(jsonDecode(string));
          goHome();
      }else{
        setState(() {
          loading = false;
        });
      }
    });

    eventHandler = LifecycleEventHandler(resumeCallBack: () {
      getSharedText();

      return Future.value();
    });

    WidgetsBinding.instance
        .addObserver(eventHandler!);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(eventHandler!);
    super.dispose();
  }

  void goHome(){
    push(Homepage(key: NavigationHelper.key,),replaceAll: true);
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
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: loading ? const Center(child: CircularProgressIndicator(),) : ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Image.asset("assets/logo.png"),
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Find your home in Rwanda",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff006C93)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Explore over 20,000 homes and find exactly what you are looking for with the help of  1000+trusted agents",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff3287C2)
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: OutlinedButton(onPressed: () {
                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=>Homepage(key: NavigationHelper.key,)));
              },style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 15),
                  side: const BorderSide(
                      color: Color(0xff3287C2)
                  ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: const Color(0xff3287C2),
                textStyle: const TextStyle(fontWeight: FontWeight.w700,fontSize: 16),
              ), child: const Text("Get Started")),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextButton(onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context)=> Authentication(loginSuccessCallback: goHome,)));
              },style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 15),
                foregroundColor: const Color(0xff3287C2),
                textStyle: const TextStyle(fontWeight: FontWeight.w700,fontSize: 16),
              ), child: const Text("Sign In")),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
