import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/player_model.dart';

class Friend {
  final String name;
  final String role; // 'admin', 'friend', 'scammer'
  final String avatarEmoji;
  bool hasUnread;

  Friend({
    required this.name,
    required this.role,
    required this.avatarEmoji,
    this.hasUnread = false,
  });
}

class ChatOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final PlayerModel player;
  final void Function(int delta) adjustBalance;

  const ChatOverlay({
    super.key,
    required this.onClose,
    required this.player,
    required this.adjustBalance,
  });

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  late List<Friend> friends;
  Friend? selectedFriend;
  // timer for scammer messages
  Timer? scammerTimer;

  // conversations holds a list of messages for each friend
  // message map: {"sender": "me"|"them", "text": String}
  late Map<String, List<Map<String, String>>> _conversations;
  final TextEditingController _inputController = TextEditingController();

  final List<String> scammerMessages = [
    "Hello! I'm offering great fertilizer deals. Interested?",
    "Hi! I have premium seeds at half price. Limited time only!",
    "Hey, I'm an official TARA representative. Verify your account here!",
    "I can help you earn 100K daily! Check my link.",
    "Offer: Free land plots registration. Click here to claim!",
    "Congratulations! You've won a lottery prize. Claim now!",
  ];

  @override
  void initState() {
    super.initState();
    // no stream needed anymore

    friends = [
      Friend(
        name: 'TARA Admin',
        role: 'admin',
        avatarEmoji: '👨‍💼',
      ),
      Friend(
        name: 'Rajesh',
        role: 'friend',
        avatarEmoji: '👨‍🌾',
      ),
      Friend(
        name: 'Priya',
        role: 'friend',
        avatarEmoji: '👩‍🌾',
      ),
      Friend(
        name: 'Sharma Trading Co.',
        role: 'scammer',
        avatarEmoji: '🏢',
      ),
    ];

    // set up simple conversations
    _conversations = {
      for (var f in friends)
        f.name: <Map<String, String>>[]
    };

    // seed with a few starter messages
    _conversations['TARA Admin']!.addAll([
      {'sender': 'them', 'text': 'Hello! How can I help you today?'},
    ]);
    _conversations['Rajesh']!.addAll([
      {'sender': 'them', 'text': 'Hey! Good harvest this season?'},
      {'sender': 'them', 'text': 'Could you lend me ₹50?'},
    ]);
    _conversations['Priya']!.addAll([
      {'sender': 'them', 'text': 'Hi! How’s your farming going?'},
    ]);
    _conversations['Sharma Trading Co.']!.addAll([
      {'sender': 'them', 'text': 'Hello! I have premium seeds at half price. Limited time only!'},
      {'sender': 'them', 'text': 'Check my link: http://scam.example.com'},
    ]);

    _startScammerTimer();
  }

  void _startScammerTimer() {
    scammerTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        final scammer = friends.firstWhere((f) => f.role == 'scammer');
        scammer.hasUnread = true;
        final text = scammerMessages[Random().nextInt(scammerMessages.length)];
        _conversations[scammer.name]!.add({'sender': 'them', 'text': text});
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    scammerTimer?.cancel();
    super.dispose();
  }

  void _selectFriend(Friend friend) {
    setState(() {
      selectedFriend = friend;
      friend.hasUnread = false;
    });
  }

  void _sendMessage(String text) {
    if (selectedFriend == null || text.trim().isEmpty) return;
    final name = selectedFriend!.name;
    _conversations[name]!.add({'sender': 'me', 'text': text});
    // detect money instructions
    final moneyMatch = RegExp(r'\u20B9?(\d+)').firstMatch(text);
    if (moneyMatch != null) {
      final amount = int.tryParse(moneyMatch.group(1)!) ?? 0;
      if (text.toLowerCase().contains('give') ||
          text.toLowerCase().contains('send')) {
        widget.adjustBalance(-amount);
      } else if (text.toLowerCase().contains('ask') ||
          text.toLowerCase().contains('lend') ||
          text.toLowerCase().contains('borrow')) {
        widget.adjustBalance(amount);
      }
    }
    setState(() {});
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 700,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber, width: 6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF8B6914),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '💬 CHAT WITH FRIENDS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Row(
                children: [
                  // Friends list
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          final isSelected = selectedFriend == friend;

                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.amber.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () => _selectFriend(friend),
                              leading: Stack(
                                children: [
                                  Text(friend.avatarEmoji,
                                      style:
                                          const TextStyle(fontSize: 32)),
                                  if (friend.hasUnread)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                friend.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Chat area
                  Expanded(
                    flex: 3,
                    child: selectedFriend != null
                        ? Column(
                            children: [
                              Expanded(child: _buildChatArea(selectedFriend!)),
                              _buildComposer(),
                            ],
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EDDE),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Select a friend to chat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(Friend friend) {
    // keep the container styling
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3EDDE),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Chat header (role information hidden)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(friend.avatarEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: _buildMessages(friend),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: const InputDecoration.collapsed(
                  hintText: 'Type a message...'),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_inputController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(Friend friend) {
    final convo = _conversations[friend.name]!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: convo.length,
      itemBuilder: (context, index) {
        final msg = convo[index]['text']!;
        final sender = convo[index]['sender']!;
        final isMine = sender == 'me';
        final bubbleColor = isMine ? Colors.green.withValues(alpha: 0.2) : Colors.white;

        Widget messageWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(msg, style: const TextStyle(fontSize: 13)),
        );

        if (friend.role == 'scammer') {
          // every tap costs coins
          messageWidget = GestureDetector(
            onTap: () {
              widget.adjustBalance(-20);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Scam Alert!'),
                    content: const Text('Oh no! You lost ₹20 to a scam.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: messageWidget,
          );
        }

        // build row with optional pay button below
        Widget row = Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              messageWidget,
            ],
          ),
        );

        if (!isMine) {
          final moneyMatch = RegExp(r'₹\s*(\d+)').firstMatch(msg);
          if (moneyMatch != null) {
            final amount = int.tryParse(moneyMatch.group(1)!) ?? 0;
            row = Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  messageWidget,
                  TextButton(
                    onPressed: () {
                      widget.adjustBalance(-amount);
                      _conversations[friend.name]!
                          .add({'sender': 'me', 'text': 'Sent ₹$amount'});
                      setState(() {});
                    },
                    child: Text('Send ₹$amount'),
                  ),
                ],
              ),
            );
          }
        }

        return row;
      },
    );
  }

}
