/// The roles established for Feature 01.
///
/// Future roles (Teacher, Finance, HR, Parent, Student) are added in later
/// phases — do not add to this enum ahead of that need.
///
/// [value] must match exactly what Cloud Functions write into the Firebase
/// Auth custom claim `role`, and what `firestore.rules` compares against.
enum AppRole {
  /// Operates at the SaaS/platform level — can manage all schools.
  platformAdmin,

  /// Operates only within its own school ([SchoolMembership.schoolId]).
  schoolAdmin;

  String get value {
    switch (this) {
      case AppRole.platformAdmin:
        return 'platform_admin';
      case AppRole.schoolAdmin:
        return 'school_admin';
    }
  }

  static AppRole fromValue(String value) => AppRole.values.firstWhere(
        (r) => r.value == value,
        orElse: () => throw ArgumentError('Unknown role: $value'),
      );

  /// A platform admin is not bound to a single school.
  bool get isSchoolScoped => this == AppRole.schoolAdmin;
}
