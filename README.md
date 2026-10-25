# Flutter Clean Architecture Template

[![CI](https://github.com/MohammedDaghmah/flutter_clean_architecture_template/actions/workflows/ci.yml/badge.svg)](https://github.com/MohammedDaghmah/flutter_clean_architecture_template/actions/workflows/ci.yml)

A reference Flutter starter demonstrating **Clean Architecture**, **BLoC**
state management, **dependency injection**, and a **feature-first** folder
structure — the same patterns used in production fintech and enterprise
apps for the Saudi market.

> Built by [Mohammed Daghmah](https://www.linkedin.com/in/mohammeddaghmah) —
> Senior Mobile & SDK Architect specializing in Flutter, .NET Core, and
> secure digital identity systems.

## Why this template exists

Most Flutter "clean architecture" boilerplate on GitHub stops at folder
names. This one implements a complete, working vertical slice — a Todo
feature — through all three layers, wired end-to-end with dependency
injection, error handling, an offline cache, and tests, so you can see
exactly how data flows from a data source to the UI and back.

It runs **out of the box with no backend**: demo mode uses an in-memory
fake data source that implements the same contract as the real Dio-based
one. Flipping a single flag in `lib/main.dart` switches to the real REST
implementation — and nothing in the domain or presentation layers changes.
That swap is the whole point of the architecture.

## Architecture

```
lib/
├── core/                     # Shared, feature-agnostic code
│   ├── di/                   # Dependency injection setup (get_it)
│   ├── error/                # Failure & Exception types
│   ├── network/              # Dio client, connectivity check
│   ├── security/             # Biometric unlock, secure storage, pinning, root detection
│   └── usecase/              # Base UseCase contract
│
└── features/
    └── todo/
        ├── data/
        │   ├── datasources/  # Remote (Dio / fake) & local (Hive cache)
        │   ├── models/       # DTOs — extend domain entities, add (de)serialization
        │   └── repositories/ # Repository implementation (data layer)
        │
        ├── domain/
        │   ├── entities/     # Pure business objects, no framework dependencies
        │   ├── repositories/ # Abstract repository contracts
        │   └── usecases/     # One class per business action
        │
        └── presentation/
            ├── bloc/         # Event, State, and Bloc
            ├── pages/        # Screens
            └── widgets/      # Feature-specific widgets
```

### The dependency rule

Dependencies always point **inward**:

```
presentation  →  domain  ←  data
```

`domain` never imports from `data` or `presentation`. This is what makes
the domain layer testable in isolation and swappable — you could replace
Dio with GraphQL, or REST with gRPC, and the domain/presentation layers
would never know.

## Key patterns demonstrated

| Pattern | Where |
|---|---|
| Repository pattern (interface in domain, implementation in data) | `todo_repository.dart` / `todo_repository_impl.dart` |
| UseCase per business action | `domain/usecases/*.dart` |
| Either-based error handling (no thrown exceptions across layers) | `core/error/failures.dart`, all repository methods |
| BLoC for state management | `presentation/bloc/todo_bloc.dart` |
| Dependency injection with `get_it` | `core/di/injection_container.dart` |
| Swappable data sources (fake / REST) behind one contract | `todo_fake_remote_data_source.dart`, `todo_remote_data_source.dart` |
| Offline-first fallback (remote → Hive cache) | `todo_repository_impl.dart` |
| Tests at every layer, each isolated from the others | `test/` |

## Mobile security

All security settings live in one immutable `SecurityPolicy` value
(`lib/main.dart`), and every piece sits behind a small interface so it can be
faked in tests:

| Control | Contract | Implementation |
|---|---|---|
| Biometric unlock (fingerprint / face) | `BiometricAuthenticator` | `local_auth` |
| Secure token storage (Keychain / Keystore) | `TokenStorage` | `flutter_secure_storage` |
| Root / jailbreak detection | `DeviceIntegrityChecker` | `safe_device` |
| Certificate pinning | `applyCertificatePinning(dio, pins)` | Dio `validateCertificate` |
| Debug-only HTTP logging | `DioClient` | `kDebugMode` |

`SecurityGate` wraps the app and applies the policy: it blocks compromised
devices and requires biometric unlock when the policy asks for it.

- To enable the lock screen, set `requireBiometricUnlock: true`.
- To enable pinning, add your server's fingerprints to `certificatePins`
  (see `lib/core/security/certificate_fingerprint.dart` for the command), and
  always ship a backup pin.
- Device checks are one defensive layer. The server must still validate every
  request.

Build an obfuscated release:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols
```

The same command is available as a manual GitHub Actions workflow
(`Release build (obfuscated)`).

## Getting started

```bash
flutter pub get
flutter run
```

> **First time on a fresh clone?** If the `android/`, `ios/`, etc. folders
> are missing, generate them once with:
> `flutter create . --org com.yourname`
> (this only adds the missing platform files; it won't touch `lib/`).

Run the tests:

```bash
flutter test
```

Switch to a real backend: in `lib/main.dart` set `_useFakeBackend = false`
and point `_apiBaseUrl` at your REST API (expects `/todos` endpoints).

## Testing strategy

| Layer | What is tested | How |
|---|---|---|
| Domain | Use cases delegate correctly to the repository | Mocked repository |
| Data | Online → fetch + cache; offline → cache fallback; failures mapped | Mocked data sources + network info |
| Presentation | BLoC state transitions; page renders each state | `bloc_test`, mocked BLoC |

## Adapting this to a new feature

1. Copy the `features/todo/` folder and rename it.
2. Define your entity in `domain/entities/`.
3. Define the repository contract in `domain/repositories/`.
4. Write one UseCase class per action in `domain/usecases/`.
5. Implement the repository in `data/repositories/`, backed by a remote
   and/or local data source.
6. Wire a BLoC in `presentation/bloc/` that calls your UseCases.
7. Register everything in `core/di/injection_container.dart`.

## License

MIT — use freely as a starting point for your own projects.
