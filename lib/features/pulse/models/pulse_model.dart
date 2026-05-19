class PulseModel {
  final int timeRemainingMs;
  final int concurrentPlayers;
  final String serverStatus;

  const PulseModel({
    required this.timeRemainingMs,
    required this.concurrentPlayers,
    required this.serverStatus,
  });

  PulseModel copyWith({
    int? timeRemainingMs,
    int? concurrentPlayers,
    String? serverStatus,
  }) {
    return PulseModel(
      timeRemainingMs: timeRemainingMs ?? this.timeRemainingMs,
      concurrentPlayers: concurrentPlayers ?? this.concurrentPlayers,
      serverStatus: serverStatus ?? this.serverStatus,
    );
  }
}
