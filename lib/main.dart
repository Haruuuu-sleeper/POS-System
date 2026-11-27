import 'package:material_ui/material_ui.dart';

import 'presentation/pos_store.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/main_shell_screen.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatefulWidget {
  const PosApp({super.key});

  @override
  State<PosApp> createState() => _PosAppState();
}

class _PosAppState extends State<PosApp> {
  final PosStore _store = PosStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          if (_store.currentUser == null) {
            return AuthScreen(store: _store, onAuthenticated: () {});
          }

          return MainShellScreen(store: _store, onLogout: _store.signOut);
        },
      ),
    );
  }
}
