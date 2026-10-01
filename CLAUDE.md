# CLAUDE.md

Permanent rules for working on EazySchool 360. These apply to every phase,
not just the one currently in progress.

## Product

EazySchool 360 is a multi-tenant School Management SaaS.

## Architecture Principles

- Multi-tenancy is mandatory.
- Tenant isolation is mandatory.
- Security must be enforced server-side/security-rule-side.
- Never trust tenant IDs supplied by the client.
- Do not hard-code school-specific configuration.
- Do not hard-code academic structures.
- Do not hard-code fee structures.
- Historical data must be preserved.
- Business logic must be separated from UI.
- Reusable components must be preferred.
- Avoid duplicate implementations.

## Development Rules

- Work only within the current phase.
- Do not implement future phases without explicit approval.
- Every feature requires tests.
- Every feature requires security validation where applicable.
- Every phase requires production-readiness verification.
- Do not modify unrelated modules.
- Do not silently change architecture.
- Document important architectural decisions.

## Git Rules

- Never directly commit feature work to `main`.
- Use feature branches.
- Merge feature → phase.
- Merge completed phase → dev.
- Merge production-ready dev → main.
- Use meaningful commit messages.
