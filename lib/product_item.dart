import 'package:cached_network_image/cached_network_image.dart';
import 'package:vima_app/json/product.dart';
import 'package:vima_app/product_details.dart';
import 'package:vima_app/super_base.dart';
import 'package:flutter/material.dart';

import 'add_cart_screen.dart';

class ProductItem extends StatefulWidget{
  final Product product;
  final double maxSize;
  const ProductItem({Key? key, required this.product, this.maxSize=200}) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends Superbase<ProductItem> {
  @override
  Widget build(BuildContext context) {
    return Card(clipBehavior: Clip.antiAliasWithSaveLayer,child: InkWell(
      onTap: (){
        push(ProductDetails(product: widget.product));
      },
      child: LayoutBuilder(
        builder: (context,constraints) {
          var img = Image(image: CachedNetworkImageProvider(widget.product.image),fit: BoxFit.cover,width: double.infinity,frameBuilder: frameBuilder,);
          Widget wd = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              constraints.maxHeight.isInfinite ? img : Expanded(child: img),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name,maxLines: 2,overflow: TextOverflow.ellipsis,),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text("RWF ${fmtNbr(widget.product.discount)}",maxLines: 1,overflow: TextOverflow.ellipsis,style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18
                      ),),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text("${widget.product.sold} Sold",style: TextStyle(
                              color: Colors.grey.shade500
                          ),),
                        ),
                        Container(
                          height: 30,
                          width: 30,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle
                          ),
                          child: InkWell(
                            onTap: (){
                              showModalBottomSheet(context: context, builder: (context){
                                return AddCartScreen(product: widget.product,);
                              });
                            },
                            child: Center(
                              child: Icon(Icons.shopping_cart,size: 15,color: Colors.grey.shade700,),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          );

          return constraints.maxWidth.isInfinite ? SizedBox(width: widget.maxSize,child: wd,) : wd;
        }
      ),
    ),);
  }
}