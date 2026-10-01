import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

import { buildCustomClaims, MembershipRecord } from "./claims";

initializeApp();

/**
 * The authoritative, server-side step of:
 *   Current authenticated user -> User membership -> School/Tenant -> Role -> Permissions
 *
 * Whenever a schoolMemberships document is created, updated, or deleted,
 * this resolves the resulting Firebase Auth custom claims (`role`,
 * `schoolId`) for the affected user. Security rules and the Flutter client
 * read tenant membership from these claims — NEVER from a client-supplied
 * field — which is what makes tenant isolation enforceable server-side
 * (see firestore.rules and docs/architecture/multi-tenancy.md).
 */
export const onSchoolMembershipWrite = onDocumentWritten(
  "schoolMemberships/{membershipId}",
  async (event) => {
    const after = event.data?.after;
    const before = event.data?.before;

    const userId = after?.exists
      ? (after.data() as MembershipRecord).userId
      : before?.exists
        ? (before.data() as MembershipRecord).userId
        : undefined;

    if (!userId) {
      logger.warn("onSchoolMembershipWrite: no userId resolvable, skipping", {
        membershipId: event.params.membershipId,
      });
      return;
    }

    const claims = after?.exists ? buildCustomClaims(after.data() as MembershipRecord) : null;

    await getAuth().setCustomUserClaims(userId, claims);

    logger.info("TENANT_CLAIMS_UPDATED", {
      userId,
      membershipId: event.params.membershipId,
      role: claims?.role ?? null,
      schoolId: claims?.schoolId ?? null,
    });
  },
);
