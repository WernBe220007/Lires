import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lires/helpers/graph_fetcher.dart';
import 'package:lires/helpers/user_manager.dart';
import 'package:lires/logging.dart';
import 'package:lires/persistent/app_preferences.dart';
import 'package:lires/main.dart';
import 'package:provider/provider.dart';
import 'package:lires/structures/colorsprovider.dart';
import 'package:lires/config.dart';
import 'dart:convert';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool darkMode = false;
  var profilePicture;

  @override
  void initState() {
    AppPreferences.getDarkMode().then((value) {
      setState(() {
        darkMode = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<LiResState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(UserManager.getUserFirstname() ?? 'Unbekannt'),
            Text(UserManager.getUserLastname() ?? 'Unbekannt'),
            Text(UserManager.getEmail() ?? 'Unbekannt'),
            Text(UserManager.getPrivileged().toString()),
            Text(UserManager.getUserOfficeLocation() ?? 'Unbekannt'),
            TextButton(onPressed: () async {
              String? token = await AadAuthentication.getOAuth()!.getAccessToken();
              var temp = await GraphApi.getProfilePicture(token!);
              var picture = temp.body;
              Logging.logger.d(picture);
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Profilbild'),
                content: SizedBox(),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Schließen')),
                ],
              ));
            }, child: const Text('Profilbild')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Dark Mode:'),
                const SizedBox(width: 10),
                Switch(
                    value: darkMode,
                    onChanged: (value) {
                      setState(() {
                        darkMode = value;
                        AppPreferences.setDarkMode(value);
                        appState.updateListeners();
                      });
                    }),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Farbe:'),
                const SizedBox(width: 10),
                DropdownButton(
                  value: AppPreferences.getSelectedColorSync(),
                  items: colorMap.entries
                      .map((entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(colorNameMap[entry.key] ?? 'Unbekannt',
                                style: TextStyle(color: entry.value)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    AppPreferences.setSelectedColor(value as int);
                    appState.updateListeners();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
                onPressed: () async {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: const Text('Einstellungen zurücksetzen'),
                    content: const Text('Möchten Sie wirklich alle Einstellungen zurücksetzen?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Abbrechen')),
                      TextButton(
                          onPressed: () async {
                            await AppPreferences.clear();
                            appState.updateListeners();
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Zurücksetzen')),
                    ],
                  ));
                },
                child: const Text('Zurücksetzen')),
            const Spacer(),
            FilledButton(
                onPressed: () {
                  UserManager.logout(context);
                },
                child: const Text('Logout')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
