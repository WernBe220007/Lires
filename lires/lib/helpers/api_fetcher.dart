import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:async';
import 'package:lires/config.dart';
import 'package:http/io_client.dart';

class ServerApi {
  static String? bearerToken;

  static Future<Response> authenticate(String token) async {
    HttpClient client = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    var ioClient = IOClient(client);
    return await ioClient.get(Uri.parse("${ApiConfig.uri}token"), headers: {
      HttpHeaders.authorizationHeader: "Bearer $token",
      "Accept": "application/json"
    });
  }

  static Future<Response> getUserData(String token) async {
    HttpClient client = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    var ioClient = IOClient(client);
    return await ioClient.get(Uri.parse("${ApiConfig.uri}users/me/"), headers: {
      HttpHeaders.authorizationHeader: "Bearer $token",
      "Accept": "application/json"
    });
  }

  static bool checkTokenExpiry(String token) {
    var parts = token.split(".");
    if (parts.length != 3) {
      return false;
    }
    var payload = parts[1];
    var payloadJson = json.decode(
        ascii.decode(base64.decode(base64.normalize(payload))));
    var expiry = payloadJson["exp"];
    var expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
    return expiryDate.isAfter(DateTime.now());
  }

  static List<String> getTokenScopes(String token) {
    var parts = token.split(".");
    if (parts.length != 3) {
      return [];
    }
    var payload = parts[1];
    var payloadJson = json.decode(
        ascii.decode(base64.decode(base64.normalize(payload))));
    var scopes = payloadJson["scopes"];
    return scopes != null ? List<String>.from(scopes) : [];
  }

  static Future<Response> wrappedFetcher(String msIdToken, dynamic Function(String) fetcher) async {
    // Do we have an existing token and is it valid?
    if (bearerToken != null && checkTokenExpiry(bearerToken!)) {
      return await fetcher(bearerToken!);
    }

    // If not, authenticate and fetch
    Response response = await authenticate(msIdToken);
    if (response.statusCode == 200) {
      String token = json.decode(response.body)["access_token"];
      bearerToken = token;
      return await fetcher(token);
    } else {
      throw Exception("Failed to authenticate with server");
    }
  }
}