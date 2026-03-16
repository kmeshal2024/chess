import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/app/router.dart';

class ChessMateApp extends StatelessWidget {
  const ChessMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
