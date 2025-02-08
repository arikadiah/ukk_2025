import 'package:flutter/material.dart';
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ctlabkkchuiouduicshn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0bGFia2tjaHVpb3VkdWljc2huIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTUzNTgsImV4cCI6MjA1NDI5MTM1OH0.pY0U2Plq1Fs8u8xWCSnAe-h88LRds2qCfcti4Jv6LGs',
  );
  runApp(MyApp());
}
        
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
