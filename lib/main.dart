import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/datasourcers/notification_service.dart';
import 'firebase_options.dart';
import 'presentation/pages/home_screen.dart';
import 'presentation/providers/aqi_weather_provider.dart';
import 'presentation/providers/location_data_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/theme_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  NotificationService().showNotification(
    "🔔 Test Notification",
    "This is a manual test notification!",
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AqiWeatherProvider()),
        ChangeNotifierProvider(create: (_) => LocationDataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AQI App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}

/// **Light Theme**
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
    bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
  ),
  cardColor: Colors.white,
);

/// **Dark Theme**
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
  ),
  cardColor: Colors.grey[900],
);
