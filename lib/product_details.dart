import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vima_app/authentication.dart';
import 'package:vima_app/json/product.dart';
import 'package:vima_app/json/user.dart';
import 'package:vima_app/product_item.dart';
import 'package:vima_app/super_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';

import 'add_cart_screen.dart';
import 'json/variant.dart';

class ProductDetails extends StatefulWidget{
  final Product product;
  const ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  Superbase<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends Superbase<ProductDetails>{

  List<VariantPrice>? prices;
  List<Variant>? variants;

  List<Product> _related = [];

  bool _adding = false;

  bool _liked = false;
  int likesCount = 0;
  
  Future<void> addToLiked() async {

    if(User.user == null){
      await push(Authentication(fromAdd: true,loginSuccessCallback: goBack,));
      if(User.user == null){
        showSnack("Login First !!");
        return Future.value();
      }
    }

    setState(() {
      _adding = true;
    });
    await ajax(url: "wish/add/${widget.product.id}",onValue: (s,v){
      showSnack(s['message']??"");
      setState(() {
        _liked = s['code'] == 200;
        likesCount += _liked ? 1 : -1;
      });
    });
    setState(() {
      _adding = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getDetails(widget.product.id,callback: (pr,v,extra){
        setState(() {
          prices = pr;
          variants = v;
          _liked = extra.liked;
          likesCount = extra.likesCount;
        });
      });
      getRelated();
    });
    super.initState();
  }

  void getRelated(){
    ajax(url: "public/products/related/${widget.product.id}",onValue: (object,url){
      setState(() {
        _related = (object['data'] as Iterable).map((e) => Product.fromJson(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: (){
            Share.share(url("public/products/details/${widget.product.id}"));
          }, icon: const Icon(Icons.share)),
          // IconButton(onPressed: (){}, icon: const Icon(Icons.shopping_cart)),
        //   PopupMenuButton(itemBuilder: (context)=>[])
        ],
      ),
      body: StaggeredGridView.countBuilder(padding: EdgeInsets.zero,crossAxisCount: 2,itemCount: _related.length+1, itemBuilder: (context,index){
        index = index - 1;

        if(index<0){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.product.images.isNotEmpty ? Stack(
                children: [
                  CarouselSlider.builder(itemCount: widget.product.images.length, itemBuilder: (context,index,ix){
                    var g = widget.product.images[index];
                    return Image(image: CachedNetworkImageProvider(
                      g.url,
                    ),fit: BoxFit.cover,frameBuilder: frameBuilder,);
                  }, options: CarouselOptions(
                      aspectRatio: 1,
                      viewportFraction: 1,
                      initialPage: widget.product.activeSlide,
                      onPageChanged: (index,rsn){
                        setState(() {
                          widget.product.activeSlide = index;
                        });
                      }
                  )),
                  Positioned.fill(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.product.images.asMap().map((k,v)=>MapEntry(k, Container(
                          height: 10,
                          width: 10,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: k == widget.product.activeSlide ? Theme.of(context).colorScheme.secondary : appGrey
                          ),
                        ))).values.toList(),
                      ),
                    ),
                  )
                ],
              ) : Image(image: CachedNetworkImageProvider(widget.product.image),),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("RWF ${fmtNbr(widget.product.discount)}",style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold
                    ),),
                    widget.product.hasDiscount ? Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Text("RWF ${fmtNbr(widget.product.price)}",style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough
                          ),),
                          const SizedBox(width: 5),
                          Text("-${widget.product.percentDiscountStr}%",style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),),
                        ],
                      ),
                    ) : const Spacer(),
                    _adding ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(height: 25,width: 25,child: CircularProgressIndicator(strokeWidth: 2,)),
                    ) : Column(
                      children: [
                        InkWell(onTap: addToLiked, child: Icon(_liked ? Icons.favorite : Icons.favorite_border,color: _liked ? Theme.of(context).primaryColor : null,size: 32,)),
                        Text(fmtNbr(likesCount),style: const TextStyle(
                            fontSize: 11
                        ),)
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.product.name,style: Theme.of(context).textTheme.titleLarge,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.product.description??""),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_related.isNotEmpty ? "Related products(${_related.length})" : "",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary
                ),),
              ),
            ],
          );
        }

        return ProductItem(product: _related[index]);
      }, staggeredTileBuilder:(index)=> StaggeredTile.fit(index == 0 ?2 : 1)),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:Row(
            children: [
              Expanded(child: ElevatedButton(style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                elevation: MaterialStateProperty.all(1)
              ),onPressed: (){

                showModalBottomSheet(context: context, builder: (context){
                  return AddCartScreen(product: widget.product,variants: variants,prices: prices,buyNow: true);
                });
              }, child: const Text("Buy Now"))),
              const SizedBox(width: 5),
              Expanded(child: ElevatedButton(onPressed: (){
                showModalBottomSheet(context: context, builder: (context){
                  return AddCartScreen(product: widget.product,variants: variants,prices: prices,);
                });
              },style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                  elevation: MaterialStateProperty.all(1),
                backgroundColor: MaterialStateProperty.all(appGrey)
              ), child: const Text("Add To Cart"))),
            ],
          ),
        ),
      ),
    );
  }
}