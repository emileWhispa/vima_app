import 'package:flutter/material.dart';
import 'package:vima_app/authentication.dart';
import 'package:vima_app/job_registration.dart';
import 'package:vima_app/product_registration.dart';
import 'package:vima_app/super_base.dart';

class PlaceAdScreen extends StatefulWidget{
  const PlaceAdScreen({super.key});

  @override
  State<PlaceAdScreen> createState() => _PlaceAdScreenState();
}

class _PlaceAdScreenState extends Superbase<PlaceAdScreen> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loggedOut ? const Authentication() : Scaffold(
      appBar: AppBar(
        title: const Text("Advertisement"),
        bottom: TabBar(controller: controller,tabs: const [
          Tab(text: "Products"),
          Tab(text: "Jobs",)
        ]),
      ),
      body: TabBarView(controller: controller,children: [
        Center(),
        Center(),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: ()async {
        var data = await showDialog<String>(context: context, builder: (context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(onTap: (){
                  Navigator.pop(context,"product");
                },leading: const Icon(Icons.car_repair),title: const Text("Create Product"),),
                ListTile(onTap:(){
                  Navigator.pop(context,"job");
                },leading: const Icon(Icons.cases_rounded),title: const Text("Create Job"),),
              ],
            ),
          );
        });

        if(data == 'product'){
          push(const ProductRegistration());
        }else if(data == 'job'){
          push(const JobRegistration());
        }
      },child: const Icon(Icons.add),),
    );
  }
}

