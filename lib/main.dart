import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_repository.dart';
import 'data/providers.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = AppRepository();
  final notifications = NotificationService();
  await notifications.init();

  // Filet de sécurité : replanifie les rappels au démarrage (après un reboot
  // du téléphone, les notifications planifiées peuvent être perdues).
  try {
    await notifications
        .rescheduleAll(await repository.getAllActiveTreatments());
  } catch (_) {
    // Non bloquant pour le démarrage de l'app.
  }

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const CarnetApp(),
    ),
  );
}

class CarnetApp extends StatelessWidget {
  const CarnetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carnet Animal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
