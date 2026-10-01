import 'package:flutter/material.dart';

/// Placeholder entry point for the initial repository scaffold.
/// Replaced by the real flavor-aware bootstrap
/// (`bootstrap.dart` + `main_development.dart`/`main_uat.dart`/
/// `main_production.dart`) once Feature 01 adds Firebase/auth/routing.
void main() {
  runApp(const _ScaffoldPlaceholderApp());
}

class _ScaffoldPlaceholderApp extends StatelessWidget {
  const _ScaffoldPlaceholderApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('EazySchool 360')),
      ),
    );
  }
}
