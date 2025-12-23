import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Stream<List<ConnectivityResult>> get connectivity$ =>
      Connectivity().onConnectivityChanged;

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
