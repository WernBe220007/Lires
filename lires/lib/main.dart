import 'package:flutter/material.dart';
import 'package:lires/persistent/app_preferences.dart';
import 'package:lires/persistent/secure_storage.dart';
import 'package:lires/routes.dart';
import 'package:lires/gui/splashscreen.dart';
import 'package:lires/gui/page/login.dart';
import 'package:lires/gui/clientnavigation.dart';
import 'package:provider/provider.dart';
import 'package:lires/structures/colorsprovider.dart';
import 'package:lires/helpers/user_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  late bool? rememberState;
  //UserSecureStorage.deleteAll();
  rememberState = await UserSecureStorage.getRememberState() ?? false;
  if (rememberState) {
    UserManager.fromJson(await UserSecureStorage.getUserValues(), null);
    if (!await UserManager.reloadUserData()) {
      rememberState = false;
    }
  }
  runApp(Lires(
    rememberState: rememberState,
  ));
}

class LiResState extends ChangeNotifier {
  static SnackBar? globalSnackbar;
  void updateListeners() {
    notifyListeners();
  }
}

class Lires extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  final bool rememberState;
  const Lires({required this.rememberState, super.key});

  @override
  Widget build(BuildContext context) {
    /*if (rememberState) {
      return MaterialApp(
      title: 'Lires',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode:  AppPreferences.getDarkModeSync() ? ThemeMode.dark : ThemeMode.light,
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode:  AppPreferences.getDarkModeSync() ? ThemeMode.dark : ThemeMode.light,
      routes: routes,
      navigatorKey: navigatorKey,
      //home: const SplashScreen(toLogin: true),
      home: const Login(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );*/
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LiResState(),
        ),
      ],
      child: MainPage(
        rememberState: rememberState,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final bool rememberState;
  final GlobalKey<NavigatorState> navigatorKey = Lires.navigatorKey;
  MainPage({super.key, required this.rememberState});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    context.watch<LiResState>();
    if (widget.rememberState) {
      return MaterialApp(
        title: 'Lires',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: colorMap[AppPreferences.getSelectedColorSync()] ??
                  Colors.deepOrange),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: colorMap[AppPreferences.getSelectedColorSync()] ??
                  Colors.deepOrange,
              brightness: Brightness.dark),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode:
            AppPreferences.getDarkModeSync() ? ThemeMode.dark : ThemeMode.light,
        routes: routes,
        navigatorKey: widget.navigatorKey,
        //home: const SplashScreen(),
        home: const ClientNavigation(),
        onGenerateRoute: RouteGenerator.generateRoute,
      );
    }
    return MaterialApp(
      title: 'Lires',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: colorMap[AppPreferences.getSelectedColorSync()] ??
                Colors.deepOrange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: colorMap[AppPreferences.getSelectedColorSync()] ??
                Colors.deepOrange,
            brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode:
          AppPreferences.getDarkModeSync() ? ThemeMode.dark : ThemeMode.light,
      routes: routes,
      navigatorKey: widget.navigatorKey,
      //home: const SplashScreen(toLogin: true),
      home: const Login(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
