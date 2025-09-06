import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Builder(
        builder: (context) {
          final theme = context.watch<ThemeProvider>().theme;
          return MaterialApp(
            title: 'Adv MobProg',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
