import '../../../../core/config/app_config.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/google_auth_remote_data_source.dart';
import '../mappers/auth_user_mapper.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required AuthRemoteDataSource authRemoteDataSource,
    required GoogleAuthRemoteDataSource googleAuthRemoteDataSource,
    required AppLogger logger,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _googleAuthRemoteDataSource = googleAuthRemoteDataSource,
       _logger = logger;

  final AuthRemoteDataSource _authRemoteDataSource;
  final GoogleAuthRemoteDataSource _googleAuthRemoteDataSource;
  final AppLogger _logger;

  @override
  Future<Result<void>> initialize() {
    return _googleAuthRemoteDataSource.initialize();
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    final currentUser = await _authRemoteDataSource.currentUser();
    if (currentUser case Failure failure) {
      return Failure(failure.failure);
    }

    final dto = (currentUser as Success).value;
    if (dto != null) {
      final session = AuthSession(user: AuthUserMapper.toDomain(dto));
      final ownerCheck = _validateOwner(session);
      if (ownerCheck != null) {
        return Failure(ownerCheck);
      }
      return Success(session);
    }

    final googleTokens =
        await _googleAuthRemoteDataSource.attemptLightweightSignIn();
    if (googleTokens case Failure failure) {
      _logger.warning('Google lightweight auth did not restore a session');
      return Failure(failure.failure);
    }

    final tokens = (googleTokens as Success).value;
    if (tokens == null) {
      return const Success(null);
    }

    return _signInWithGoogleTokens(tokens);
  }

  @override
  Future<Result<AuthSession>> signInWithGoogle() async {
    final googleTokens = await _googleAuthRemoteDataSource.signIn();
    if (googleTokens case Failure failure) {
      return Failure(failure.failure);
    }

    return _signInWithGoogleTokens((googleTokens as Success).value);
  }

  @override
  Future<Result<void>> signOut() async {
    final supabaseSignOut = await _authRemoteDataSource.signOut();
    final googleSignOut = await _googleAuthRemoteDataSource.signOut();

    if (supabaseSignOut case Failure failure) {
      return Failure(failure.failure);
    }
    if (googleSignOut case Failure failure) {
      return Failure(failure.failure);
    }

    return const Success(null);
  }

  Future<Result<AuthSession>> _signInWithGoogleTokens(
    GoogleAuthTokens tokens,
  ) async {
    final supabaseAuth = await _authRemoteDataSource.signInWithGoogleIdToken(
      tokens.idToken,
    );
    if (supabaseAuth case Failure failure) {
      return Failure(failure.failure);
    }

    final session = AuthSession(
      user: AuthUserMapper.toDomain((supabaseAuth as Success).value),
    );
    final ownerCheck = _validateOwner(session);
    if (ownerCheck != null) {
      await signOut();
      return Failure(ownerCheck);
    }

    return Success(session);
  }

  AppFailure? _validateOwner(AuthSession session) {
    if (!AppConfig.restrictToOwnerEmail) {
      return null;
    }

    final expected = AppConfig.atlasOwnerEmail.trim().toLowerCase();
    final actual = session.user.email.trim().toLowerCase();
    if (actual == expected) {
      return null;
    }

    return const AppFailure(
      kind: AppFailureKind.permission,
      message: 'This Atlas build is restricted to its configured owner.',
    );
  }
}
