import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dicoding_chatting/pages/login_page.dart';
import 'package:dicoding_chatting/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  static const String id = 'chat_page';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  User _activeUser;
  final _messageTextController = TextEditingController();
  final messageBubble = MessageBubble(
    sender: messageSender,
    text: messageText,
    isMyChat: messageSender == _activeUser.email,
  );
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser() async {
    try {
      var currentUser = await _auth.currentUser;

      if (currentUser != null) {
        _activeUser = currentUser;
      }
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            tooltip: 'Logout',
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, LoginPage.id);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                  .collection('messages')
                  .orderBy('dateCreated', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  children: snapshot.data!.docs.map((document) {
                    final messageText = document.data()['text'];
                    final messageSender = document.data()['sender'];
                    return MessageBubble(
                      sender: messageSender,
                      text: messageText,
                    );
                  }).toList(),
                );
              },
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageTextController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                MaterialButton(
                  child: Text('SEND'),
                  color: Theme.of(context).primaryColor,
                  textTheme: ButtonTextTheme.primary,
                  onPressed: () {
                    _firestore.collection('messages').add({
                      'text': _messageTextController.text,
                      'sender': _activeUser.email,
                      'dateCreated': Timestamp.now(),
                    });
                    _messageTextController.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _messageTextController.dispose();
    super.dispose();
  }
}
