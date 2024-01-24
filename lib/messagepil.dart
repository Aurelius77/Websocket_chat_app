import 'package:flutter/material.dart';

class MessagePill extends StatelessWidget {
  final String text;
  final String sender;
  final bool isCurrentUser;

  const MessagePill(
      {super.key,
      required this.text,
      required this.sender,
      required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isCurrentUser ? Colors.blue : Colors.grey[300],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
