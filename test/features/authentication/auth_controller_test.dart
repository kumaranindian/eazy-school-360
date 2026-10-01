import 'package:eazy_school_360/core/di/repository_providers.dart';
import 'package:eazy_school_360/core/errors/failures.dart';
import 'package:eazy_school_360/core/models/auth_identity.dart';
import 'package:eazy_school_360/core/repositories/user_repository.dart';
import 'package:eazy_school_360/features/authentication/domain/auth_repository.dart';
import 'package:eazy_school_360/features/authentication/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockUserRepository userRepository;
  late ProviderContainer container;

  setUp(() {
    authRepository = _MockAuthRepository();
    userRepository = _MockUserRepository();
    when(() => authRepository.authStateChanges()).thenAnswer((_) => const Stream.empty());
    when(() => authRepository.currentIdentity).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('signIn succeeds: ensures the user profile and leaves state as data', () async {
    const identity = AuthIdentity(uid: 'u1', email: 'u1@example.com');
    when(() => authRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => identity);
    when(() => userRepository.ensureUserProfile(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) async {});

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'u1@example.com', password: 'password123');

    final state = container.read(authControllerProvider);
    expect(state, const AsyncData<void>(null));
    verify(() => userRepository.ensureUserProfile(
          userId: 'u1',
          email: 'u1@example.com',
          displayName: 'u1@example.com',
        )).called(1);
  });

  test('signIn failure surfaces a Failure in AsyncError without crashing', () async {
    when(() => authRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const UnauthenticatedFailure('Incorrect email or password.'));

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'u1@example.com', password: 'wrong');

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<UnauthenticatedFailure>());
    verifyNever(() => userRepository.ensureUserProfile(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          displayName: any(named: 'displayName'),
        ));
  });
}
