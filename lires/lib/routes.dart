import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lires/gui/clientnavigation.dart';

final Map<String, WidgetBuilder> routes = {
  "/clientnavigation": (context) => const ClientNavigation(),
};



class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      /*
      Example:
      // Storage
      case '/addStorage':
        return MaterialPageRoute(builder: ((context) => const AddStorage()));
      case '/alterStorage':
        if (args is String) {
          return MaterialPageRoute(
              builder: ((context) => StorageSettings(storageName: args)));
        }
        return _errorRoute();
      */

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: const Text("Error")),
          body: const Center(
            child: Text("Error"),
          ));
    });
  }
}
