import 'package:flutter/material.dart';
import 'package:lires/persistent/app_preferences.dart';
import 'package:lires/persistent/secure_storage.dart';
import 'package:lires/routes.dart';
import 'package:lires/gui/splashscreen.dart';
import 'package:lires/gui/clientnavigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  late bool? rememberState;
  rememberState = await UserSecureStorage.getRememberState() ?? false;
  runApp(Lires(
    rememberState: rememberState,
  ));
}

class Lires extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  final bool rememberState;
  const Lires({
    required this.rememberState,
    super.key});

  @override
  Widget build(BuildContext context) {
    if (rememberState) {
      return MaterialApp(
      title: 'Lires',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routes: routes,
      navigatorKey: navigatorKey,
      //home: const SplashScreen(),
      home: const ClientNavigation(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
    }
    return MaterialApp(
      title: 'Lires',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routes: routes,
      navigatorKey: navigatorKey,
      home: const SplashScreen(toLogin: true),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}