# CLAUDE.md

Permanent rules for working on EazySchool 360. These apply to every phase,
not just the one currently in progress.

## Product

EazySchool 360 is a multi-tenant School Management SaaS. See
`docs/architecture/overview.md` for the stack and layering, and
`docs/phases/` for what each phase actually built.

## Architecture Principles

- **Multi-tenancy is mandatory.** Every tenant-owned resource must have a
  reliable relationship to its school. See `docs/architecture/multi-tenancy.md`.
- **Tenant isolation is mandatory.** A user in School A must never be able
  to read or write School B's data — not even by guessing an id.
- **Security must be enforced server-side / security-rule-side.** Hiding a
  button in the UI is not a security control. See
  `docs/architecture/authorization.md`.
- **Never trust tenant IDs supplied by the client.** Tenant/role is resolved
  from Firebase Auth custom claims, set server-side by
  `functions/src/index.ts` in reaction to a `schoolMemberships` write the
  client cannot make itself. See `docs/architecture/multi-tenancy.md`.
- **Do not hard-code school-specific configuration, academic structures, or
  fee structures.** Those are modeled as tenant-owned data in later phases,
  not constants in code.
- **Historical data must be preserved.** Prefer status flags / soft states
  (e.g. `SchoolStatus.suspended`, `MembershipStatus.revoked`) over deleting
  records that future reporting/audit may need.
- **Business logic must be separated from UI.** Presentation → Controller →
  Core context → Repository → Firebase. A widget never calls
  `FirebaseFirestore`/`FirebaseAuth` directly.
- **Reusable components must be preferred; avoid duplicate implementations.**
  Future feature modules should consume `TenantContext` /
  `AuthorizationService` (`lib/core/context/`, `lib/core/authorization/`)
  instead of re-deriving tenant/role resolution themselves.

## Development Rules

- **Work only within the current phase.** Do not implement future phases
  without explicit approval — see each phase doc's "Out of scope" section.
- **Every feature requires tests.** Flutter/Dart unit tests (`test/`),
  Firestore rules tests (`tests/security/`), and Cloud Functions tests
  (`functions/test/`) as applicable — see `docs/phases/phase-01-foundation.md`
  "Testing strategy" for the pattern to follow.
- **Every feature requires security validation where applicable.** For
  anything touching Firestore, that means a rules test proving both the
  ALLOW and the DENY case, not just the happy path.
- **Every phase requires a production-readiness verification** — walk the
  checklist in the relevant `docs/phases/phase-NN-*.md` (or add one,
  following the Phase 01 doc's shape) before calling the phase done.
- **Do not modify unrelated modules. Do not silently change architecture.**
  If an existing pattern seems wrong for a new requirement, say so
  explicitly and propose the change — don't route around it quietly.
- **Document important architectural decisions** in `docs/architecture/`.

## Git Rules

```
main
  └── dev
       └── phase/NN-<name>
            └── feature/<name>
```

- Never commit feature work directly to `main`. Never work directly on `main`.
- Use feature branches off the current phase branch.
- Merge feature → phase, completed phase → dev, production-ready dev → main.
- Never force-push. Never delete a branch containing work that hasn't been
  merged elsewhere.
- Use meaningful commit messages (`type: summary`, e.g.
  `feat: establish multi-tenant foundation`).

## Where things live (Phase 1 conventions — extend, don't fork)

- `lib/core/` — cross-feature infrastructure (config, errors, logging,
  routing, theme, models, repositories + Firebase implementations, the
  `TenantContext`/`AuthorizationService` chain, Riverpod DI providers).
- `lib/features/<name>/{domain,data,presentation}/` — feature-first,
  following the pattern in `lib/features/authentication/`.
- `firestore.rules` — the actual enforcement boundary. A new tenant-owned
  collection gets its own `match` block here, scoped by the custom-claim
  `schoolId`, following the existing blocks — never relying on the
  catch-all `deny all` to "sort of" protect something new.
- `functions/` — server-side logic that must not run on the client
  (currently: custom-claim resolution). Pure logic goes in its own file
  (see `functions/src/claims.ts`) so it's unit-testable without the
  emulator; the Admin SDK glue goes in `functions/src/index.ts`.
