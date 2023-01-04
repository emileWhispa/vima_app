import 'super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'create_address_info.dart';
import 'json/address.dart';

class AddressDetailScreen extends StatefulWidget{
  final Address? defaultAd;
  final bool select;
  const AddressDetailScreen({Key? key, this.defaultAd, this.select=false}) : super(key: key);

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends Superbase<AddressDetailScreen> {
  List<Address> _list = [];

  Address? _address;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _address = widget.defaultAd;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
      getDefault(server: widget.defaultAd != null);
    });
  }

  void load(){
    refreshKey.currentState?.show(atTop: true);
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();


  void _deletePop(Address address)async{
    showCupertinoModalPopup(context: context, builder: (context)=>CupertinoAlertDialog(
      title: const Text("Confirm To Delete"),
      content: const Text("Delete This Address ?"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text("Cancel"),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: (){
            Navigator.pop(context);
            _delete(address);
          },
          child: const Text("Confirm"),
        )
      ],
    ));
  }

  void getDefault({bool server =false}) {
    ajax(
        url: "address/default",
        auth: true,
        server: server,
        onValue: (source, url) {
          var data = source['data'];
          if (data == null) return;
          setState(() {
            _address = Address.fromJson(data);
          });
        });
  }

  Future<void> loadAddresses() {
    return ajax(
        url: "address/list?load-ad",
        auth: true,
        onValue: (source, url) {
          Iterable? map = source['data'];
          if (map != null) {
            setState(() {
              _list = map.map((json) => Address.fromJson(json)).toList();
              if( _list.isNotEmpty ){
                setDefaultAddressIfEmpty(address!);
              }
            });
          }
        });
  }

  void _newAddress() async {
    Address? address =
    await push(const CreateAddressInfo(
    ));
    if (address != null) {
      setState(() {
        _list.add(address);
      });
      load();
    }
  }

  void _delete(Address address) {
    setState(() {
      address.sending = true;
    });
    ajax(
        url: "address/delete/${address.addressId}",
        method: "DELETE",
        server: true,
        auth: true,
        onValue: (source, url) {
          setState(() {
            _list.removeWhere((f) => f.addressId == address.addressId);

          });
          load();
        },
        error: (source, url) {

        },
        onEnd: () {
          setState(() {
            address.sending = false;
          });
        });
  }

  void _setDefault(Address address) {
    setState(() {
      address.sending = true;
      setDefaultAddress(address);
    });
    ajax(
        url: "address/default/${address.addressId}",
        method: "PUT",
        server: true,
        auth: true,
        onValue: (source, url) {
          setState(() {
            _address = address;
          });
          if(widget.select){
            Navigator.of(context).pop(address);
          }else {
            load();
            getDefault();
          }
        },
        error: (source, url) {

        },
        onEnd: () {
          setState(() {
            address.sending = false;
          });
        });
  }

  int _selected = 0;

  bool _select = false;

  Address? get address => _address ?? (_list.isNotEmpty ? _selected < _list.length ? _list[_selected] : _list.first : null);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: ()async{

        Navigator.pop(context,address);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Address"),
          centerTitle: true,
          actions: <Widget>[
            _list.isEmpty
                ? const SizedBox.shrink()
                : _select
                ? TextButton(
                onPressed: () {
                  setState(() {
                    _select = false;
                  });
                },
                child: Text("Complete",style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.headline6?.color
                ),))
                : IconButton(
                onPressed: () {
                  setState(() {
                    _select = true;
                  });
                },
                icon: const Icon(Feather.edit))
          ],
        ),
        backgroundColor: Colors.grey.shade200,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  key: refreshKey,
                  onRefresh: loadAddresses,
                  child: _list.isNotEmpty
                      ? ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      var ad = _list[index];
                      var dip = Text(ad.address);
                      var cont = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      ad.delivery,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        ad.phone,
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _address?.addressId == ad.addressId ? Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red.shade200,
                                          borderRadius: BorderRadius.circular(3)
                                      ),
                                      padding: const EdgeInsets.all(2.5),
                                      child: const Text("default",style: TextStyle(color: Colors.red),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: dip,
                                    )
                                  ],
                                ) : dip,
                              ],
                            ),
                          ),
                          _select
                              ? ad.sending
                              ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CupertinoActivityIndicator(),
                          )
                              : InkWell(
                              onTap: () => _deletePop(ad),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 17,
                              ))
                              : InkWell(onTap: ()async{
                                push(CreateAddressInfo(address: ad,));
                            load();
                          },child: Image.asset("assets/account_edit.png",height: 20))
                        ],
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColorLight),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white.withOpacity(0.4)),
                        child: _address?.addressId == ad.addressId ? cont : Column(
                          children: <Widget>[
                            cont,
                            const SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                ad.sending ? const CupertinoActivityIndicator() : InkWell(
                                  onTap: () async {
                                    setState(() {
                                      _selected = index;
                                    });
                                    _setDefault(ad);
                                    return;
                                  },
                                  child: Container(height: 24,width: 24,decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.shade400)
                                  ),),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left:8.0),
                                  child: Text("Set to the default address"),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    itemCount: _list.length,
                  )
                      : ListView(
                    children: <Widget>[
                      const SizedBox(height: 90),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          children: const <Widget>[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(left: 50.0),
                                child: Image(
                                  image: AssetImage("assets/empty.png"),
                                  height: 170,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text("It Was Empty"),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: CupertinoButton(
                      borderRadius: BorderRadius.circular(4),
                      padding: EdgeInsets.zero,
                      child: const Text(
                        "Add A New Address",
                        style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w800),
                      ),
                      onPressed: _newAddress,color: Theme.of(context).primaryColor,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}