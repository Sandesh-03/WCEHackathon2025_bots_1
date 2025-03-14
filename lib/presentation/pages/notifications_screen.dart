import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget{
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
   return  Scaffold(
     appBar: AppBar(
      title: const Text("Chat"),
    ),
    body:Center(
      child: Text("Notification"),
    )
   );
  }
  
}