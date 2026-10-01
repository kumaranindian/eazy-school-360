# EazySchool 360

A multi-tenant School Management SaaS. Built phase by phase — see
`docs/phases/` for what exists and what's deliberately deferred, and
`CLAUDE.md` for the architecture/process rules that apply to every phase.

## Stack

Flutter (Android/iOS/Web) + Firebase (Auth, Firestore, Cloud Functions).
See `docs/architecture/overview.md` for the full picture.

## Getting started

```
flutter pub get
flutter run                      # defaults to the development flavor
flutter run -t lib/main_uat.dart
flutter run -t lib/main_production.dart
```

The first run needs real Firebase projects configured — the committed
`lib/firebase_options_*.dart` files are placeholders. For each environment:

```
flutterfire configure --project=eazyschool360-dev -o lib/firebase_options_development.dart
flutterfire configure --project=eazyschool360-uat -o lib/firebase_options_uat.dart
flutterfire configure --project=eazyschool360-prod -o lib/firebase_options_production.dart
```

### Local backend (emulators)

```
firebase emulators:start
npm run seed:dev   # safe synthetic test data — School A/B, two admins — see scripts/seed-dev-data.js
```

## Tests

```
flutter test                 # Dart unit tests
npm run test:rules           # Firestore security rules (tenant isolation, RBAC)
cd functions && npm test     # Cloud Functions unit tests
```

## Project structure

```
lib/
  core/            # cross-feature infrastructure: config, errors, logging,
                    # routing, theme, models, repositories, context,
                    # authorization, DI providers
  features/        # authentication, dashboard, ...
functions/         # Cloud Functions (server-side tenant claim resolution)
firestore.rules    # the real tenant-isolation/RBAC enforcement boundary
tests/security/    # Firestore rules tests (run against the emulator)
test/              # Flutter/Dart unit tests
docs/              # architecture + phase documentation
scripts/           # dev tooling (e.g. seed-dev-data.js)
```

## Git workflow

```
main → dev → phase/NN-<name> → feature/<name>
```

See `CLAUDE.md` "Git Rules" — never commit feature work directly to `main`.
