import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:lires/main.dart';


class AadAuthentication {
  static final AadOAuth _oauth = AadOAuth(config);

  //static Future<void> getEnv() async {
  //  await dotenv.load(fileName: "assets/azure.env");
  //  _oauth = AadOAuth(config);
  //}

  static final Config config = Config(
    tenant: '88fae967-01b4-42f0-8966-32a990173948',
    clientId: '4f397fa9-b781-443c-8187-30ea6b940bc2',
    scope: 'openid profile offline_access User.Read',
    redirectUri: 'lires://auth',
    navigatorKey: Lires.navigatorKey,
  );

  static AadOAuth? getOAuth() {
    return _oauth;
  }
}

class GraphConfig {
  static const String uri = "https://graph.microsoft.com/v1.0/me";
}

class ApiConfig {
  static const String uri = "https://192.168.98.195:8080/api/";
}

class GeneralConfig {
  static const bool ignoreServerConnection = true;
}