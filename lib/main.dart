import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/crypto/encryption_utility.dart';
import 'data/models/local_journal_model.dart';
import 'data/models/local_cbt_model.dart';
import 'presentation/screens/auth_gatekeeper.dart';
import 'providers/app_providers.dart';
import 'firebase_options.dart';

// Application entry point - initializes Firebase, Hive, and encryption
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  // Register Hive adapters for local storage
  Hive.registerAdapter(LocalJournalAdapter());
  Hive.registerAdapter(LocalCbtRecordAdapter());

  // Get encryption key for secure box
  final encryptionKey = await EncryptionUtility.getOrGenerateEncryptionKey();

  // Open encrypted box for journal logging
  final cipher = HiveAesCipher(encryptionKey.bytes);
  await Hive.openBox('encrypted_journal_logs', encryptionCipher: cipher);

  runApp(const ProviderScope(child: MyApp()));
}

// Root widget - provides theme configuration
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Clinical App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const AuthGatekeeper(),
    );
  }
}
