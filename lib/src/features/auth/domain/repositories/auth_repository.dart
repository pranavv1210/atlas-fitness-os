import '../../../../core/errors/result.dart';
import '../models/auth_session.dart';

abstract interface class AuthRepository {
  Future<Result<void>> initialize();

  Future<Result<AuthSession?>> restoreSession();

  Future<Result<AuthSession>> signInWithGoogle();

  Future<Result<void>> signOut();
}
