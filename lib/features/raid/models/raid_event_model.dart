class RaidEventModel {
  final int slotsFilled;
  final int maxSlots;

  const RaidEventModel({
    required this.slotsFilled,
    required this.maxSlots,
  });

  factory RaidEventModel.fromMap(Map<String, dynamic> map) {
    return RaidEventModel(
      slotsFilled: map['slots_filled'] ?? 0,
      maxSlots: map['max_slots'] ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slots_filled': slotsFilled,
      'max_slots': maxSlots,
    };
  }
}
