class MicrosoftUser {
  static String? context;
  static String? businessPhones;
  static String? displayName;
  static String? givenName;
  static String? jobTitle;
  static String? mail;
  static String? mobilePhone;
  static String? officeLocation;
  static String? preferredLanguage;
  static String? surname;
  static String? userPrincipalName;
  static String? id;

  static Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json.addAll({
      "context": context ?? "",
      "businessPhones": businessPhones ?? "",
      "displayName": displayName ?? "",
      "givenName": givenName ?? "",
      "jobTitle": jobTitle,
      "mail": mail ?? "",
      "mobilePhone": mobilePhone ?? "",
      "officeLocation": officeLocation ?? "",
      "preferredLanguage": preferredLanguage ?? "",
      "surname": surname,
      "userPrincipalName": userPrincipalName ?? "",
      "id": id ?? "",
    });

    return json;
  }

  static void fromJson(Map<String, dynamic> json) {
    context = json["context"];
    businessPhones = json["businessPhones"];
    displayName = json["displayName"];
    givenName = json["givenName"];
    jobTitle = json["jobTitle"];
    mail = json["mail"];
    mobilePhone = json["mobilePhone"];
    officeLocation = json["officeLocation"];
    preferredLanguage = json["preferredLanguage"];
    surname = json["surname"];
    userPrincipalName = json["userPrincipalName"];
    id = json["id"];
  }
}
