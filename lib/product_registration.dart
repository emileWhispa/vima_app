import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final List<Variant> _variants = [];
  final List<Variant> _properties = [];

  Category? _category;
  SubCategory? _subCategory;
  File? _image;
  List<File> _images = [];
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
            .where((element) => !element.job)
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


  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final List<XFile> image = await picker.pickMultiImage();

    setState(() {
      _images = image.map((e) => File(e.path)).toList();
    });
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
            "files":_images.map((e) => MultipartFile.fromFileSync(e.path)).toList(),
            "properties":jsonEncode(_properties),
            "variants":jsonEncode(_variants),
            "phone":_phoneController.text,
            "email":_emailController.text,
            "location":_locationResult?.name,
            "locationId":_locationResult?.placeId,
          }),onValue: (s,v){
            goBack();
            showSnack(s['message']??"");
          },error: (s,v){
            if(s is Map){
              showSnack(s['message']??"");
            }else{
               showSnack("$s");
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
                        child: InkWell(
                          onTap: pickImage,
                          child: Icon(
                            Icons.add_box_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
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
                    validator: (s)=>s?.trim().isEmpty == true ? "Name is required !!!" : null,
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
                            validator: (s)=>s?.trim().isEmpty == true ? "Price is required !!!" : null,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Price"),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            validator: (s)=>s?.trim().isEmpty == true ? "Discounted price is required !!!" : null,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
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
                    validator: (s)=>s == null ? "Category is required !!!" : null,
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
                    validator: (s)=>s == null ? "Sub Category is required !!!" : null,
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
                    validator: (s)=>s?.trim().isEmpty == true ? "Quantity is required !!!" : null,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Product Initial Quantity"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: _emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Contact email"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: _phoneController,
                    validator: validateMobile,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Contact email"),
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
                  child: FormField<List<File>>(
                    builder: (field) {
                      var btn = OutlinedButton.icon(
                        onPressed: pickImages,
                        style: OutlinedButton.styleFrom(
                            side: field.hasError
                                ? BorderSide(
                                color: Theme.of(context).colorScheme.error)
                                : null,
                            foregroundColor: field.hasError
                                ? Theme.of(context).colorScheme.error
                                : null,
                            padding: const EdgeInsets.all(10)),
                        label: const Text("Gallery Images for this (max 15)"),
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
                    initialValue: _images,
                    validator: (s) =>
                    _images.isEmpty ? "At least one gallery image is required !!" : null,
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
                    _locationResult == null ? "Location is required !!" : null,
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

                const Text("House Property Info"),
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: OutlinedButton.icon(icon: const Icon(Icons.add),onPressed: (){
                        setState(() {
                          _properties.add(Variant("Amenities",[
                            VariantValue("Cleaning Included", ""),
                            VariantValue("Free Parking", ""),
                            VariantValue("Kitchen Appliances", ""),
                            VariantValue("Recreation Centre", ""),
                            VariantValue("Sauna", ""),
                            VariantValue("Swimming Pool", ""),
                            VariantValue("Washer", ""),
                            VariantValue("Black", ""),
                          ],property: true));
                        });
                      }, label: const Text("AMENITIES")),
                    )),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: OutlinedButton.icon(icon: const Icon(Icons.add),onPressed: (){
                        setState(() {
                          _properties.add(Variant("Property Info",[
                            VariantValue("Room For Rent", "Apartment"),
                            VariantValue("Room Type", "Private Room"),
                            VariantValue("Attached Bathroom", "No"),
                            VariantValue("Balcony", "No"),
                            VariantValue("Preferred Tenants", "Don't Mind"),
                          ],keyValue: true,property: true));
                        });
                      }, label: const Text("HOUSE INFO")),
                    )),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _properties.asMap().map((key,e){
                    var addTap = InkWell(onTap: ()async{
                      var str = await showTextEditor(context,title: "Add New Sku Value");
                      if(str != null){
                        setState(() {
                          e.list.add(VariantValue(str, ""));
                        });
                      }
                    },child: const Icon(Icons.add));
                    var card = e.keyValue ? Card(
                      margin: const EdgeInsets.only(bottom: 6),child: Padding(
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
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300
                                ),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              margin: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: e.list.asMap().map((key, value) => MapEntry(key, Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: key == e.list.length-1 ? null : Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300
                                      )
                                    )
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(value.name)),
                                      Expanded(child: Text(value.description??"",style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                      ),)),
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            e.list.removeAt(key);
                                          });
                                        },
                                        child: const Icon(Icons.delete,color: Colors.red,),
                                      )
                                    ],
                                  ),
                                ))).values.toList(),
                              ),
                            ),
                            Center(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: addTap,
                            )),
                            Center(child: TextButton.icon(onPressed: (){
                              setState(() {
                                _properties.removeAt(key);
                              });
                            }, label: const Text("Remove"),icon: const Icon(Icons.delete),style: TextButton.styleFrom(
                                foregroundColor: Colors.red
                            ),),)
                          ])),
                    ) : Card(
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
                                _properties.removeAt(key);
                              });
                            }, label: const Text("Remove"),icon: const Icon(Icons.delete),style: TextButton.styleFrom(
                                foregroundColor: Colors.red
                            ),),)
                          ],
                        ),
                      ),
                    );
                    return MapEntry(key, card);
                  }).values.toList(),
                ),
                const Text("More Property Info"),
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: OutlinedButton.icon(icon: const Icon(Icons.add),onPressed: (){
                        setState(() {
                          _properties.add(Variant("Color",[],property: true));
                        });
                      }, label: const Text("PROPERTY")),
                    )),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: OutlinedButton.icon(icon: const Icon(Icons.add),onPressed: (){
                        setState(() {
                          _variants.add(Variant("Property",[],keyValue: true,property: true));
                        });
                      }, label: const Text("KEY & VALUE")),
                    )),
                  ],
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
