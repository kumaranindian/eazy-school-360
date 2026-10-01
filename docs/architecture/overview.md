# Architecture Overview

EazySchool 360 is a multi-tenant School Management SaaS. This document is
the map of how the pieces fit together; the other files in this folder go
deeper on each piece.

## Stack

- **Client**: Flutter (Android, iOS, Web), feature-first structure under `lib/`.
- **State management / DI**: Riverpod.
- **Routing**: `go_router`, with tenant-aware redirect guards.
- **Backend**: Firebase — Authentication, Firestore, Cloud Functions.
- **Environments**: three separate Firebase projects (`eazyschool360-dev`,
  `eazyschool360-uat`, `eazyschool360-prod`) — see `../phases/phase-01-foundation.md`
  and the root `.firebaserc`.

## Layering

```
Presentation (pages/widgets)
    ↓
Controllers (Riverpod AsyncNotifier/StreamProvider)
    ↓
Core context (TenantContext, AuthorizationService)
    ↓
Repositories (interfaces in lib/core/repositories, lib/features/*/domain)
    ↓
Firebase (Auth / Firestore) — lib/core/repositories/firebase, lib/features/*/data
```

A widget never talks to `FirebaseFirestore`/`FirebaseAuth` directly — every
access goes through a repository, so query logic and error mapping live in
one place and can be swapped or tested without a real backend.

## The context chain

Every feature module is meant to consume one reusable context instead of
re-deriving tenant/role information itself:

```
AuthService (authStateProvider)
     ↓
TenantContext (tenantContextProvider)
     ↓
AuthorizationService
     ↓
Feature
```

See `multi-tenancy.md`, `authentication.md`, and `authorization.md` for the
detail behind each step.

## Why Firebase config files are committed

`lib/firebase_options_*.dart` contain `apiKey`/`appId`/`projectId` — this is
expected to be public for a Firebase Web/mobile client by design, and is
**not** the thing that protects tenant data. The real boundary is
`firestore.rules` plus the custom claims set by `functions/src/index.ts` —
see `multi-tenancy.md` and `../../firestore.rules`. What must never be
committed is Admin SDK / service-account credentials, which this repo does
not contain.
