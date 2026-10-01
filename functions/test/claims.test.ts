import { buildCustomClaims } from "../src/claims";

describe("buildCustomClaims", () => {
  it("grants platform_admin claims for an active platform admin membership", () => {
    expect(
      buildCustomClaims({ userId: "u1", role: "platform_admin", status: "active" }),
    ).toEqual({ role: "platform_admin" });
  });

  it("grants school_admin claims scoped to the membership's schoolId", () => {
    expect(
      buildCustomClaims({
        userId: "u1",
        role: "school_admin",
        schoolId: "school-a",
        status: "active",
      }),
    ).toEqual({ role: "school_admin", schoolId: "school-a" });
  });

  it("returns null (no access) for a revoked membership", () => {
    expect(
      buildCustomClaims({
        userId: "u1",
        role: "school_admin",
        schoolId: "school-a",
        status: "revoked",
      }),
    ).toBeNull();
  });

  it("fails closed for a school_admin membership missing a schoolId", () => {
    expect(
      buildCustomClaims({ userId: "u1", role: "school_admin", status: "active" }),
    ).toBeNull();
  });
});
