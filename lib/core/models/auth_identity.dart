/// The authenticated identity — deliberately just what Firebase Auth knows
/// (who signed in), separate from [AppUser] (the application profile) and
/// [SchoolMembership] (tenant/role). See `docs/architecture/authentication.md`.
class AuthIdentity {
  const AuthIdentity({required this.uid, required this.email});

  final String uid;
  final String email;
}
