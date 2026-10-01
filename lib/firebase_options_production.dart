import 'package:firebase_core/firebase_core.dart';

/// PLACEHOLDER — these are not real credentials.
///
/// Replace by running, once the `eazyschool360-prod` Firebase project exists:
/// ```
/// flutterfire configure --project=eazyschool360-prod -o lib/firebase_options_production.dart
/// ```
const productionFirebaseOptions = FirebaseOptions(
  apiKey: 'REPLACE_WITH_PROD_API_KEY',
  appId: 'REPLACE_WITH_PROD_APP_ID',
  messagingSenderId: 'REPLACE_WITH_PROD_SENDER_ID',
  projectId: 'eazyschool360-prod',
  authDomain: 'eazyschool360-prod.firebaseapp.com',
  storageBucket: 'eazyschool360-prod.appspot.com',
);
