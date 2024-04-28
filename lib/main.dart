import 'package:flutter/material.dart';
import 'package:mqtt_provider/home_page.dart';
import 'package:mqtt_provider/mqtt.dart';
import 'package:mqtt_provider/provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = await connect();
  runApp(
    ChangeNotifierProvider(
      create: (context) => MQTTDataProvider(client: client),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
