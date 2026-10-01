# Authorization

"What can you access?" — built on top of authentication (`authentication.md`)
and tenant resolution (`multi-tenancy.md`).

## Roles and permissions (Phase 1)

Two roles only — see CLAUDE.md "do not add to this ahead of need":

- `platform_admin` — operates at the SaaS level, all schools.
- `school_admin` — operates only within its own school.

```dart
// lib/core/models/permission.dart
const Map<AppRole, Set<Permission>> rolePermissions = {
  AppRole.platformAdmin: {managePlatform, manageOwnSchool, viewOwnSchool},
  AppRole.schoolAdmin:   {manageOwnSchool, viewOwnSchool},
};
```

Future roles (Teacher, Finance, HR, Parent, Student) are added in later
phases, each as a new `AppRole` value plus a `rolePermissions` entry — the
mechanism does not need to change.

### Why this is code, not a Firestore collection

The `roles` Firestore collection exists (Part 14 of the Feature 01 spec) as
reference data a client can read to know what a role grants — but the
*authoritative* role → permission mapping lives in `permission.dart`, not
in that collection. Phase 1 has exactly two roles and a handful of
permissions; a runtime-editable permission system is real complexity this
phase doesn't need yet. If a future phase needs admin-editable roles, that
collection becomes the source of truth and `rolePermissions` is removed —
a visible, deliberate change at that point, not something to half-build now.

## Two enforcement layers, not one

1. **`AuthorizationService`** (`lib/core/authorization/authorization_service.dart`)
   — checked in the Flutter app. This is UX: hide a button, fail fast with
   a clear message, log `ACCESS_DENIED`/`TENANT_ACCESS_DENIED`.
2. **`firestore.rules`** — checked by Firestore itself, independent of the
   client. This is the actual security boundary.

**(1) without (2) is not a finished feature.** A modified client or a raw
authenticated request against Firestore would bypass (1) entirely. Every
piece of tenant/role enforcement in this codebase exists in `firestore.rules`
first; `AuthorizationService` mirrors it for a better UX, never replaces it.
See `tests/security/firestore.rules.test.ts` for the proof — those tests
talk to the rules engine directly, with no Flutter app involved.

## TenantContext

`lib/core/context/tenant_context.dart` is what a feature should ask instead
of re-deriving any of this:

```dart
if (!context.has(Permission.manageOwnSchool)) { ... }
AuthorizationService.requirePermission(context, Permission.manageOwnSchool);
AuthorizationService.requireSameSchool(context, someSchoolId);
```
