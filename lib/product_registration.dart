import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:place_picker/place_picker.dart';
import 'package:vima_app/json/sub_category.dart';
import 'package:vima_app/json/variant.dart';
import 'package:vima_app/super_base.dart';

import 'json/category.dart';

class ProductRegistration extends StatefulWidget {
  const ProductRegistration({super.key});

  @override
  State<ProductRegistration> createState() => _ProductRegistrationState();
}

class _ProductRegistrationState extends Superbase<ProductRegistration> {
  List<Category> _list = [];

  List<Variant> _variants = [];
  List<Variant> _properties = [];

  Category? _category;
  SubCategory? _subCategory;
  File? _image;
  DateTime? _expireDate;

  bool _saving = false;
  final _key = GlobalKey<FormState>();
  LocationResult? _locationResult;
  final _nameController = TextEditingController();
  final _originalController = TextEditingController();
  final _discountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadCategories();
    });
    super.initState();
  }

  void loadCategories() {
    ajax(
        url: "public/categories/all",
        server: false,
        onValue: (source, url) {
          setState(() {
            _category = null;
            _subCategory = null;
            _list = (source['data'] as Iterable)
                .map((e) => Category.fromJson(e))
                .toList();
          });
        });
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }


  void create()async{

    if(_key.currentState?.validate()??false) {
      if (await _image?.exists() != true) {
        showSnack("File not found !");
        return;
      }


      setState(() {
        _saving = true;
      });
      await ajax(url: "user/create/product",
          method: "POST",
          data: FormData.fromMap({
            'file': await MultipartFile.fromFile(
                _image!.path),
            "expireDate":_expireDate?.toString(),
            "category.id":_subCategory?.id,
            "name":_nameController.text,
            "originalPrice":_originalController.text,
            "discountPrice":_discountController.text,
            "description":_descriptionController.text,
            "quantity":_quantityController.text,
            "files":[],
            "properties":jsonEncode(_properties),
            "variants":jsonEncode(_variants),
            "phone":_phoneController.text,
            "email":_emailController.text,
            "location":_locationResult?.name,
            "locationId":_locationResult?.placeId,
          }),onValue: (s,v){
            goBack();
          },error: (s,v){
            if(s is Map){
              showSnack(s['message']??"");
            }
          });
      setState(() {
        _saving = false;
      });
    }
  }

  void showPlacePicker() async {
    _locationResult = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker(mapKey)));

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Product"),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 15))),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                       Card(
                         clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: const EdgeInsets.only(bottom: 10, right: 10),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            image: _image != null ? DecorationImage(image: FileImage(_image!),fit: BoxFit.cover) : null
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.add_box_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FormField<File>(
                    builder: (field) {
                      var btn = OutlinedButton.icon(
                        onPressed: pickImage,
                        style: OutlinedButton.styleFrom(
                            side: field.hasError
                                ? BorderSide(
                                    color: Theme.of(context).colorScheme.error)
                                : null,
                            foregroundColor: field.hasError
                                ? Theme.of(context).colorScheme.error
                                : null,
                            padding: const EdgeInsets.all(10)),
                        label: const Text("Upload Product Image"),
                        icon: const Icon(Icons.cloud_upload_outlined),
                      );

                      return field.hasError
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                btn,
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    field.errorText!,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                        fontSize: 11.5),
                                  ),
                                )
                              ],
                            )
                          : btn;
                    },
                    initialValue: _image,
                    validator: (s) =>
                        _image == null ? "C.V Attachment is required !!" : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Product Name"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                            controller: _originalController,
                        decoration: const InputDecoration(labelText: "Price"),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                            controller: _discountController,
                        decoration:
                            const InputDecoration(labelText: "Discounted Price"),
                      )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<Category>(
                    value: _category,
                    onChanged: (v) {
                      setState(() {
                        _subCategory = null;
                        _category = v;
                      });
                    },
                    items: _list
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<SubCategory>(
                    value: _subCategory,
                    onChanged: (v) {
                      setState(() {
                        _subCategory = v;
                      });
                    },
                    items: _category?.subs
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    decoration: const InputDecoration(labelText: "Sub Category"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                        labelText: "Product Initial Quantity"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    maxLines: 5,
                    minLines: 4,
                    controller: _descriptionController,
                    decoration:
                        const InputDecoration(labelText: "Product Description"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FormField<LocationResult>(
                    builder: (field) {
                      var btn = OutlinedButton.icon(
                        onPressed: showPlacePicker,
                        style: OutlinedButton.styleFrom(
                            side: field.hasError
                                ? BorderSide(
                                color: Theme.of(context).colorScheme.error)
                                : null,
                            foregroundColor: field.hasError
                                ? Theme.of(context).colorScheme.error
                                : null,
                            padding: const EdgeInsets.all(10)),
                        label: const Text("Select product location"),
                        icon: const Icon(Icons.location_on),
                      );

                      return field.hasError
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          btn,
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 11.5),
                            ),
                          )
                        ],
                      )
                          : btn;
                    },
                    initialValue: _locationResult,
                    validator: (s) =>
                    _locationResult == null ? "C.V Attachment is required !!" : null,
                  ),
                ),
                const Text("Product Sku"),
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: OutlinedButton.icon(icon: const Icon(Icons.add),onPressed: (){
                        setState(() {
                          _variants.add(Variant("Color",[
                            VariantValue("Yellow", ""),
                            VariantValue("Green", ""),
                            VariantValue("Blue", ""),
                            VariantValue("Red", ""),
                            VariantValue("Purple", ""),
                            VariantValue("Orange", ""),
                            VariantValue("Pink", ""),
                            VariantValue("Black", ""),
                          ]));
                        });
                      }, label: const Text("COLOR")),
                    )),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: OutlinedButton.icon(icon: const Icon(Icons.add),onPressed: (){
                        setState(() {
                          _variants.add(Variant("Size",[
                            VariantValue("XS", ""),
                            VariantValue("S", ""),
                            VariantValue("M", ""),
                            VariantValue("L", ""),
                            VariantValue("XL", ""),
                            VariantValue("XLL", ""),
                          ]));
                        });
                      }, label: const Text("SIZE")),
                    )),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: OutlinedButton.icon(icon: const Icon(Icons.add),onPressed: ()async{

                        var str = await showTextEditor(context,title: "Add New SkuVar");
                        if(str != null){
                          setState(() {
                            _variants.add(Variant(str, []));
                          });
                        }
                      }, label: const Text("NEW")),
                    )),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _variants.asMap().map((key,e){
                    var addTap = InkWell(onTap: ()async{
                      var str = await showTextEditor(context,title: "Add New Sku Value");
                      if(str != null){
                        setState(() {
                          e.list.add(VariantValue(str, ""));
                        });
                      }
                    },child: const Icon(Icons.add));
                    return MapEntry(key, Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 40,
                              child: TextFormField(initialValue: e.name,onChanged: (s){
                                setState(() {
                                  e.name = s;
                                });
                              },decoration: const InputDecoration(
                                  labelText: "Sku name",
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15)
                              ),),
                            ),
                            e.list.isEmpty ? Center(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: addTap,
                            )) : Wrap(alignment: WrapAlignment.start,children: e.list.asMap().map((key,ex) {

                              Widget entry = Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Chip(onDeleted: (){
                                  setState(() {
                                    e.list.removeAt(key);
                                  });
                                },label: Text(ex.name),),
                              );

                              if(key == e.list.length-1){
                                entry = Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    entry,
                                    addTap,
                                  ],
                                );
                              }

                              return MapEntry(key, entry);
                            }).values.toList(),),
                            Center(child: TextButton.icon(onPressed: (){
                              setState(() {
                                _variants.remove(e);
                              });
                            }, label: const Text("Remove"),icon: const Icon(Icons.delete),style: TextButton.styleFrom(
                                foregroundColor: Colors.red
                            ),),)
                          ],
                        ),
                      ),
                    ));
                  }).values.toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _saving
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: create,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(15)),
                          child: const Text("Apply Now")),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
