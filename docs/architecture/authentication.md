# Authentication

"Who are you?" — separate from authorization ("what can you access?", see
`authorization.md`).

## Identity layers

```
Firebase Auth identity (uid, email, credentials)
        ↓
AppUser (lib/core/models/app_user.dart)        — the application profile
        ↓
SchoolMembership (lib/core/models/school_membership.dart) — role + school
```

These are deliberately three different things:

- **Firebase Auth** knows only who can sign in. Modeled client-side as
  `AuthIdentity` (`lib/core/models/auth_identity.dart`) — intentionally
  smaller than firebase_auth's own `User`, so nothing outside
  `FirebaseAuthRepository` depends on the Firebase Auth SDK's type.
- **`AppUser`** is the application profile (email, display name, status).
  `AppUser != Staff` — a future Staff module maintains its own profile that
  *references* a user, it does not replace this one.
- **`SchoolMembership`** is tenant/role information. See `multi-tenancy.md`
  for why this is a separate collection rather than a field on `AppUser`.

## Flow

```
LoginPage
    ↓ signIn()
AuthController (features/authentication/presentation/auth_controller.dart)
    ↓
AuthRepository.signInWithEmailAndPassword()
    ↓
Firebase Auth sign-in + forced ID token refresh
    ↓
authStateProvider emits the new AuthIdentity
    ↓
tenantContextProvider resolves AppUser + SchoolMembership + School
    ↓
route_guard redirects to /dashboard (or /tenant-error)
```

### Why the ID token is force-refreshed after sign-in

Custom claims (`role`, `schoolId`) are set by a Cloud Function reacting to a
Firestore write (see `multi-tenancy.md`). They only appear on a freshly
issued ID token — Firebase does not push them to an already-issued token.
`FirebaseAuthRepository.signInWithEmailAndPassword` calls
`getIdTokenResult(true)` right after sign-in so a user whose membership was
granted before this login sees it immediately, instead of waiting for
Firebase's ~1 hour natural token refresh.

If a membership is granted/changed while a session is already active (not
exercised in Phase 1's UI), the same forced refresh would need to be
triggered again — e.g. on next sign-in, or a future "refresh my access"
action — rather than assumed automatic.

## Error handling

`FirebaseAuthRepository` and `FirebaseSchoolRepository`/etc. never let a raw
`FirebaseAuthException`/`FirebaseException` reach the UI — see
`lib/core/errors/failure_mapper.dart`, which maps them to the safe
`Failure` types in `lib/core/errors/failures.dart`. The UI only ever
displays `Failure.message`, which is written to be safe to show a user.
