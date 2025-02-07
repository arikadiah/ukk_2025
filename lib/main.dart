import 'package:flutter/material.dart';
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://mmvqwzcwxukkqalyuuds.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1tdnF3emN3eHVra3FhbHl1dWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzI5OTgsImV4cCI6MjA1MTcwODk5OH0.nsxmWf0YQpwoBSh2UFffeTnVI2l7Yg_zHmli-7MbFEw',
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
