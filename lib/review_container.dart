import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vima_app/review_item.dart';
import 'package:vima_app/super_base.dart';

import 'json/product.dart';
import 'json/review.dart';

class ReviewContainer extends StatefulWidget{
  final List<Review> list;
  final Product product;
  final bool canReview;
  const ReviewContainer({super.key, required this.list, required this.product, required this.canReview});

  @override
  State<ReviewContainer> createState() => _ReviewContainerState();
}

class _ReviewContainerState extends Superbase<ReviewContainer> {

  int review = 0;
  final controller = TextEditingController();

  final _key = GlobalKey<FormState>();

  bool _loading = false;
  
  
  void submit()async{
    if(_key.currentState?.validate()??false){
      setState(() {
        _loading = true;
      });
      await ajax(url: "user/create/review",method: "POST",data: FormData.fromMap({
        "review":review,
        "product.id":widget.product.id,
        "description":controller.text,
      }),onValue: (s,v){
        setState(() {
          widget.list.add(Review.fromJson(s['data']));
          controller.text = "";
          review = 0;
        });
      });
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemCount: widget.list.length+1,itemBuilder: (context,index){

      index = index - 1;

      if(index<0){
        return widget.canReview ? Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200
          ),
          padding: const EdgeInsets.all(12),
          child: Form(key: _key,child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [
                FormField<int>(initialValue: review,validator: (s)=>review <= 0 ? "Check star above for rating" : null,builder: (s){
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [1,2,3,4,5].map((e) => InkWell(onTap: (){
                            setState(() {
                              review = e;
                            });
                          },child: Icon(e<=review ? Icons.star : Icons.star_border,color: s.hasError ? Theme.of(context).colorScheme.error : e<=review ? Theme.of(context).primaryColor : null,))).toList(),
                        ),
                        Text(s.errorText??"",style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.error),)
                      ],
                    ),
                  );
                }),
                TextFormField(controller: controller,validator: (s)=>s?.trim().isEmpty == true ? "Review required !!" : null,decoration: const InputDecoration(hintText: "Enter review comment"),minLines: 2,maxLines: 5,)
              ],)),
              _loading ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(child: CircularProgressIndicator()),
              ) : ElevatedButton(onPressed: submit, child: const Text("Submit"))
            ],
          )),
        ) : Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Icon(Icons.warning,size: 40,color: Theme.of(context).colorScheme.error,),
                Text("Not Allowed to review on this item unless you do a successful order on it.",textAlign: TextAlign.center,style: TextStyle(
                  color: Theme.of(context).colorScheme.error
                ),),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(12).copyWith(bottom: 0),
        child: ReviewItem(review: widget.list[index]),
      );
    });
  }
}