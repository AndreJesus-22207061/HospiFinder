import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {

  Location _locationController = new Location();
  static const LatLng _posRandom = LatLng(38.763973, -9.276104);
  static const LatLng _posRandom1 = LatLng(38.766871, -9.278568);

  LatLng? _currentPos = null;


  @override
  void initState() {
    super.initState();
    getLocalizacaoUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPos == null
          ? const Center(
        child: Text("Loading...", style: TextStyle(color: Colors.black)),
      )
          : GoogleMap(
        initialCameraPosition:
        CameraPosition(target: _posRandom, zoom: 15,
        ),
        markers: {
          Marker(markerId: MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,position: _posRandom1),
        },
      ),
    );
  }

  Future<void> getLocalizacaoUpdates() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;


    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled){
      _serviceEnabled = await _locationController.requestService();
    }else{
      return;
    }


    _permissionGranted = await _locationController.hasPermission();

    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await _locationController.requestPermission();

      if(_permissionGranted != PermissionStatus.granted){
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation){
      if(currentLocation.latitude!= null && currentLocation.longitude != null){
        setState(() {
          _currentPos = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(_currentPos);
        });
      }
    });
  }


}