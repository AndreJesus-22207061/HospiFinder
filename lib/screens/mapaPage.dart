import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
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
  late SnsRepository snsRepository;

  GoogleMapController? mapController;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpSnsDataSource = Provider.of<HttpSnsDataSource>(context);
    final connectivityModule = Provider.of<ConnectivityModule>(context);
    final sqfliteSnsDataSource = Provider.of<SqfliteSnsDataSource>(context);
    final locationModule = Provider.of<LocationModule>(context);
    snsRepository = SnsRepository(sqfliteSnsDataSource, httpSnsDataSource, connectivityModule,locationModule);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenToLocationUpdates();
      carregarHospitais();
    });
  }

  void listenToLocationUpdates() {
    snsRepository.locationModule.onLocationChanged().listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final newPosition = LatLng(locationData.latitude!, locationData.longitude!);
        setState(() {
          _currentPos = newPosition;
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
          ..._hospitalMarkers,
        },
        myLocationEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
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
