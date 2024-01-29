// ignore: file_names
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'messagepil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(title: 'Test Chat App'),
    );
  }
}

class Message {
  final String userName;
  final String text;
  final String createdAt;

  Message(
      {required this.userName, required this.text, required this.createdAt});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messages = [];
  // ignore: prefer_typing_uninitialized_variables
  late IO.Socket socket;
  late String user = '';
  bool isMounted = false;

  // ... (previous code)

  @override
  void initState() {
    super.initState();
    isMounted = true;
    // Initialize the socket connection in initState
    socket = IO.io(
      'http://192.168.161.176:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'foo': 'bar'})
          .build(),
    );

    socket.onConnect(
      (_) {
        debugPrint('connected');
        if (isMounted) {
          setState(() {
            user = socket.id!;
          });
        }
      },
    );

    socket.onConnectError(
      (error) {
        debugPrint('Error connecting to the server: $error');
        socket.disconnect();
      },
    );

    // Listen for incoming messages from the server
    socket.on('message', (data) {
      final message = Message(
          userName: data['userName'] ?? '',
          text: data['text'] ?? '',
          createdAt: data['createdAt'].toString());
      if (isMounted) {
        setState(() {
          messages.add(message);
        });
      }
    });

    socket.connect();
  }

  @override
  void dispose() {
    isMounted = false;
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final isCurrentUser = messages[index].userName == user;
                    return Column(
                      children: [
                        MessagePill(
                            text: messages[index].text,
                            sender: messages[index].userName,
                            isCurrentUser: isCurrentUser)
                      ],
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: 'Send your message'),
                  )),
                  IconButton(
                      onPressed: sendMessage, icon: const Icon(Icons.send))
                ],
              ),
            )
          ],
        ));
  }

  void sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      socket.emit('message', message);

      if (isMounted) {
        setState(() {
          _messageController.text = '';
        });
      }
    }
  }
}
