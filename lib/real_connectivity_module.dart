import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:prjectcm/connectivity_module.dart';

class RealConnectivityModule implements ConnectivityModule {
  @override
  Future<bool> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}