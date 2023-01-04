
import 'super_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'json/address.dart';


class CreateAddressInfo extends StatefulWidget {
  final Address? address;
  const CreateAddressInfo({Key? key, this.address}) : super(key: key);

  @override
  Superbase<CreateAddressInfo> createState() => _CreateAddressInfoState();
}

class _CreateAddressInfoState extends Superbase<CreateAddressInfo> {
  final TextEditingController _address =  TextEditingController();
  final TextEditingController _delivery =  TextEditingController();
  final TextEditingController _phone =  TextEditingController();
  final TextEditingController _email =  TextEditingController();
  var formKey = GlobalKey<FormState>();
  var _saving = false;

  String get phone => _phone.text;

  @override
  void initState() {
    super.initState();
    if(widget.address != null){
      _address.text = widget.address!.address;
      _delivery.text = widget.address!.delivery;
      _phone.text = widget.address!.phone;
      _email.text = widget.address!.email;
    }
  }

  void _saveAddress() {
    setState(() {
      _saving = true;
    });
    ajax(
        url: "address/create",
        method: "POST",
        auth: true,
        server: true,
        map: {
          "addressDetail": _address.text,
          "deliveryName": _delivery.text,
          "email": _email.text,
          "id": widget.address?.addressId,
          "phone": phone
        },
        onValue: (source, url) {
          if (source['code'] == 1) {
            var address = Address.fromJson(source['data']);
            Navigator.of(context).pop(address);
            //setDefaultAddress(address);
          } else {
            _showSnack(source['message']);
          }
        },
        error: (source, url) {
          _showSnack(source['message']);
        },
        onEnd: () {
          setState(() {
            _saving = false;
          });
        });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                })
            : null,
        title: const Text("Address"),
        centerTitle: true,
        actions: <Widget>[
          _saving
              ? IconButton(icon: loadBox(color: Theme.of(context).primaryTextTheme.titleLarge?.color), onPressed: null)
              : IconButton(
                  onPressed: () {
                    if (formKey.currentState?.validate()??false) {
                      _saveAddress();
                    }
                  },
                  icon: const Icon(Feather.send))
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(7),
          children: <Widget>[
            TextFormField(
              controller: _address,
              validator: (s) => s!.isEmpty ? "Field required !!" : null,
              decoration: const InputDecoration(
                  hintText: "Address",
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
            TextFormField(
              controller: _delivery,
              validator: (s) => s?.isNotEmpty == true  ? null : "Field required !!",
              decoration: const InputDecoration(
                  hintText: "Delivery name",
                  fillColor: Colors.white,
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
            Container(
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _phone,
                      validator: validateMobile,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                          hintText: "Phone number",
                          hintStyle: TextStyle(color: Colors.grey),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
            TextFormField(
              controller: _email,
              validator: (s)=>emailExp.hasMatch(s!) ? null : "Valid email is required",
              decoration: const InputDecoration(
                  hintText: "Email",
                  fillColor: Colors.white,
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
