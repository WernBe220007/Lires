import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lires/config.dart';
import 'package:lires/helpers/api_fetcher.dart';
import 'package:intl/intl.dart';
import 'package:lires/logging.dart';
import 'package:lires/main.dart';
import 'package:provider/provider.dart';

class TripTile extends StatefulWidget {
  final Map<String, dynamic> trip;
  const TripTile({
    super.key,
    required this.trip,
  });

  @override
  State<TripTile> createState() => TripTileState();
}

class TripTileState extends State<TripTile> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<LiResState>();
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
      onPressed: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(widget.trip["name"],
                style: Theme.of(context).textTheme.headlineSmall),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Start: "),
                OutlinedButton(
                  onPressed: null,
                  child: Text(DateFormat('dd.MM.yyyy - kk:mm')
                      .format(DateTime.parse(widget.trip["startdate"]))),
                )
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Ende: "),
                OutlinedButton(
                  onPressed: null,
                  child: Text(DateFormat('dd.MM.yyyy - kk:mm')
                      .format(DateTime.parse(widget.trip["enddate"]))),
                )
              ],
            ),
            if (widget.trip["acknowledged"])
              const FilledButton(onPressed: null, child: Text("Bestätigt"))
            else
              FilledButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Anwesenheit bestätigen"),
                            content: const Text(
                                "Sie bestätigen ihre Anwesenheit zu diesem Ausflug?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Abbrechen")),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    Response resp =
                                        await ServerApi.wrappedFetcherArgs(
                                            await AadAuthentication.getOAuth()!
                                                    .getIdToken() ??
                                                "",
                                            ServerApi.acknowledgeTrip,
                                            widget.trip["id"].toString());
                                    Logging.logger.d(resp.body);
                                    Logging.logger.d(resp.statusCode);
                                    appState.updateListeners();
                                    //setState(() {});
                                  },
                                  child: const Text("Bestätigen"))
                            ],
                          );
                        });
                  },
                  child: const Text("Bestätigen"))
          ],
        ),
      ),
    );
  }
}
