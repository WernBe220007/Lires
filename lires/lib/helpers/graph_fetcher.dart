import 'dart:io';
import 'package:http/http.dart';
import 'dart:async';
import 'package:lires/config.dart';

class GraphApi {
  static Future<Response> getUserData(String token) async {
    return await get(Uri.parse(GraphConfig.uri), headers: {
      HttpHeaders.authorizationHeader: "Bearer $token",
      "Accept": "application/json"
    });
  }

  static Future<Response> getProfilePicture(String token) async {
    String url = "/photo/\$value";
    return await get(Uri.parse("${GraphConfig.uri}$url"), headers: {
      HttpHeaders.authorizationHeader: "Bearer $token",
      "Accept": "application/json"
    });
  }
}