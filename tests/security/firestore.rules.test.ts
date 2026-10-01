import * as fs from "fs";
import * as path from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";

/**
 * Verifies the ACTUAL enforcement boundary (Part 13/25): these tests prove
 * that tenant isolation and RBAC hold even if a client is fully
 * compromised/manipulated — they talk to the Firestore emulator through the
 * rules engine directly, bypassing the Flutter app and its repositories
 * entirely.
 *
 * Seed data is written via a rules-disabled context; everything else goes
 * through the real `firestore.rules`.
 */

const PROJECT_ID = "eazyschool360-rules-test";

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(path.resolve(__dirname, "../../firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await db.doc("schools/school-a").set({
      name: "School A",
      code: "SCH-A",
      status: "active",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    await db.doc("schools/school-b").set({
      name: "School B",
      code: "SCH-B",
      status: "active",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc("users/admin-a").set({
      email: "admin-a@school-a.example",
      displayName: "Admin A",
      status: "active",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    await db.doc("users/admin-b").set({
      email: "admin-b@school-b.example",
      displayName: "Admin B",
      status: "active",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc("schoolMemberships/admin-a_school-a").set({
      userId: "admin-a",
      schoolId: "school-a",
      role: "school_admin",
      status: "active",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    await db.doc("schoolMemberships/admin-b_school-b").set({
      userId: "admin-b",
      schoolId: "school-b",
      role: "school_admin",
      status: "active",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc("roles/school_admin").set({
      name: "school_admin",
      permissions: ["manage_own_school", "view_own_school"],
    });
  });
});

function schoolAdminContext(uid: string, schoolId: string) {
  return testEnv.authenticatedContext(uid, { role: "school_admin", schoolId });
}

function platformAdminContext(uid = "platform-admin") {
  return testEnv.authenticatedContext(uid, { role: "platform_admin" });
}

function unauthenticatedContext() {
  return testEnv.unauthenticatedContext();
}

describe("schools — tenant isolation", () => {
  it("DENIES an unauthenticated read", async () => {
    await assertFails(unauthenticatedContext().firestore().doc("schools/school-a").get());
  });

  it("ALLOWS School Admin A to read their own school", async () => {
    await assertSucceeds(
      schoolAdminContext("admin-a", "school-a").firestore().doc("schools/school-a").get(),
    );
  });

  it("DENIES School Admin A reading School B by manipulating the document id", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a").firestore().doc("schools/school-b").get(),
    );
  });

  it("DENIES School Admin A writing to their own school (platform-owned)", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .doc("schools/school-a")
        .update({ name: "Hacked Name" }),
    );
  });

  it("DENIES School Admin A deleting School B", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a").firestore().doc("schools/school-b").delete(),
    );
  });

  it("ALLOWS Platform Admin to read and write any school", async () => {
    const db = platformAdminContext().firestore();
    await assertSucceeds(db.doc("schools/school-a").get());
    await assertSucceeds(db.doc("schools/school-b").get());
    await assertSucceeds(db.doc("schools/school-b").update({ name: "School B Renamed" }));
  });
});

describe("users — own-profile isolation", () => {
  it("ALLOWS a user to read their own profile", async () => {
    await assertSucceeds(
      schoolAdminContext("admin-a", "school-a").firestore().doc("users/admin-a").get(),
    );
  });

  it("DENIES a user reading another user's profile", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a").firestore().doc("users/admin-b").get(),
    );
  });

  it("DENIES a user updating another user's profile", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .doc("users/admin-b")
        .update({ displayName: "Pwned" }),
    );
  });
});

describe("schoolMemberships — role assignment is never client-writable", () => {
  it("DENIES a School Admin creating their own membership (self-assignment)", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .doc("schoolMemberships/admin-a_school-b")
        .set({
          userId: "admin-a",
          schoolId: "school-b",
          role: "school_admin",
          status: "active",
          createdAt: new Date(),
          updatedAt: new Date(),
        }),
    );
  });

  it("DENIES a School Admin escalating their own membership to platform_admin", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .doc("schoolMemberships/admin-a_school-a")
        .update({ role: "platform_admin" }),
    );
  });

  it("ALLOWS a School Admin to read their own membership", async () => {
    await assertSucceeds(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .doc("schoolMemberships/admin-a_school-a")
        .get(),
    );
  });

  it("DENIES a School Admin reading another school's membership", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .doc("schoolMemberships/admin-b_school-b")
        .get(),
    );
  });

  it("ALLOWS Platform Admin to write memberships", async () => {
    await assertSucceeds(
      platformAdminContext()
        .firestore()
        .doc("schoolMemberships/admin-a_school-a")
        .update({ status: "revoked" }),
    );
  });
});

describe("roles — reference data", () => {
  it("DENIES an unauthenticated read", async () => {
    await assertFails(unauthenticatedContext().firestore().doc("roles/school_admin").get());
  });

  it("ALLOWS any signed-in user to read", async () => {
    await assertSucceeds(
      schoolAdminContext("admin-a", "school-a").firestore().doc("roles/school_admin").get(),
    );
  });

  it("DENIES a School Admin writing role definitions", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .doc("roles/school_admin")
        .update({ permissions: ["manage_platform"] }),
    );
  });
});

describe("auditLogs — append-only, tenant-scoped", () => {
  it("ALLOWS a School Admin to create an audit log for their own action in their own school", async () => {
    await assertSucceeds(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .collection("auditLogs")
        .add({
          actorUserId: "admin-a",
          schoolId: "school-a",
          action: "SCHOOL_SETTINGS_VIEWED",
          entityType: "school",
          entityId: "school-a",
          timestamp: new Date(),
        }),
    );
  });

  it("DENIES creating an audit log impersonating another actor", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .collection("auditLogs")
        .add({
          actorUserId: "admin-b",
          schoolId: "school-a",
          action: "SCHOOL_SETTINGS_VIEWED",
          entityType: "school",
          entityId: "school-a",
          timestamp: new Date(),
        }),
    );
  });

  it("DENIES creating an audit log scoped to a different school than the actor's own", async () => {
    await assertFails(
      schoolAdminContext("admin-a", "school-a")
        .firestore()
        .collection("auditLogs")
        .add({
          actorUserId: "admin-a",
          schoolId: "school-b",
          action: "SCHOOL_SETTINGS_VIEWED",
          entityType: "school",
          entityId: "school-b",
          timestamp: new Date(),
        }),
    );
  });

  it("DENIES a School Admin reading another school's audit logs", async () => {
    const logId = "school-b-log-1";
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context
        .firestore()
        .doc(`auditLogs/${logId}`)
        .set({
          actorUserId: "admin-b",
          schoolId: "school-b",
          action: "SCHOOL_SETTINGS_VIEWED",
          entityType: "school",
          entityId: "school-b",
          timestamp: new Date(),
        });
    });

    await assertFails(
      schoolAdminContext("admin-a", "school-a").firestore().doc(`auditLogs/${logId}`).get(),
    );
  });

  it("DENIES updating or deleting an audit log, even for a Platform Admin", async () => {
    const logId = "school-a-log-1";
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context
        .firestore()
        .doc(`auditLogs/${logId}`)
        .set({
          actorUserId: "admin-a",
          schoolId: "school-a",
          action: "SCHOOL_SETTINGS_VIEWED",
          entityType: "school",
          entityId: "school-a",
          timestamp: new Date(),
        });
    });

    const db = platformAdminContext().firestore();
    await assertFails(db.doc(`auditLogs/${logId}`).update({ action: "TAMPERED" }));
    await assertFails(db.doc(`auditLogs/${logId}`).delete());
  });
});
