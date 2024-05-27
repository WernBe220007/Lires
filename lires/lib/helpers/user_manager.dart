import 'package:flutter/material.dart';
import 'package:lires/structures/priveleges.dart';
import 'package:lires/persistent/secure_storage.dart';
import 'dart:convert';
import 'package:lires/config.dart';
import 'package:http/http.dart';
import 'package:lires/helpers/graph_fetcher.dart';
import 'package:lires/logging.dart';
import 'package:lires/helpers/api_fetcher.dart';
import 'package:lires/main.dart';

class UserManager {
  static String? _email;
  static Priveleges? _priviliged;
  static String? _userFirstname;
  static String? _userLastname;
  static String? _userOfficeLocation;

  static String? getEmail() {
    return _email;
  }

  static Priveleges? getPrivileged() {
    return _priviliged;
  }

  static String? getUserFirstname() {
    return _userFirstname;
  }

  static String? getUserLastname() {
    return _userLastname;
  }

  static String? getUserOfficeLocation() {
    return _userOfficeLocation;
  }

  static fromJson(dynamic apiUser, dynamic microsoftUser) {
    _email = (microsoftUser == null) ? apiUser["email"] : microsoftUser["mail"];
    _priviliged = (apiUser == null)
        ? Priveleges.student
        : Priveleges.values.firstWhere(
            (e) => e.toString() == 'Priveleges.${apiUser["privelege_level"]}');
    _userFirstname = (microsoftUser == null)
        ? apiUser["firstname"]
        : microsoftUser["givenName"];
    _userLastname = (microsoftUser == null)
        ? apiUser["lastname"]
        : microsoftUser["surname"];
    _userOfficeLocation = (microsoftUser == null)
        ? apiUser["officeLocation"]
        : microsoftUser["officeLocation"];
  }

  static Future<bool> reloadUserData() async {
    try {
      String? token = await AadAuthentication.getOAuth()!.getIdToken();
      Response response =
          await ServerApi.wrappedFetcher(token!, ServerApi.getUserData);
      Logging.logger.d(response.statusCode);
      if (response.statusCode != 200) {
        LiResState.globalSnackbar = SnackBar(content: Text("Fehler bei Kommunikation mit server: ${response.statusCode}"));
        return GeneralConfig.ignoreServerConnection;
      }
      var apiJson = jsonDecode(response.body);
      _priviliged = Priveleges.values.firstWhere(
          (e) => e.toString() == 'Priveleges.${apiJson["privelege_level"]}');
      return true;
    } catch (e) {
      LiResState.globalSnackbar = SnackBar(content: Text("Fehler bei Kommunikation mit server: $e"));
      return GeneralConfig.ignoreServerConnection;
    }
  }

  static Future<void> logout(BuildContext context) async {
    UserSecureStorage.deleteAll();
    AadAuthentication.getOAuth()!.logout();
    Navigator.pushReplacementNamed(context, "/login");
  }

  static Future<LoginResponse> login(bool remember) async {
    //try {
    await AadAuthentication.getOAuth()!.logout(); // log out of existing
    await AadAuthentication.getOAuth()!.login(); // Start new login
    String? accessToken = await AadAuthentication.getOAuth()!.getAccessToken();
    String? idToken = await AadAuthentication.getOAuth()!.getIdToken();

    if (accessToken == null || idToken == null) {
      return LoginResponse(false, "Failed to aquire token from microsoft");
    } // Succesfully aquired token

    if (accessToken.isEmpty || idToken.isEmpty) {
      return LoginResponse(false, "Failed to aquire token from microsoft");
    } // Succesfully aquired token

    Logging.logger.d("Access token: $accessToken");
    Logging.logger.d("Id token: $idToken");

    Response response = await GraphApi.getUserData(accessToken);
    var jsonDecoded = jsonDecode(response.body);
    Logging.logger.d(jsonDecoded);

    // Authenticate against API
    Response apiResponse = await ServerApi.authenticate(idToken);
    if (apiResponse.statusCode != 200) {
      return LoginResponse(false, "Failed to authenticate with API");
    }
    var apiJson = jsonDecode(apiResponse.body);
    String apiToken = apiJson["access_token"];
    Logging.logger.d(apiJson);
    Logging.logger.d("API token: $apiToken");

    // Get user data from API
    Response apiUserResponse = await ServerApi.getUserData(apiToken);
    if (apiUserResponse.statusCode != 200) {
      return LoginResponse(false, "Failed to get user data from API");
    }
    var apiUserJson = jsonDecode(apiUserResponse.body);
    Logging.logger.d(apiUserJson);

    // Save user data
    ServerApi.bearerToken = apiToken;
    UserManager.fromJson(apiUserJson, jsonDecoded);
    if (remember) {
      UserSecureStorage.setUserValues(apiUserJson, jsonDecoded);
      UserSecureStorage.setRememberState(remember.toString());
    } else {
      UserSecureStorage.setRememberState(false.toString());
    }
    return LoginResponse(true, "Success");
    //} catch (e) {
    //  Logging.logger.e(e.toString());
    //  return LoginResponse(false, e.toString());
    //}
  }
}

class LoginResponse {
  bool response;
  String message;
  LoginResponse(this.response, this.message);
}
