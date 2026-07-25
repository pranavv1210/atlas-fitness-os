enum NetworkStatus { online, offline }

abstract interface class ConnectivityService {
  Future<NetworkStatus> currentStatus();

  Stream<NetworkStatus> watchStatus();
}
