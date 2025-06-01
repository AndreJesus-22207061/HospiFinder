import 'package:location/location.dart';
import 'location_module.dart';

class GPSLocationModule extends LocationModule {
  final Location _location = Location();

  late final Future<void> initialized;

  GPSLocationModule() {
    // Expõe a inicialização para aguardar de fora
    initialized = _init();
  }

  Future<void> _init() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização não está ativado');
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted) {
      throw Exception('Permissão para localização não concedida');
    }
  }

  @override
  Stream<LocationData> onLocationChanged() async* {
    // Espera que o módulo esteja inicializado antes de emitir valores
    await initialized;
    yield* _location.onLocationChanged;
  }
}
