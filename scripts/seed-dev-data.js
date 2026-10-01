#!/usr/bin/env node
/**
 * Seeds safe, synthetic test data into the LOCAL FIREBASE EMULATOR ONLY
 * (see Part 23 — "Do not use real personal data"). Never point this at a
 * real project: it hardcodes test credentials.
 *
 * Usage (with the emulators already running, e.g. `firebase emulators:start`):
 *   node scripts/seed-dev-data.js
 *
 * Creates:
 *   School A, School B
 *   admin-a@eazyschool360.test -> School Admin of School A
 *   admin-b@eazyschool360.test -> School Admin of School B
 *   platform-admin@eazyschool360.test -> Platform Admin
 *
 * Use this data to manually verify tenant isolation (Part 25): sign in as
 * Admin A and confirm School B's data is unreachable.
 */

const admin = require("firebase-admin");

const PROJECT_ID = process.env.GCLOUD_PROJECT || "eazyschool360-dev";
const TEST_PASSWORD = "Test1234!";

if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error(
    "Refusing to run: FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST must both be set.\n" +
      'Run via `firebase emulators:exec --only auth,firestore "node scripts/seed-dev-data.js"`,\n' +
      "or export those two variables after starting `firebase emulators:start`.",
  );
  process.exit(1);
}

admin.initializeApp({ projectId: PROJECT_ID });

const auth = admin.auth();
const db = admin.firestore();

async function ensureAuthUser(email) {
  try {
    return await auth.getUserByEmail(email);
  } catch {
    return await auth.createUser({ email, password: TEST_PASSWORD, emailVerified: true });
  }
}

async function seedSchool(id, name, code) {
  const now = admin.firestore.Timestamp.now();
  await db.doc(`schools/${id}`).set({ name, code, status: "active", createdAt: now, updatedAt: now });
}

async function seedUser(uid, email, displayName) {
  const now = admin.firestore.Timestamp.now();
  await db.doc(`users/${uid}`).set({ email, displayName, status: "active", createdAt: now, updatedAt: now });
}

async function seedMembership(id, userId, schoolId, role) {
  const now = admin.firestore.Timestamp.now();
  await db.doc(`schoolMemberships/${id}`).set({
    userId,
    schoolId,
    role,
    status: "active",
    createdAt: now,
    updatedAt: now,
  });
  // Mirrors functions/src/claims.ts — the deployed Cloud Function does this
  // automatically against a real project; the seed script does it directly
  // so the data is immediately usable without the functions emulator.
  await auth.setCustomUserClaims(userId, schoolId ? { role, schoolId } : { role });
}

async function seedRoles() {
  await db.doc("roles/platform_admin").set({
    name: "platform_admin",
    permissions: ["manage_platform", "manage_own_school", "view_own_school"],
  });
  await db.doc("roles/school_admin").set({
    name: "school_admin",
    permissions: ["manage_own_school", "view_own_school"],
  });
}

async function main() {
  await seedSchool("school-a", "School A", "SCH-A");
  await seedSchool("school-b", "School B", "SCH-B");
  await seedRoles();

  const adminA = await ensureAuthUser("admin-a@eazyschool360.test");
  const adminB = await ensureAuthUser("admin-b@eazyschool360.test");
  const platformAdmin = await ensureAuthUser("platform-admin@eazyschool360.test");

  await seedUser(adminA.uid, adminA.email, "Admin A");
  await seedUser(adminB.uid, adminB.email, "Admin B");
  await seedUser(platformAdmin.uid, platformAdmin.email, "Platform Admin");

  await seedMembership(`${adminA.uid}_school-a`, adminA.uid, "school-a", "school_admin");
  await seedMembership(`${adminB.uid}_school-b`, adminB.uid, "school-b", "school_admin");
  await seedMembership(`${platformAdmin.uid}_platform`, platformAdmin.uid, null, "platform_admin");

  console.log("Seed complete:");
  console.log(`  admin-a@eazyschool360.test / ${TEST_PASSWORD} -> School A admin`);
  console.log(`  admin-b@eazyschool360.test / ${TEST_PASSWORD} -> School B admin`);
  console.log(`  platform-admin@eazyschool360.test / ${TEST_PASSWORD} -> Platform admin`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
