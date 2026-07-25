import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_service.dart';

class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<NetworkStatus> currentStatus() async {
    return _map(await _connectivity.checkConnectivity());
  }

  @override
  Stream<NetworkStatus> watchStatus() {
    return _connectivity.onConnectivityChanged.map(_map).distinct();
  }

  NetworkStatus _map(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }

    return NetworkStatus.online;
  }
}
