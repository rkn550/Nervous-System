import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../models/chat_message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  late final String myUserId;
  late final String myUserName;

  bool _isSending = false;
  String? _errorMessage;

  ChatProvider({required ChatService chatService})
    : _chatService = chatService {
    final randId = 1000 + DateTime.now().millisecondsSinceEpoch % 9000;
    myUserId = 'user_$randId';
    myUserName = 'Aether_Recruit_$randId';
  }

  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Stream<List<ChatMessageModel>> get messagesStream =>
      _chatService.streamMessages();

  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _chatService.sendMessage(
        senderId: myUserId,
        senderName: myUserName,
        message: trimmed,
      );
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
