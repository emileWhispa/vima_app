import 'package:cached_network_image/cached_network_image.dart';
import 'json/category.dart';
import 'product_details.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';

import 'json/product.dart';
import 'json/sub_category.dart';

class SubCategoryScreen extends StatefulWidget{
  final Category category;
  const SubCategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends Superbase<SubCategoryScreen> {


  void loadPerCategory(SubCategory subCategory)async{
    await ajax(url: "public/products/category/${subCategory.id}",server: false,onValue: (s,v){
      subCategory.loading = false;
      subCategory.products = (s['data'] as Iterable).map((e) => Product.fromJson(e)).toList();
    });
    setState(() {
      subCategory.loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(padding: EdgeInsets.zero,itemCount: widget.category.subs.length,itemBuilder: (context,index){
      var item = widget.category.subs[index];
      return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.grey.shade200
                )
            )
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  var prev = item.selected;
                  for (var element in widget.category.subs) {element.selected=false;}
                  item.selected = !prev;
                  if(item.selected){
                    item.loading = true;
                    loadPerCategory(item);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(item.name,style: Theme.of(context).textTheme.titleMedium,overflow: TextOverflow.ellipsis,maxLines: 2,)),
                    Icon(item.selected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,color: Theme.of(context).colorScheme.secondary,)
                  ],
                ),
              ),
            ),
            item.selected ? SizedBox(
              height: 180,
              child: item.loading ? const Center(
                child: CircularProgressIndicator(),
              )  : item.products.isEmpty ? Center(child: Text("No Products found !",style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context)
                      .textTheme.headlineMedium?.color                    ),)) : ListView.builder(itemCount: item.products.length,scrollDirection: Axis.horizontal,itemBuilder: (context,index){
                var pro = item.products[index];
                return SizedBox(
                  width: 150,
                  child: InkWell(
                    onTap: (){
                      push(ProductDetails(product: pro));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffededed),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(10.0),
                          clipBehavior:Clip.antiAlias,
                          child: Image(image: CachedNetworkImageProvider(pro.image),fit: BoxFit.cover,frameBuilder: frameBuilder,width: double.infinity,),
                        )),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          child: Text(pro.name,textAlign: TextAlign.start,maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10,left: 10,right: 10),
                          child: Text("RWF ${fmtNbr(pro.discount)}",textAlign: TextAlign.start,maxLines: 1,overflow: TextOverflow.ellipsis,style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )
                      ],
                    ),
                  ),
                );
              }),
            )  : const SizedBox.shrink(),
          ],
        ),
      );
    });
  }
}