import 'package:flutter/material.dart';

class AboutUSScreen extends StatelessWidget {
  const AboutUSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
        ),
        body: const Center(
          child: Text("Notification"),
        ));
  }
}
