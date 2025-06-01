import 'package:connectivity_plus/connectivity_plus.dart';

import '../connectivity_module.dart';

class ConnectivityService implements ConnectivityModule{


  @override
  Future<bool> checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity == ConnectivityResult.mobile || connectivity == ConnectivityResult.wifi;
  }
}