import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lires/config.dart';
import 'dart:convert';
import 'package:lires/helpers/api_fetcher.dart';
import 'package:intl/intl.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => OverviewState();
}

class OverviewState extends State<Overview> {
    Future<Response> fetchTrips() async {
    return await ServerApi.wrappedFetcher(await AadAuthentication.getOAuth()!.getIdToken() ?? "", ServerApi.getUserTrips);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Übersicht'),
        ),
        body: SingleChildScrollView(
            child: Center(
                child: FutureBuilder(
                    future: fetchTrips(),
                    builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Column(children: [
                          for (var trip in jsonDecode(snapshot.data!.body))
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(trip["name"], style: Theme.of(context).textTheme.headlineSmall),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text("Start: "),
                                        OutlinedButton(onPressed: null, child: Text(DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(trip["startdate"]))),)
                                      ],
                                    ),
                                                                       Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text("Ende: "),
                                        OutlinedButton(onPressed: null, child: Text(DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(trip["enddate"]))),)
                                      ],
                                    ),
                                    FilledButton(onPressed: () async {
                                      // Show confirmation dialog
                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Anwesenheit bestätigen"),
                                              content: const Text("Sie bestätigen ihre Anwesenheit zu diesem Ausflug?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text("Abbrechen")),
                                                TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      await ServerApi.wrappedFetcherArgs(await AadAuthentication.getOAuth()!.getIdToken() ?? "", ServerApi.acknowledgeTrip, trip["id"].toString());
                                                    },
                                                    child: const Text("Bestätigen"))
                                              ],
                                            );
                                          });
                                    }, child: const Text("Bestätigen"))
                                  ],
                                ),
                              ),
                            )
                        ]);
                      }
                    }))));
  }
}
