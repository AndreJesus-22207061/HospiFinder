
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/http/http_client.dart';
import 'package:provider/provider.dart';
import 'hospital_detail_page.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  Location _locationController = Location();
  static const LatLng _posRandom = LatLng(38.763973, -9.276104);

  LatLng? _currentPos = _posRandom;
  Set<Marker> _hospitalMarkers = {};

  @override
  void initState() {
    super.initState();
    getLocalizacaoUpdates();
    //carregarHospitais();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: _currentPos == null
      //     ? const Center(child: CircularProgressIndicator())
      //     : GoogleMap(
      //   initialCameraPosition: CameraPosition(
      //     target: _currentPos!,
      //     zoom: 13,
      //   ),
      //   markers: {
      //     // Marker azul para a localização atual
      //     Marker(
      //       markerId: const MarkerId("user_location"),
      //       position: _currentPos!,
      //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      //       infoWindow: const InfoWindow(title: "A minha localização"),
      //     ),
      //     ..._hospitalMarkers, // Markers vermelhos dos hospitais
      //   },
      // ),

      // Código temporário para evitar erros
      body: const Center(
        child: Text("Conteúdo do mapa comentado para testes."),
      ),
    );
  }

  Future<void> getLocalizacaoUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentPos = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  /*Future<void> carregarHospitais() async {
    try {
      List<Hospital> hospitais = await _snsRepository.getAllHospitals();

      Set<Marker> markersTemp = hospitais.map((hospital) {
        return Marker(
          markerId: MarkerId(hospital.id.toString()),
          position: LatLng(hospital.latitude, hospital.longitude),
          infoWindow: InfoWindow(
            title: hospital.name,
            snippet: hospital.address,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalDetailPage(hospitalId: hospital.id),
                ),
              );
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).toSet();

      setState(() {
        _hospitalMarkers = markersTemp;
      });
    } catch (e) {
      print('Erro ao carregar hospitais: $e');
    }
  }*/
}
