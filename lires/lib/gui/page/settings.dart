import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lires/helpers/user_manager.dart';
import 'package:lires/persistent/app_preferences.dart';
import 'package:lires/main.dart';
import 'package:provider/provider.dart';
import 'package:lires/structures/colorsprovider.dart';
import 'package:lires/config.dart';
import 'package:lires/helpers/api_fetcher.dart';
import 'package:lires/gui/component/profilePicture.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool darkMode = false;

  @override
  void initState() {
    AppPreferences.getDarkMode().then((value) {
      setState(() {
        darkMode = value;
      });
    });

    super.initState();
  }

  Future<Response> fetchServer() async {
    return await ServerApi.wrappedFetcher(
        await AadAuthentication.getOAuth()!.getIdToken() ?? "",
        ServerApi.getUserTrips);
  }


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<LiResState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (MediaQuery.of(context).size.width <= 600)
                          const ProfilePicture(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (MediaQuery.of(context).size.width > 600)
                              const ProfilePicture(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${UserManager.getUserFirstname() ?? 'Unbekannt'} ${UserManager.getUserLastname() ?? 'Unbekannt'}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
                                Text(
                                    "Email: ${UserManager.getEmail() ?? 'Unbekannt'}", overflow: TextOverflow.ellipsis,),
                                Text(
                                    "Rolle: ${UserManager.getPrivileged().toString().split(".")[1]}", overflow:  TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                Text(
                                    "Raum: ${UserManager.getUserOfficeLocation() ?? 'Unbekannt'}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                              child: Text(
                                  colorNameMap[entry.key] ?? 'Unbekannt',
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
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: const Text('Einstellungen zurücksetzen'),
                              content: const Text(
                                  'Möchten Sie wirklich alle Einstellungen zurücksetzen?'),
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
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Zurücksetzen')),
                              ],
                            ));
                  },
                  child: const Text('Zurücksetzen')),
              const SizedBox(
                height: 40,
              ),
              FilledButton(
                  onPressed: () {
                    UserManager.logout(context);
                  },
                  child: const Text('Logout')),
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text("Erweitert"),
                children: [
                  Text("Token: ${ServerApi.bearerToken ?? "Kein Token"}"),
                  const Text("Scopes:"),
                  Wrap(
                    children:
                        ServerApi.getTokenScopes(ServerApi.bearerToken ?? "")
                            .map((scope) => Chip(label: Text(scope)))
                            .toList(),
                  )
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<Response>(
                future: fetchServer(),
                builder:
                    (BuildContext context, AsyncSnapshot<Response> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text('Loaded: ${snapshot.data!.body.toString()}');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
