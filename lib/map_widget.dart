import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vima_app/super_base.dart';

class MapWidget extends StatefulWidget {
  final String locationId;

  const MapWidget({super.key, required this.locationId});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends Superbase<MapWidget> {

  bool loading = true;


  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  LatLng? _latLng;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData();
    });
    super.initState();
  }

  void loadData() {
    ajax(
        url: "https://maps.googleapis.com/maps/api/place/details/json?placeid=${widget.locationId}&key=$mapKey",absolutePath: true,onValue: (s,v){
          var x = s['result']['geometry']['location'];
          setState(() {
            _latLng = LatLng(x['lat'], x['lng']);
            loading = false;
          });
    },error: (s,v)=>setState(() {
      loading = false;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Center(
      child: Padding(
        padding: EdgeInsets.all(25.0),
        child: CircularProgressIndicator(),
      ),
    ) : _latLng == null ? Center(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Text("Location Not found",style: Theme.of(context).textTheme.titleMedium,),
      ),
    ) : SizedBox(
      height: 400,
      width: double.infinity,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            bearing: 192.8334901395799,target: _latLng!,tilt: 59.440717697143555,
            zoom: 13.151926040649414),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

}
