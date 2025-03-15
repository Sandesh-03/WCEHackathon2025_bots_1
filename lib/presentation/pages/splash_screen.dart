import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../providers/theme_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
    String videoUrl = 'assets/v2.mp4'; // Light theme video

    _videoPlayerController = VideoPlayerController.asset(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
        _navigateToHomeScreenAfterVideo();
      });
  }
  void _navigateToHomeScreenAfterVideo() {
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position == _videoPlayerController.value.duration) {
        // Video has finished, navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }
  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _videoPlayerController.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        )
            : CircularProgressIndicator(),  // Show loading indicator while video is initializing
      ),
    );
  }
}

