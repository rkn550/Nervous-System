import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/raid_event_model.dart';

class RaidService {
  final FirebaseFirestore firestore;
  final _joinQueue = Queue<Completer<bool>>();
  bool _isProcessingQueue = false;

  RaidService({required this.firestore});

  Stream<RaidEventModel> streamRaidEvent() {
    return firestore.collection('events').doc('dragon_raid').snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const RaidEventModel(slotsFilled: 0, maxSlots: 15);
      }
      return RaidEventModel.fromMap(snapshot.data()!);
    });
  }

  Future<bool> joinRaid({required String userId}) {
    final completer = Completer<bool>();
    _joinQueue.add(completer);

    if (!_isProcessingQueue) {
      _processQueue();
    }

    return completer.future;
  }

  Future<void> _processQueue() async {
    _isProcessingQueue = true;

    while (_joinQueue.isNotEmpty) {
      final completer = _joinQueue.removeFirst();
      try {
        final success = await _executeJoinTransaction();
        completer.complete(success);
      } catch (e) {
        completer.complete(false);
      }
    }

    _isProcessingQueue = false;
  }

  Future<bool> _executeJoinTransaction() async {
    final docRef = firestore.collection('events').doc('dragon_raid');

    try {
      final success = await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Raid document does not exist.');
        }

        final data = snapshot.data()!;
        final int currentSlots = data['slots_filled'] ?? 0;
        final int maxSlots = data['max_slots'] ?? 15;

        if (currentSlots >= maxSlots) {
          return false;
        }

        transaction.update(docRef, {'slots_filled': FieldValue.increment(1)});

        return true;
      });
      return success;
    } catch (e) {
      return false;
    }
  }
}
