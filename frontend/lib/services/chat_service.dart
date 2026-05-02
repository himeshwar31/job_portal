import '../config/api_config.dart';
import '../models/message.dart';
import 'api_service.dart';

/// Chat service for sending and receiving messages.
///
/// Future Upgrade:
/// - Replace polling with Socket.IO for real-time messaging
/// - Add push notifications
class ChatService {
  final _api = ApiService();

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _api.dio.get(ApiConfig.conversations);
      final List<dynamic> data = response.data['conversations'] ?? [];
      return data.map((c) => Conversation.fromJson(c)).toList();
    } catch (e) {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<Message>> getMessages(int otherUserId) async {
    try {
      final response = await _api.dio.get(
        ApiConfig.messages,
        queryParameters: {'other_user_id': otherUserId},
      );
      final List<dynamic> data = response.data['messages'] ?? [];
      return data.map((m) => Message.fromJson(m)).toList();
    } catch (e) {
      throw Exception('Failed to load messages');
    }
  }

  Future<Map<String, dynamic>> sendMessage(int receiverId, String content) async {
    try {
      await _api.dio.post(
        ApiConfig.sendMessage,
        data: {
          'receiver_id': receiverId,
          'content': content,
        },
      );
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': 'Failed to send message'};
    }
  }
}
