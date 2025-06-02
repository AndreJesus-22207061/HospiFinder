import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_module.dart';

class GPSLocationModule extends LocationModule {
  final Location _location = Location();

  Future<void> _ensurePermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      await _location.requestPermission();
    }
  }

  @override
  Stream<LocationData> onLocationChanged() {
    return _location.onLocationChanged;
  }

  Future<LatLng> getCurretlocation() async {
    await _ensurePermissions();
    final location = await onLocationChanged().first;
    return LatLng(location.latitude ?? 0, location.longitude ?? 0);
  }
}
