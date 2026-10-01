/**
 * Pure mapping from a schoolMemberships document to the Firebase Auth
 * custom claims that establish tenant membership for security rules and
 * the Flutter client's TenantContext.
 *
 * Kept pure (no Admin SDK calls) so it can be unit tested without the
 * emulator — see test/claims.test.ts.
 */

export type MembershipRecord = {
  userId: string;
  schoolId?: string | null;
  role: "platform_admin" | "school_admin";
  status: "active" | "revoked";
};

export type TenantClaims = {
  role: "platform_admin" | "school_admin";
  schoolId?: string;
};

/**
 * Returns the custom claims to set for this membership, or `null` if the
 * membership should result in no tenant claims (revoked, or an invalid
 * school-scoped membership missing a schoolId — fails closed).
 */
export function buildCustomClaims(membership: MembershipRecord): TenantClaims | null {
  if (membership.status !== "active") {
    return null;
  }

  if (membership.role === "platform_admin") {
    return { role: "platform_admin" };
  }

  if (membership.role === "school_admin") {
    if (!membership.schoolId) {
      // Fail closed: a school_admin membership without a schoolId is
      // invalid and must not grant any tenant access.
      return null;
    }
    return { role: "school_admin", schoolId: membership.schoolId };
  }

  return null;
}
