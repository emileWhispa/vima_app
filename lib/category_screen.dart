import 'package:cached_network_image/cached_network_image.dart';
import 'json/category.dart';
import 'search_delegate.dart';
import 'sub_category_screen.dart';
import 'super_base.dart';
import 'wish_list_screen.dart';
import 'package:flutter/material.dart';

import 'search_screen.dart';

class CategoryScreen extends StatefulWidget{
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Superbase<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends Superbase<CategoryScreen>{
  
  List<Category> _categories = [];
  Category? selected;
  var focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadCategories();
    });

    focusNode.addListener(() {
      if(focusNode.hasFocus){
        focusNode.unfocus();
        showSearch(context: context, delegate: SearchDemoSearchDelegate((query){
          return SearchScreen(query: query);
        }));
      }
    });
  }

  void loadCategories(){
    ajax(url: "public/categories/all",server: false,onValue: (source,url){
      setState(() {
        _categories = (source['data'] as Iterable).map((e) => Category.fromJson(e)).toList();
        if(_categories.isNotEmpty){
          _categories.first.selected = true;
          selected = _categories.first;
        }
      });
    });
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        title: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextFormField(
              focusNode: focusNode,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  hintText: "Search product",
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(40)
                  ),
                  fillColor: const Color(0xfff5f6f8),
                  hintStyle: const TextStyle(
                      color: Color(0xffc8c8c8)
                  ),
                  prefixIcon: const Icon(Icons.search,size: 30,)
              ),
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            push(const WishListScreen());
          },color: Theme.of(context).colorScheme.secondary,iconSize: 30, icon: const Icon(Icons.favorite_border))
        ],
      ),
      body: Column(children: [
        Expanded(child: Row(
          children: [
            Expanded(child: Container(
              decoration: const BoxDecoration(
                color: Color(0xfff2f2f3)
              ),
              child: ListView.builder(padding: EdgeInsets.zero,itemCount: _categories.length,itemBuilder: (context,index){
                var item = _categories[index];
                return Container(
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: item.id == selected?.id ? Colors.white : null,
                    border: Border(
                      left: item.id == selected?.id ? BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 3
                      ) : BorderSide.none
                    )
                  ),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        selected = item;
                      });
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image(image: CachedNetworkImageProvider(item.icon),height: 35,
                            color: Theme.of(context).primaryColor,),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2).copyWith(bottom: 10),
                          child: Text(item.name,textAlign: TextAlign.center,style: const TextStyle(
                            fontSize: 12.5
                          ),),
                        )
                      ],
                    ),
                  ),
                );
              }),
            )),
            Expanded(flex: 3,child: selected == null ? const SizedBox.shrink() : SubCategoryScreen(category: selected!,),),
          ],
        ))
      ],),
    );
  }
}