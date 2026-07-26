import 'package:local_auth/local_auth.dart';

class AtlasBiometricService {
  AtlasBiometricService(this._auth);

  final LocalAuthentication _auth;

  Future<bool> isAvailable() async {
    return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
  }

  Future<bool> authenticate() {
    return _auth.authenticate(
      localizedReason: 'Unlock Atlas',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }
}
