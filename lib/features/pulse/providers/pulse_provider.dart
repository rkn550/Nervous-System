import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pulse_model.dart';
import '../services/pulse_service.dart';

class PulseProvider extends ChangeNotifier {
  final PulseService _pulseService;
  late PulseModel _state;
  Timer? _timer;

  final ValueNotifier<int> timeRemaining = ValueNotifier<int>(600000);

  PulseProvider({required PulseService pulseService})
    : _pulseService = pulseService {
    _state = const PulseModel(
      timeRemainingMs: 600000,
      concurrentPlayers: 10482,
      serverStatus: 'ONLINE',
    );
    _startTimer();
  }

  PulseModel get state => _state;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value -= 100;
      } else {
        timeRemaining.value = 600000;
      }
    });
  }

  Future<void> refreshPulseInfo() async {
    final players = await _pulseService.fetchConcurrentPlayers();
    final status = await _pulseService.fetchServerStatus();
    _state = _state.copyWith(concurrentPlayers: players, serverStatus: status);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    timeRemaining.dispose();
    super.dispose();
  }
}
