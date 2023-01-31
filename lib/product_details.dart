import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vima_app/authentication.dart';
import 'package:vima_app/json/category.dart';
import 'package:vima_app/json/product.dart';
import 'package:vima_app/json/user.dart';
import 'package:vima_app/map_widget.dart';
import 'package:vima_app/product_item.dart';
import 'package:vima_app/review_container.dart';
import 'package:vima_app/review_item.dart';
import 'package:vima_app/super_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';

import 'add_cart_screen.dart';
import 'json/review.dart';
import 'json/variant.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  Superbase<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends Superbase<ProductDetails> {
  List<VariantPrice>? prices;
  List<Variant> variants = [];

  List<Product> _related = [];
  List<Review> _reviews = [];
  bool canReview = false;

  bool _adding = false;

  bool _liked = false;
  int likesCount = 0;
  Category? _category;

  Future<void> addToLiked() async {
    if (User.user == null) {
      await push(Authentication(
        fromAdd: true,
        loginSuccessCallback: goBack,
      ));
      if (User.user == null) {
        showSnack("Login First !!");
        return Future.value();
      }
    }

    setState(() {
      _adding = true;
    });
    await ajax(
        url: "wish/add/${widget.product.id}",
        onValue: (s, v) {
          showSnack(s['message'] ?? "");
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
      getDetails(widget.product.id, callback: (pr, v, extra) {
        setState(() {
          prices = pr;
          variants = v;
          _category = extra.category;
          _liked = extra.liked;
          _reviews = extra.reviews ?? [];
          canReview= extra.canReview;
          likesCount = extra.likesCount;
        });
      });
      getRelated();
    });
    super.initState();
  }

  void getRelated() {
    ajax(
        url: "public/products/related/${widget.product.id}",
        onValue: (object, url) {
          setState(() {
            _related = (object['data'] as Iterable)
                .map((e) => Product.fromJson(e))
                .toList();
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
          IconButton(
              onPressed: () {
                Share.share(
                    webUrl("product/default/${widget.product.id}"));
              },
              icon: const Icon(Icons.share)),
          // IconButton(onPressed: (){}, icon: const Icon(Icons.shopping_cart)),
          //   PopupMenuButton(itemBuilder: (context)=>[])
        ],
      ),
      body: StaggeredGridView.countBuilder(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          itemCount: _related.length + 1,
          itemBuilder: (context, index) {
            index = index - 1;

            if (index < 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.product.images.isNotEmpty
                      ? Stack(
                          children: [
                            CarouselSlider.builder(
                                itemCount: widget.product.images.length,
                                itemBuilder: (context, index, ix) {
                                  var g = widget.product.images[index];
                                  return Image(
                                    image: CachedNetworkImageProvider(
                                      g.url,
                                    ),
                                    fit: BoxFit.cover,
                                    frameBuilder: frameBuilder,
                                  );
                                },
                                options: CarouselOptions(
                                    aspectRatio: 1,
                                    viewportFraction: 1,
                                    initialPage: widget.product.activeSlide,
                                    onPageChanged: (index, rsn) {
                                      setState(() {
                                        widget.product.activeSlide = index;
                                      });
                                    })),
                            Positioned.fill(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: widget.product.images
                                      .asMap()
                                      .map((k, v) => MapEntry(
                                          k,
                                          Container(
                                            height: 10,
                                            width: 10,
                                            margin:
                                                const EdgeInsets.only(right: 3),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: k ==
                                                        widget
                                                            .product.activeSlide
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                    : appGrey),
                                          )))
                                      .values
                                      .toList(),
                                ),
                              ),
                            )
                          ],
                        )
                      : Image(
                          image:
                              CachedNetworkImageProvider(widget.product.image),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "RWF ${fmtNbr(widget.product.discount)}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        widget.product.hasDiscount
                            ? Expanded(
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "RWF ${fmtNbr(widget.product.price)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontSize: 15,
                                                color: Colors.grey.shade400,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "-${widget.product.percentDiscountStr}%",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : const Spacer(),
                        _adding
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )),
                              )
                            : Column(
                                children: [
                                  InkWell(
                                      onTap: addToLiked,
                                      child: Icon(
                                        _liked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _liked
                                            ? Theme.of(context).primaryColor
                                            : null,
                                        size: 32,
                                      )),
                                  Text(
                                    fmtNbr(likesCount),
                                    style: const TextStyle(fontSize: 11),
                                  )
                                ],
                              )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.product.description ?? ""),
                  ),

                  _reviews.isNotEmpty ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ReviewItem(review: _reviews.first),
                        TextButton(onPressed: (){
                          showModalBottomSheet(context: context,clipBehavior: Clip.antiAliasWithSaveLayer,shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20)
                            )
                          ), builder: (context){
                            return ReviewContainer(list: _reviews,product: widget.product,canReview: canReview,);
                          });
                        }, child: Text("View all reviews (${_reviews.length})"))
                      ],
                    ),
                  ) : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            elevation: 1,
                                backgroundColor: appGrey
                              ),
                                icon: const Icon(Icons.mail),
                                onPressed: () {
                                launchUrlString("mail:${widget.product.email??""}");
                                },
                                label: const Text("Email"))),
                        const SizedBox(width: 5),
                        Expanded(
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                  elevation: 1,
                                  backgroundColor: Colors.red.shade800
                                ),
                                icon: const Icon(Icons.call),
                                onPressed: () {
                                  launchUrlString("tel:${widget.product.phone??""}");
                                },
                                label: const Text("Phone"))),
                      ],
                    ),
                  ),
                  widget.product.locationId != null
                      ? MapWidget(locationId: widget.product.locationId!)
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: variants
                          .where((element) => element.property)
                          .toList()
                          .asMap()
                          .map((key, e) {
                            var card = e.keyValue
                                ? Card(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                e.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: e.list
                                                      .asMap()
                                                      .map(
                                                          (key, value) =>
                                                              MapEntry(
                                                                  key,
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    decoration: BoxDecoration(
                                                                        border: key ==
                                                                                e.list.length - 1
                                                                            ? null
                                                                            : Border(bottom: BorderSide(color: Colors.grey.shade300))),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                Text(value.name)),
                                                                        Expanded(
                                                                            child:
                                                                                Text(
                                                                          value.description ??
                                                                              "",
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  )))
                                                      .values
                                                      .toList(),
                                                ),
                                              ),
                                            ])),
                                  )
                                : Card(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(e.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          Wrap(
                                            alignment: WrapAlignment.start,
                                            children: e.list
                                                .asMap()
                                                .map((key, ex) => MapEntry(
                                                    key,
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 2),
                                                      child: Chip(
                                                        label: Text(ex.name),
                                                      ),
                                                    )))
                                                .values
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                            return MapEntry(key, card);
                          })
                          .values
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _related.isNotEmpty
                          ? "Related products(${_related.length})"
                          : "",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ],
              );
            }

            return ProductItem(product: _related[index]);
          },
          staggeredTileBuilder: (index) =>
              StaggeredTile.fit(index == 0 ? 2 : 1)),
      bottomNavigationBar: _category?.allowCart == true
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                              elevation: 1,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return AddCartScreen(
                                        product: widget.product,
                                        variants: variants,
                                        prices: prices,
                                        buyNow: true);
                                  });
                            },
                            child: const Text("Buy Now"))),
                    const SizedBox(width: 5),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return AddCartScreen(
                                      product: widget.product,
                                      variants: variants,
                                      prices: prices,
                                    );
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15),
                                elevation: 1,
                                backgroundColor: appGrey),
                            child: const Text("Add To Cart"))),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
