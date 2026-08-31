import '../models/focus_session.dart';

/// Abstraction over focus-session persistence.
abstract class SessionRepository {
  Future<void> add(FocusSession session);
  Future<List<FocusSession>> all({int? userId});
  Future<List<FocusSession>> since(DateTime start, {int? userId});
}

/// Simple aggregation result for the analytics view.
class SessionSummary {
  SessionSummary({this.totalSessions = 0, this.totalMinutes = 0});

  final int totalSessions;
  final int totalMinutes;
}