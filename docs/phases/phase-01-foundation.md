# Phase 01 — Multi-Tenant Core Foundation

Branch: `phase/01-foundation`. Feature branch: `feature/01-multi-tenant-core-foundation`.

## Goal

Establish the infrastructure every future EazySchool 360 module will build
on: tenant model, authentication, authorization, security rules, logging,
error handling, audit foundation, and just enough UI to prove the chain
`Login → User → School → Tenant Context → Dashboard` works end to end.

## In scope

- `School`, `AppUser`, `SchoolMembership`, `AuditLog` models and repositories
- `platform_admin` / `school_admin` roles and a minimal permission map
- Firebase Auth email/password sign-in
- Server-side tenant resolution via Cloud Functions → custom claims (never
  trusting a client-supplied `schoolId`)
- `firestore.rules` enforcing tenant isolation and RBAC for every Phase 1
  collection
- `TenantContext` / `AuthorizationService` as the reusable context future
  features should consume
- Tenant-aware routing (`go_router` + redirect guard)
- Minimal login + dashboard shell UI
- Structured logging (`AppLogger`) and standardized failures (`Failure`)
- Firestore security-rules tests + Dart unit tests + Cloud Functions unit
  tests
- `development` / `uat` / `production` environment structure

## Out of scope (explicitly deferred — see CLAUDE.md)

School Profile & branding, Branches, Academic Years, Classes, Sections, Fee
Configuration, Students, Staff, Parents, Attendance, Leave, Payroll, Exams,
a full audit UI, and a fine-grained/editable permission system. None of
these were implemented.

## Git

```
main
  └── dev
       └── phase/01-foundation
            └── feature/01-multi-tenant-core-foundation   (NOT merged — see "Status" below)
```

- Initial commit `chore: initialize EazySchool 360` on `main`.
- `dev` branched from `main`.
- `phase/01-foundation` branched from `dev`.
- `feature/01-multi-tenant-core-foundation` branched from `phase/01-foundation`,
  containing this feature's commit(s).

Per the task instructions, the feature branch is pushed but **not** merged
into `phase/01-foundation`/`dev`/`main` — that merge is a separate, explicit
step after review/approval.

## Testing strategy

| Layer | Tool | What it proves |
|---|---|---|
| Firestore rules | `@firebase/rules-unit-testing` + emulator (`tests/security/firestore.rules.test.ts`) | Tenant isolation and RBAC hold at the actual enforcement boundary, independent of any client code. |
| Cloud Functions | Jest (`functions/test/claims.test.ts`) | Membership → custom-claims mapping is correct, including the fail-closed case. |
| Flutter | `flutter_test` + `mocktail` (`test/`) | Routing guard logic, permission/authorization logic, auth controller state transitions. |

Run all three with:

```
flutter test
npm run test:rules      # requires the Firebase CLI; starts/stops the emulator itself
cd functions && npm test
```

## Production readiness

See the final report delivered with this feature for the live checklist
result; the summary:

**READY WITH LIMITATIONS.** The foundation (tenant isolation, RBAC, server-
side authorization, logging, error handling, audit log, tests) is
functionally complete and verified. The limitations are expected for a
from-scratch Phase 1 with no real Firebase projects provisioned yet:

1. `lib/firebase_options_*.dart` contain placeholder values — real
   projects (`eazyschool360-dev/uat/prod`) need to be created and
   `flutterfire configure` run for each before this runs against a real
   backend (see `../architecture/overview.md`).
2. Tests were run against the Firebase emulator; there is no deployed
   environment yet to verify against.
3. `schoolMemberships` (role assignment) has no admin UI — by design for
   Phase 1 (see CLAUDE.md "do not implement future phases"). It is written
   today via the Admin SDK (the dev seed script, `scripts/seed-dev-data.js`)
   or a Platform Admin operator; a future phase may add an admin UI for it.
4. No CI pipeline wiring (GitHub Actions, etc.) was set up — not requested
   and out of scope for Feature 01's repository/feature work.
