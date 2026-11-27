import 'package:flutter/material.dart';
import 'package:pos_system/presentation/screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: AuthScreen(
        onAuthenticated: () {
          // TODO: Navigate to your POS / Products screen and initialize PosRepository
        },
      ),
    );
  }
}
