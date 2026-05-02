class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class Conversation {
  final int userId;
  final String userName;
  final String userRole;
  final String lastMessage;
  final String lastTimestamp;

  Conversation({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      userRole: json['user_role'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastTimestamp: json['last_timestamp'] ?? '',
    );
  }
}
