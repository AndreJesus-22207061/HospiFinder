import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_module.dart';

class GPSLocationModule extends LocationModule {
  final Location _location = Location();

  @override
  Stream<LocationData> onLocationChanged() {
    return _location.onLocationChanged;
  }

}
