import 'package:flutter/material.dart';
import 'package:fd13/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//global V here: MessageBubble() can access it
final _firestore = FirebaseFirestore.instance;
User loggedUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //to clear textField before next input
  final messageTextController = TextEditingController();
  final _authV = FirebaseAuth.instance;

  //create a varible for Firestore cloud
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    // now _authV.currentUser is not required the await
    final user = _authV.currentUser;
    if (user != null) {
      loggedUser = user;
      print(loggedUser.email);
    }
  }

  //to retrieve data from cloud to phone (but it takes time) ==> Streams Better
  // void getMessages() async {
  //   final messagesV = await _firestore.collection('messages').get();
  //   for (var message in messagesV.docs) {
  //     print(message.data().toString());
  //   }
  // }

  //Stream with snapshot()
  // void messagesStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data().toString());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              //logout x
              onPressed: () {
                // messagesStream();
                _authV.signOut();
                Navigator.pop(
                    context); //push user back to previous screen (login)
              }),
        ],
        title: Text('⚡️ Chat'),
        centerTitle: true,
        backgroundColor: Colors.black12,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      //messageTextV + loggedUser
                      //name from cloud must match exactly: collection name, field (key)name
                      messageTextController.clear();
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedUser.email});
                    },
                    child: Icon(Icons.send),
                    // child: Text(
                    //   'Send',
                    //   style: kSendButtonTextStyle,
                    // ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return //**adding StreamBuilder need (1) stream/data n (2) builder
        StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshort) {
        if (!snapshort.hasData) {
          return Center(
              //adding spinner
              child: CircularProgressIndicator(
            backgroundColor: Color(0xFF8ac4d0),
          ));
        }
        final messages = snapshort.data.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageData = message.data();
          final messageText = messageData['text'];
          final messageSender = messageData['sender'];
          final currentUser = loggedUser.email;

          final messageBubble =
              MessageBubble(
                sender: messageSender, 
                text: messageText,
                isMe: (currentUser == messageSender) 
                );
          //**to update List
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            // reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  MessageBubble({this.sender, this.text, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              )),
          Material(
            borderRadius: isMe? BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)): BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
              
            elevation: 5,
            color: isMe? Color(0xFF28527a): Color(0xFF8ac4d0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                //working here for design
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
