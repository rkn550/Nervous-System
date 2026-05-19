import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore firestore;

  ChatService({required this.firestore});

  Stream<List<ChatMessageModel>> streamMessages() {
    return firestore
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessageModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    await firestore.collection('chats').add({
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
