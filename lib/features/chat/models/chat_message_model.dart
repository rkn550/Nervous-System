import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final Timestamp? timestamp;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.timestamp,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return ChatMessageModel(
      id: doc.id,
      senderId: data?['sender_id'] ?? '',
      senderName: data?['sender_name'] ?? 'Unknown',
      message: data?['message'] ?? '',
      timestamp: data?['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
