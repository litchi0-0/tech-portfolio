import 'package:flutter/material.dart';
import 'common/theme/app_theme.dart';
import 'pages/splash/splash_page.dart';

class NuclearLedgerApp extends StatelessWidget {
  const NuclearLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuclearLedger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
