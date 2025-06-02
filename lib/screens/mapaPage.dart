
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
  static const LatLng _posRandom = LatLng(38.75799917281845, -9.15307308768478);
  LatLng? _currentPos = _posRandom;
  Set<Marker> _hospitalMarkers = {};

  late final SnsRepository snsRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      snsRepository = Provider.of<SnsRepository>(context, listen: false);
      listenToLocationUpdates();
      carregarHospitais();
    });
  }

  void listenToLocationUpdates() {
    snsRepository.locationModule.onLocationChanged().listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentPos = LatLng(locationData.latitude!, locationData.longitude!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPos == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPos!,
          zoom: 13,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("user_location"),
            position: _currentPos!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: "A minha localização"),
          ),
          ..._hospitalMarkers,
        },
      ),
    );
  }

  Future<void> carregarHospitais() async {
    try {
      final hospitais = await snsRepository.getAllHospitals();

      final markersTemp = hospitais.map((hospital) {
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
  }
}
