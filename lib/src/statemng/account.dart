import 'dart:io';
import 'dart:ui';  
import 'package:uuid/uuid.dart'; 
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 

class Account {
  
  Account.alloc();
  static final Account _instance = Account.alloc();
  factory Account() =>  _instance;
 
  bool darkMode = false;
  String languageCode = "fr";
  String aiEngine = "openai";

  String appVersion = "";
  String appPlatform = "";
  String bundleID = "";

  String localUserId = ""; // Generated locally once opened, every user has a local unique id
  int plusMember = 0; // 1 = Monthly, 2 = Yearly, 0 = No subscription
  String subscribeExpiredTime = "";

  bool isHiddenUserGuide = false;
  bool isHiddenUserPermission = false;

  // String userId = "";
  // String userToken = "";
  // String userEmail = "";
  // String userName = "";
  // String avatarUrl = "";

  // String afUserId = "";
  // String afStatus = "";
  // String afMediaSource = "";
  // String afCampaign = "";


  Future<void> setup() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    bundleID = packageInfo.packageName;
    appPlatform = Platform.isAndroid ? "android" : "ios";
    
    await readLocalUserId();
    await readPlusMember();
    // await readUserInfo();
    
    await readDarkMode();
    await readAIEngine();
    await readLanguageCode();

    await readHiddenUserGuide();
    await readHiddenUserPermission();
  }

  Future<String> readLocalUserId() async {
    String id = (await SharedPreferences.getInstance()).getString('P_LOCAL_USER_ID') ?? "";
    if (id.isEmpty) {   
      String localId = const Uuid().v4(); 
      localUserId = localId;
      await (await SharedPreferences.getInstance()).setString('P_LOCAL_USER_ID', localUserId);
    } else {
      localUserId = id;
    }
    return localUserId;
  }

  Future<int> readPlusMember() async {
    var m = (await SharedPreferences.getInstance()).getInt('P_PLUS_MEMBER');
    return plusMember = m ?? 0;
  }

  Future<void> updatePlusMember(int member) async {
    plusMember = member;
    await (await SharedPreferences.getInstance()).setInt('P_PLUS_MEMBER', plusMember);
  }

  Future<String> readSubscribeExpiredTime() async {
    var m = (await SharedPreferences.getInstance()).getString('P_SUBSCRIBE_EXPIRED_TIME');
    return subscribeExpiredTime = m ?? "";
  }

  Future<void> updateSubscribeExpiredTime(String time) async {
    subscribeExpiredTime = time;
    await (await SharedPreferences.getInstance()).setString('P_SUBSCRIBE_EXPIRED_TIME', subscribeExpiredTime);
  }
  
  Future<bool> readHiddenUserGuide() async {
    var m = (await SharedPreferences.getInstance()).getBool('P_HIDDEN_USER_GUIDE'); 
    return isHiddenUserGuide = m ?? false;
  }

  Future<void> updateHiddenUserGuide(bool isHidden) async {
    isHiddenUserGuide = isHidden;
    await (await SharedPreferences.getInstance()).setBool('P_HIDDEN_USER_GUIDE', isHiddenUserGuide);
  }

  Future<bool> readHiddenUserPermission() async {
    var m = (await SharedPreferences.getInstance()).getBool('P_HIDDEN_USER_PERMISSION'); 
    return isHiddenUserPermission = m ?? false;
  }

  Future<void> updateHiddenUserPermission(bool isHidden) async {
    isHiddenUserPermission = isHidden;
    await (await SharedPreferences.getInstance()).setBool('P_HIDDEN_USER_PERMISSION', isHiddenUserPermission);
  }
  
  // Future<void> updateUserInfo(String id, String token, String email, String name, String avatar, int vip) async {
  //   userToken = token; 
  //   userId = id;
  //   avatarUrl = avatar;
  //   var data = <String, dynamic>{
  //     "id": id,
  //     "token": token,
  //     "email": email,
  //     "name": name,
  //     "avatar": avatar,
  //     "vip": vip,
  //   }; 
  //   await (await SharedPreferences.getInstance()).setString('P_USER_INFO', json.encode(data));
  // }

  // Future<void> readUserInfo() async { 
  //   var infoStr = (await SharedPreferences.getInstance()).getString('P_USER_INFO');   
  //   if (infoStr != null && infoStr.isNotEmpty) {
  //     var info = json.decode(infoStr);
  //     userId = NullCheck.forString(info["id"]);
  //     userToken = NullCheck.forString(info["token"]);
  //     userEmail = NullCheck.forString(info["email"]);
  //     userName = NullCheck.forString(info["name"]);
  //     avatarUrl = NullCheck.forString(info["avatar"]);
  //     vip = NullCheck.forInt(info["vip"]); 
  //   } 
  // }
  
  Future<void> updateDarkMode(bool mode) async {
    darkMode = mode; 
    await (await SharedPreferences.getInstance()).setBool('P_DARK_MODE', darkMode);
  }

  Future<bool> readDarkMode() async {  
    var m = (await SharedPreferences.getInstance()).getBool('P_DARK_MODE');
    return darkMode = m ?? false;
  }
   
  Future<void> updateLanguageCode(String code) async {
    languageCode = code;
    await (await SharedPreferences.getInstance()).setString('P_LANGUAGE_CODE', languageCode); 
  }

  Future<String> readLanguageCode() async { 
    var c = (await SharedPreferences.getInstance()).getString('P_LANGUAGE_CODE');  
    return languageCode = c ?? readSystemLanguageCode();
  }

  String readSystemLanguageCode() {
    String code = "fr"; 
    for (Locale locale in AppLocalizations.supportedLocales) {
      if (Platform.localeName.startsWith(locale.languageCode)) {
        code = locale.languageCode;
        break;
      }
    }
    return code;
  }
  
  Future<void> updateAIEngine(String engine) async {
    aiEngine = engine;
    await (await SharedPreferences.getInstance()).setString('P_AI_ENGINE', engine); 
  }

  Future<String> readAIEngine() async { 
    var c = (await SharedPreferences.getInstance()).getString('P_AI_ENGINE');  
    return aiEngine = c ?? "openai";
  }
 
  // Future<void> clearUserData() async {
  //   userId = "";
  //   userToken = "";
  //   userName = "";
  //   avatarUrl = "";
  //   plusMember = 0;
  //   await updateUserInfo("", "", "", "", "", 0);
  // }


  // Map<String, dynamic> playRecordMap = {};

  // savePlayRecord(String img, String title, int chapterNum, int videoId, int episodeId) {
  //   playRecordMap["img"] = img;
  //   playRecordMap["title"] = title;
  //   playRecordMap["chapterNum"] = chapterNum;
  //   playRecordMap["videoId"] = videoId;
  //   playRecordMap["episodeId"] = episodeId;
  //   SharedPreferences.getInstance().then((value) {
  //     value.setString("playRecord", jsonEncode(playRecordMap));
  //   });
  // }

  // Future<Map<String, dynamic>?> getPlayRecord() async {
  //   final recordString = (await SharedPreferences.getInstance()).getString("playRecord");
  //   if(recordString == null) return null;
  //   try{
  //     playRecordMap = jsonDecode(recordString);
  //   // ignore: empty_catches
  //   } catch(e) {
      
  //   }
  //   return playRecordMap;
  // }



  /* Values will not save on local. */

  bool isNotPlusMember() {
    return plusMember == 0;
  }

  bool isPlusMonthly() {
    return plusMember == 1;
  }

  bool isPlusYearly() {
    return plusMember == 2;
  }

  bool isLogin() {
    return false;
    // return userToken.isNotEmpty;
  }



  /* ///////////////////////////////// */

  String getLanguageName() {
    return languageCode;
    // switch (languageCode) {
    //   case "en":
    //     return "anglais";
    //   case "fr":
    //     return "français";
    //   case "de":
    //     return "allemand";
    //   case "zh":
    //     return "chinois simplifié";
    //   case "zh_hant":
    //     return "chinois traditionnel";
    //   case "id":
    //     return "indonésien";
    //   case "vi":
    //     return "vietnamienne";
    //   default:
    //     return "";
    // }
  }


}
