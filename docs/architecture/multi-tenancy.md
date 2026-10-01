# Multi-Tenancy

## The tenant model

```
Platform
   │
   ├── School A ── Users, Branches*, Academic Years*, Configuration*
   ├── School B ── Users, Branches*, Academic Years*, Configuration*
   └── School C
```

\* Branches, Academic Years, and detailed configuration are later features
(see `../phases/phase-01-foundation.md` — "Out of scope"). Feature 01 only
establishes the school entity and the membership/role mechanism everything
else will hang off of.

A **school is the primary tenant**. Every tenant-owned resource must carry a
reliable relationship to its school — in Phase 1, that means `schoolId` on
`schoolMemberships` and (via membership) on everything a School Admin can
reach.

## How a tenant is actually resolved — and why the client is never trusted

The single most important rule in this codebase:

> The application must NOT determine the tenant from a `schoolId` the UI
> supplies.

If it did, any user could simply change a request parameter and read or
write another school's data. Instead:

```
1. User signs in with Firebase Auth                → authStateProvider
2. A schoolMemberships document for that user       → resolved server-side
   determines role + schoolId
3. functions/src/index.ts (onSchoolMembershipWrite)  → writes {role, schoolId}
   as a Firebase Auth CUSTOM CLAIM on that user
4. firestore.rules reads request.auth.token.role /
   request.auth.token.schoolId — never a client-supplied field
5. The Flutter client's tenantContextProvider reads the SAME membership
   document (for UI purposes) — but it has no authority; the rules enforce
   the real boundary independently.
```

Because the custom claim is minted by a trusted server-side function from a
document the client cannot write (see `data-ownership.md`), a client cannot
grant itself access to another school's data by editing a request, a local
field, or a URL. This is exercised directly against the rules engine in
`tests/security/firestore.rules.test.ts` — including an explicit "manipulate
the document id" test.

## Platform Admin vs. School Admin

| | Platform Admin | School Admin |
|---|---|---|
| Scope | All schools | Exactly one school |
| `schoolId` custom claim | absent | present, immutable by the client |
| Can read/write `schools/*` | yes | read own school only |
| Can write `schoolMemberships/*` | yes | **no** — see below |

A School Admin must never be able to read or write School B's data, even by
guessing/constructing an id. `firestore.rules` enforces this per-document,
independent of whatever the client app's UI does or doesn't show.

## Multi-school users (future)

Phase 1 assumes one active membership per user — `MembershipRepository`
still queries a `schoolMemberships` collection (rather than a single field
on the user) specifically so that assumption can be lifted later (a user
with two active memberships, a school switcher in the UI) without a data
migration. The custom-claims mechanism would need to become
array/list-based at that point; this is intentionally not built now (see
CLAUDE.md "Do not implement future phases without explicit approval").
