import 'package:flutter/material.dart';

import 'dart:async';
import 'package:lires/gui/clientnavigation.dart';
import 'package:lires/gui/page/login.dart';

class SplashScreen extends StatefulWidget {
  final bool toLogin;
  const SplashScreen({super.key, this.toLogin = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(context, widget.toLogin
            ? MaterialPageRoute(builder: (context) => const Login())
            : MaterialPageRoute(builder: (context) => const ClientNavigation())));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Splash Screen"),
      ),
    );
  }
}
