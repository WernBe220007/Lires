import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lires/config.dart';
import 'dart:convert';
import 'package:lires/helpers/api_fetcher.dart';
import 'package:lires/helpers/user_manager.dart';
import 'package:lires/structures/priveleges.dart';
import 'package:lires/gui/component/trip_tile.dart';
import 'package:provider/provider.dart';
import 'package:lires/main.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => OverviewState();
}

class OverviewState extends State<Overview> {
  Priveleges privelege = UserManager.getPrivileged() ?? Priveleges.student;

  Future<Response> fetchTrips() async {
    return await ServerApi.wrappedFetcher(await AadAuthentication.getOAuth()!.getIdToken() ?? "", ServerApi.getUserTrips);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<LiResState>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Übersicht'),
        ),
        floatingActionButton: privelege != Priveleges.student
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/new');
                },
                child: const Icon(Icons.add),
              )
            : null,
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
                        if (jsonDecode(snapshot.data!.body).where((trip) => !trip["acknowledged"] || DateTime.parse(trip["startdate"]).isAfter(DateTime.now().subtract(const Duration(days: 1)))).isNotEmpty) {//(jsonDecode(snapshot.data!.body).isNotEmpty) {
                        return Column(children: [
                          for (var trip in jsonDecode(snapshot.data!.body).where((trip) => 
                            !trip["acknowledged"] || 
                            DateTime.parse(trip["startdate"]).isAfter(DateTime.now().subtract(const Duration(days: 1))))) 
                            TripTile(trip: trip,)
                        ]);
                      } else {
                        return Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height/3),
                            Text("Keine Ausflüge demnächst", style: Theme.of(context).textTheme.headlineLarge, textScaler: const TextScaler.linear(1),),
                          ],
                        );
                      }
                      }
                    }))));
  }
}

