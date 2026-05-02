import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _service.getConversations();
    } catch (e) {
      _error = 'Failed to load conversations';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(int otherUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _service.getMessages(otherUserId);
    } catch (e) {
      _error = 'Failed to load messages';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendMessage(int receiverId, String content) async {
    final result = await _service.sendMessage(receiverId, content);
    if (result['success']) {
      await loadMessages(receiverId);
      return true;
    }
    _error = result['error'];
    notifyListeners();
    return false;
  }
}
