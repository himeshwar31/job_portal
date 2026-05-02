"""
Chat routes: Send and receive messages.

# Future Upgrade:
# - Replace with Socket.IO for real-time chat
# - Store messages in MongoDB for persistence
# - Add read receipts and typing indicators
# - Add file/image attachment support
"""

from datetime import datetime
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from data.store import messages, get_next_id, find_user_by_id

chat_bp = Blueprint("chat", __name__)


@chat_bp.route("/send-message", methods=["POST"])
@jwt_required()
def send_message():
    """Send a message to another user."""
    sender_id = int(get_jwt_identity())
    data = request.get_json()

    receiver_id = data.get("receiver_id")
    content = data.get("content", "").strip()

    if not receiver_id or not content:
        return jsonify({"error": "'receiver_id' and 'content' are required"}), 400

    receiver = find_user_by_id(receiver_id)
    if not receiver:
        return jsonify({"error": "Receiver not found"}), 404

    message = {
        "id": get_next_id("message"),
        "sender_id": sender_id,
        "receiver_id": receiver_id,
        "content": content,
        "timestamp": datetime.utcnow().isoformat(),
    }
    messages.append(message)

    return jsonify({"message": "Message sent", "data": message}), 201


@chat_bp.route("/messages", methods=["GET"])
@jwt_required()
def get_messages():
    """Get conversation messages with a specific user."""
    user_id = int(get_jwt_identity())
    other_user_id = request.args.get("other_user_id", type=int)

    if not other_user_id:
        return jsonify({"error": "'other_user_id' query parameter is required"}), 400

    # Get messages between the two users
    conversation = [
        m for m in messages
        if (m["sender_id"] == user_id and m["receiver_id"] == other_user_id)
        or (m["sender_id"] == other_user_id and m["receiver_id"] == user_id)
    ]

    # Sort by timestamp
    conversation.sort(key=lambda x: x["timestamp"])

    return jsonify({"messages": conversation}), 200


@chat_bp.route("/conversations", methods=["GET"])
@jwt_required()
def get_conversations():
    """Get list of users the current user has chatted with."""
    user_id = int(get_jwt_identity())

    # Find all unique users this user has chatted with
    chat_user_ids = set()
    for m in messages:
        if m["sender_id"] == user_id:
            chat_user_ids.add(m["receiver_id"])
        elif m["receiver_id"] == user_id:
            chat_user_ids.add(m["sender_id"])

    conversations = []
    for other_id in chat_user_ids:
        other_user = find_user_by_id(other_id)
        if not other_user:
            continue

        # Get last message
        user_messages = [
            m for m in messages
            if (m["sender_id"] == user_id and m["receiver_id"] == other_id)
            or (m["sender_id"] == other_id and m["receiver_id"] == user_id)
        ]
        user_messages.sort(key=lambda x: x["timestamp"], reverse=True)
        last_message = user_messages[0] if user_messages else None

        conversations.append({
            "user_id": other_id,
            "user_name": other_user["name"],
            "user_role": other_user["role"],
            "last_message": last_message["content"] if last_message else "",
            "last_timestamp": last_message["timestamp"] if last_message else "",
        })

    # Sort by last message timestamp
    conversations.sort(key=lambda x: x["last_timestamp"], reverse=True)

    return jsonify({"conversations": conversations}), 200
