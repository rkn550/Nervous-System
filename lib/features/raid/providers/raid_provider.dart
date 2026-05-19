import 'package:flutter/material.dart';
import '../models/raid_event_model.dart';
import '../services/raid_service.dart';

class RaidProvider extends ChangeNotifier {
  final RaidService _raidService;
  bool _isJoining = false;
  bool _joinSuccess = false;

  RaidProvider({required RaidService raidService}) : _raidService = raidService;

  bool get isJoining => _isJoining;
  bool get joinSuccess => _joinSuccess;

  Stream<RaidEventModel> get raidEventStream => _raidService.streamRaidEvent();

  Future<bool> joinRaidSequence({required String userId}) async {
    if (_isJoining || _joinSuccess) return false;

    _isJoining = true;
    notifyListeners();

    final success = await _raidService.joinRaid(userId: userId);

    _isJoining = false;
    _joinSuccess = success;
    notifyListeners();

    return success;
  }
}
