import 'json/product.dart';
import 'product_item.dart';
import 'super_base.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends Superbase<SearchScreen> {
  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.query != widget.query && widget.query.isNotEmpty) {
      search();
    }
  }

  bool searching = false;

  List<Product> _list = [];

  Future<void> search() async {
    setState(() {
      searching = true;
    });
    await ajax(
        url: "public/home/search?q=${Uri.encodeComponent(widget.query)}",
        onValue: (object, url) {
          setState(() {
            searching = false;
            _list = (object['data'] as Iterable)
                .map((e) => Product.fromJson(e))
                .toList();
          });
        });

    setState(() {
      searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: searching
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.8),
              itemCount: _list.length,
              itemBuilder: (context, index) {
                var product = _list[index];
                return ProductItem(product: product);
              }),
    );
  }
}
