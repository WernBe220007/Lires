import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lires/config.dart';
import 'package:lires/helpers/graph_fetcher.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    super.key,
  });

  Future<Response> fetchGraph() async {
    return await GraphApi.getProfilePicture(
        await AadAuthentication.getOAuth()!.getAccessToken() ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.width > 600 ? MediaQuery.of(context).size.width / 8 : MediaQuery.of(context).size.width / 3, maxWidth: MediaQuery.of(context).size.width > 600 ? MediaQuery.of(context).size.width / 8 : MediaQuery.of(context).size.width / 3),
      child: Center(
        child: FutureBuilder<Response>(
          future: fetchGraph(),
          builder: (BuildContext context,
              AsyncSnapshot<Response> snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                return Text(
                    'Error: ${snapshot.error}');
              } else {
                if (snapshot.data!.statusCode ==
                    200) {
                  return Padding(
                    padding:
                        const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(100),
                      child: Image.memory(
                          snapshot.data!.bodyBytes),
                    ),
                  );
                } else {
                  return Padding(
                    padding:
                        const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(100),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context,
                                BoxConstraints
                                    constraints) {
                          return Icon(
                            Icons.person,
                            size: min(
                                constraints.maxHeight,
                                constraints.maxWidth),
                          );
                        },
                      ),
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}