import 'package:flutter/material.dart';
import 'package:mobi_pos/home.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tgazcjwfopizewjqwqpd.supabase.co',
    anonKey: 'sb_publishable_lBtbyAihIrX1jVbb4jKb0Q_Kx7u8w0j',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}