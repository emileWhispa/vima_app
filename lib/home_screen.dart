import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vima_app/json/category.dart';
import 'package:vima_app/json/product.dart';
import 'package:vima_app/product_details.dart';
import 'package:vima_app/super_base.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends Superbase<HomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp){
      loadData();
    });
    super.initState();
  }

  Future<void> loadData() async {
    await loadCategories();
    return loadProducts();
  }

  List<Category> _list = [];

  List<Product> _products = [];


  Future<void> loadProducts(){
    return ajax(url: "public/products/all?pageSize=40",onValue: (obj,url){
      setState(() {
        _products = (obj['data'] as Iterable).map((e) => Product.fromJson(e)).toList();
      });
    });
  }

  Future<void> loadCategories() {
    return ajax(
        url: "public/categories/general",
        localSave: true,
        server: false,
        onValue: (obj, url) {
          setState(() {
            _list = (obj['data']['categories'] as Iterable)
                .map((e) => Category.fromJson(e))
                .toList();
            if (_list.length > 9) {
              _list = _list.sublist(0, 9);
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(12)
              .copyWith(top: MediaQuery.of(context).padding.top),
          children: [
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  decoration: InputDecoration(
                      hintText: "What are you looking for ?",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15)),
                )),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.notifications))
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {}, child: const Text("View All Categories")),
            ),
            GridView(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  crossAxisCount: 3),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _list
                  .map((e) => Card(
                margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image(
                                  image: CachedNetworkImageProvider(e.icon),
                                  color: Theme.of(context).primaryColor,
                                ),
                              )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  e.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    height: 120,
                    width: 120,
                    child: Icon(
                      Icons.verified,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Became a verified user",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text("Build Trust\nUnlock exclusive Rewards"),
                        TextButton(onPressed: () {}, child: const Text("Get Started"))
                      ],
                    ),
                  )),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.arrow_forward))
                ],
              ),
            ),
            Row(
              children: [
                const Expanded(child: Text("Recommended For You")),
                IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_forward))
              ],
            ),
            SizedBox(
              height: 350,
              child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context,index){
                    var pro = _products[index];
                    return Card(clipBehavior: Clip.antiAliasWithSaveLayer,child: InkWell(
                      onTap: (){
                        push(ProductDetails(product: pro));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Image(image: CachedNetworkImageProvider(pro.image),fit: BoxFit.cover,width: double.infinity,)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${fmtNbr(pro.price)} RWF",style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                                ),),
                                Text(pro.name,style: Theme.of(context).textTheme.bodyLarge,maxLines: 1,overflow: TextOverflow.ellipsis,),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),);
                  }),
            )
          ],
        ),
      ),
    );
  }
}
