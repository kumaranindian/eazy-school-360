# Data Ownership

```
Platform-owned
    └── schools                (lifecycle managed by Platform Admins only)

Tenant-owned (scoped to a school, directly or via membership)
    ├── users                  (a user's own profile — owned by that user)
    ├── schoolMemberships      (role/school assignment — privileged write only)
    ├── roles                  (reference data, not school-scoped, read-only to clients)
    ├── auditLogs              (append-only, scoped to the acting user's school)
    │
    │  not yet created — future phases:
    ├── students
    ├── staff
    ├── fees
    ├── attendance
    └── payroll
```

## Collections created in Phase 1

| Collection | Owner | Client create | Client update | Client delete | Notes |
|---|---|---|---|---|---|
| `schools` | Platform | no | no | no | School Admin may **read** their own only. |
| `users` | the user | own doc only | own doc only | no | `AppUser.id == Firebase Auth uid`. |
| `schoolMemberships` | Platform | no | no | no | Role/school assignment is privileged — see `multi-tenancy.md`. Written via the Admin SDK (a seed script in Phase 1; a future admin tool in later phases) or a Platform Admin. |
| `roles` | Platform | no | no | no | Any signed-in user may read. |
| `auditLogs` | the acting user, scoped to their school | own action, own school only | **never** | **never** | Immutable once written. |

Nothing beyond these five collections is created in Phase 1 — see
`../phases/phase-01-foundation.md` "Out of scope". A future module adding
`students`, `fees`, etc. should give each its own `firestore.rules` match
block scoped by `schoolId`, following the same pattern as `schools`/
`auditLogs` here — never relying on the catch-all deny-all rule to "sort of"
protect an un-scoped new collection.
