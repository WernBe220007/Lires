import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lires/config.dart';
import 'dart:convert';
import 'package:lires/helpers/api_fetcher.dart';
import 'package:intl/intl.dart';
import 'package:lires/logging.dart';
import 'package:lires/gui/component/trip_tile.dart';
import 'package:provider/provider.dart';
import 'package:lires/main.dart';

class ReqestsView extends StatefulWidget {
  const ReqestsView({super.key});

  @override
  State<ReqestsView> createState() => ReqestsViewState();
}

class ReqestsViewState extends State<ReqestsView> {
  Future<Response> fetchTrips() async {
    return await ServerApi.wrappedFetcher(await AadAuthentication.getOAuth()!.getIdToken() ?? "", ServerApi.getUserTrips);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<LiResState>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Anfragen'),
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
                        if (jsonDecode(snapshot.data!.body).isNotEmpty) {
                        return Column(children: [
                          for (var trip in jsonDecode(snapshot.data!.body)) 
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
