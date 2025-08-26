import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

// ------------------- USERS PAGE -------------------
class UsersPage extends StatelessWidget {
  final String currentUserId;
  UsersPage({required this.currentUserId}) {
   
    PresenceService(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          "V-CHAT",
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [Text(currentUserId)],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              if (user.id == currentUserId) return Container(); 

              return StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref('status/${user.id}')
                    .onValue,
                builder: (context, statusSnapshot) {
                  String state = 'offline';
                  int? lastSeen;

                  if (statusSnapshot.hasData &&
                      statusSnapshot.data!.snapshot.value != null) {
                    final data = Map<String, dynamic>.from(
                      statusSnapshot.data!.snapshot.value as Map,
                    );
                    state = data['state'] ?? 'offline';
                    lastSeen = data['last_seen'] is int
                        ? data['last_seen'] as int
                        : null;
                  }

                  String lastSeenText = 'offline';
                  if (state == 'offline' && lastSeen != null) {
                    final dt = DateTime.fromMillisecondsSinceEpoch(lastSeen);
                    lastSeenText =
                        "last seen ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user['displayName'][0].toUpperCase()),
                      ),
                      title: Text(user['displayName']),
                      trailing: state == 'online'
                          ? Icon(Icons.circle, color: Colors.green, size: 12)
                          : Text(
                              lastSeenText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              currentUserId: currentUserId,
                              otherUserId: user.id,
                              otherUserName: user['displayName'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------- CHAT PAGE -------------------
class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  ChatPage({
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  String getChatId() {
    return widget.currentUserId.hashCode <= widget.otherUserId.hashCode
        ? "${widget.currentUserId}_${widget.otherUserId}"
        : "${widget.otherUserId}_${widget.currentUserId}";
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String chatId = getChatId();

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': widget.currentUserId,
          'receiverId': widget.otherUserId,
          'text': _controller.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Row(
          children: [
            CircleAvatar(child: Text(widget.otherUserName[0].toUpperCase())),
            SizedBox(width: 8),
            Text(
              widget.otherUserName.toUpperCase(),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                var messages = snapshot.data!.docs;

                // Mark unread messages as read
                for (var msg in messages) {
                  Map<String, dynamic> data =
                      msg.data() as Map<String, dynamic>;
                  if (data['receiverId'] == widget.currentUserId &&
                      data['read'] == false) {
                    msg.reference.update({'read': true});
                  }
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index];
                    Map<String, dynamic> data =
                        msg.data() as Map<String, dynamic>;

                    bool isMe = data['senderId'] == widget.currentUserId;
                    bool isRead = data['read'] ?? false;

                    Timestamp? ts = data['timestamp'] as Timestamp?;
                    String time = ts != null
                        ? "${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}"
                        : '';

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(6),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: CircleAvatar(
                                  radius: 12,
                                  child: Text(
                                    widget.otherUserName[0].toUpperCase(),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['text']),
                                SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if (isMe) SizedBox(width: 4),
                                    if (isMe)
                                      Icon(
                                        isRead ? Icons.done_all : Icons.done,
                                        size: 14,
                                        color: isRead
                                            ? Colors.blue
                                            : Colors.black54,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- PRESENCE SERVICE -------------------
class PresenceService extends WidgetsBindingObserver {
  final String currentUserId;
  final DatabaseReference statusRef = FirebaseDatabase.instance.ref().child(
    'status',
  );

  PresenceService(this.currentUserId) {
    WidgetsBinding.instance.addObserver(this);
    goOnline();
  }

  void goOnline() {
    statusRef.child(currentUserId).set({
      'state': 'online',
      'last_seen': ServerValue.timestamp,
    });
  }

  void goOffline() async {
    await statusRef.child(currentUserId).set({
      'state': 'offline',
      'last_seen': ServerValue.timestamp,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      goOnline();
    } else {
      goOffline();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
