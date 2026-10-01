import 'package:firebase_core/firebase_core.dart';

/// PLACEHOLDER — these are not real credentials.
///
/// Replace this file by running, once the `eazyschool360-dev` Firebase
/// project exists:
///
/// ```
/// flutterfire configure --project=eazyschool360-dev -o lib/firebase_options_development.dart
/// ```
///
/// Firebase Web/mobile app config (apiKey, appId, projectId, ...) is public
/// client configuration by design — see `docs/architecture/overview.md` and
/// CLAUDE.md "No secrets in source, ever". It is still generated per
/// environment so development never points at production data.
const developmentFirebaseOptions = FirebaseOptions(
  apiKey: 'REPLACE_WITH_DEV_API_KEY',
  appId: 'REPLACE_WITH_DEV_APP_ID',
  messagingSenderId: 'REPLACE_WITH_DEV_SENDER_ID',
  projectId: 'eazyschool360-dev',
  authDomain: 'eazyschool360-dev.firebaseapp.com',
  storageBucket: 'eazyschool360-dev.appspot.com',
);
