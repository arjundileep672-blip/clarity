import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final bool isStudent;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isStudent,
    required this.timestamp,
  });
}

class SocraticBuddyViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hi! I\'m here to help you learn. What would you like to explore today?',
      isStudent: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final List<String> _mockResponses = [
    'That\'s a great question! Let\'s break it down together. What do you already know about this?',
    'I can help with that. Can you tell me what part feels confusing?',
    'Interesting! Why do you think that might be the case?',
    'Let\'s explore this step by step. What\'s the first thing that comes to mind?',
  ];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messages.add(
      ChatMessage(text: text, isStudent: true, timestamp: DateTime.now()),
    );
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 800), () {
      _addTutorResponse(text);
    });
  }

  void _addTutorResponse(String studentQuestion) {
    final response = _mockResponses[_messages.length % _mockResponses.length];
    _messages.add(
      ChatMessage(text: response, isStudent: false, timestamp: DateTime.now()),
    );
    notifyListeners();
  }

  void takeBreak() {
    // Placeholder for break mode logic
  }
}
