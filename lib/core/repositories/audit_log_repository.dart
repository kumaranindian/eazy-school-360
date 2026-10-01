abstract interface class AuditLogRepository {
  /// Records an audit event. Audit logs are append-only — there is
  /// intentionally no update/delete method.
  Future<void> record({
    required String actorUserId,
    required String? schoolId,
    required String action,
    required String entityType,
    required String entityId,
  });
}
