import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_c2copine/src/models/response_model.dart';
import 'package:flutter_c2copine/src/models/status_code.dart';
import 'package:flutter_c2copine/src/statemng/account.dart'; 


class Requester {

  late Dio dio = Dio(); 
  // late Dio dioProber = Dio(); 

  Requester() { 
    // dio.options.headers["Content-Type"] = "application/json";
    // dio.options.headers["Accept"] = "application/json";
    // dio.options.connectTimeout = const Duration(seconds: 60); 
    // dio.options.receiveTimeout = const Duration(seconds: 60); 

    // dioProber.options.connectTimeout = const Duration(seconds: 3);
    // dioProber.options.receiveTimeout = const Duration(seconds: 3);

    if (Platform.isAndroid) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        HttpClient client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) { 
          if (cert.issuer.contains('Sectigo') && host == 'api.macopine.space') {
            // 允许Sectigo证书通过验证，因为api.macopine.space使用的是Sectigo RSA Domain Validation Secure Server CA证书
            // 也不知道什么原因，在Android上Dio会报错unable to get local issuer certificate，iOS正常
            // 可运行此命令 openssl s_client -connect api.macopine.space:443 -servername api.macopine.space -showcerts 查看证书信息
            return true;
          } 
          // 其他证书按默认验证
          return false;
        }; 
        return client;
      };
    }
  }

  Future<String> getApiDomain() async { 
    return "https://api.macopine.space"; // AWS EC2 instance  
  }

  // Future<bool> checkGoogleAccess() async { 
  //   try { 
  //     Response response = await dioProber.get('https://www.google.com'); 
  //     if (response.statusCode == 200) {
  //       return true;
  //     }  
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Future<C2HttpResponse> sendAudio(String msgId, String audioFilepath, List<Map<String, String>> messages) async {  
    try {
      var acc = Account();
      var formData = FormData.fromMap({
        "type": "audio",
        "model": Account().aiEngine,
        "messages": jsonEncode(messages),
        'file': await MultipartFile.fromFile(
          audioFilepath,
          contentType: DioMediaType('audio', 'wav'),  
        ),
        "msg_id": msgId,
        "local_user_id": acc.localUserId,
        "app_platform": acc.appPlatform,
        "bundle_id": acc.bundleID,
        "app_version": acc.appVersion,
      }); 
      String apiDomain = await getApiDomain(); 
      Response response = await dio.post(
        "$apiDomain/api/conversation/audio",
        data: formData,
      );
      if (response.statusCode == 200) {
        final respData = Map<String, String>.from(response.data["data"]);
        return C2HttpResponse(C2CodeSuccess, "", respData); 
      } 
      return C2HttpResponse(C2CodeFailure, response.statusMessage ?? response.data as String, {});  
    } catch (e) { 
      if (e.toString().contains("DioException")) {
        return C2HttpResponse(C2CodeFailure, "Network error", {}); 
      }
      return C2HttpResponse(C2CodeFailure, "$e", {}); 
    }
  }

  downloadAudio(String audioFilename, String saveToFilepath) async {
    try {
      String apiDomain = await getApiDomain();
      Response response = await dio.download("$apiDomain/api/conversation/audio/download?audio_name=$audioFilename", saveToFilepath);
      if (response.statusCode == 200) {
        return C2HttpResponse(C2CodeSuccess, "", {});
      }
      return C2HttpResponse(C2CodeFailure, response.statusMessage ?? response.data as String, {}); 
    } catch (e) { 
      if (e.toString().contains("DioException")) {
        return C2HttpResponse(C2CodeFailure, "Network error while parsing audio", {}); 
      }
      return C2HttpResponse(C2CodeFailure, "$e", {}); 
    }
  }

  Future<C2HttpResponse> askGrammarOrStructure(String msgId, String userText, List<Map<String, String>> messages) async {
    try {
      var acc = Account();
      var params = { 
        "model": Account().aiEngine,
        "user_lang": Account().getLanguageName(),
        "messages": jsonEncode(messages),
        'user_text': userText,
        "msg_id": msgId,
        "local_user_id": acc.localUserId,
        "app_platform": acc.appPlatform,
        "bundle_id": acc.bundleID,
        "app_version": acc.appVersion,
      }; 
      String apiDomain = await getApiDomain();
      Response response = await dio.post("$apiDomain/api/conversation/chat", data: params);
      if (response.statusCode == 200) {
        final respData = Map<String, String>.from(response.data["data"]);
        return C2HttpResponse(C2CodeSuccess, "", respData); 
      }  
      return C2HttpResponse(C2CodeFailure, response.statusMessage ?? response.data as String, {}); 
    } catch (e) { 
      if (e.toString().contains("DioException")) {
        return C2HttpResponse(C2CodeFailure, "Network error while asking grammar or structure", {}); 
      }
      return C2HttpResponse(C2CodeFailure, "$e", {}); 
    }
  }

  // Like, Dislike, Report
  Future<C2HttpResponse> feedbackForAIContent(String msgId, String type, String genre, String userText, String aiContent) async {
    try {
      var acc = Account();
      var params = {  
        "msg_id": msgId,
        "type": type,
        "genre": genre, // text or audio
        'user_text': userText,
        "ai_content": aiContent,
        "user_lang": Account().getLanguageName(),
        "local_user_id": acc.localUserId,
        "app_platform": acc.appPlatform,
        "bundle_id": acc.bundleID,
        "app_version": acc.appVersion,
      }; 
      String apiDomain = await getApiDomain();
      Response response = await dio.post("$apiDomain/api/feedback/message", data: params);
      if (response.statusCode == 200) {
        final respData = Map<String, String>.from(response.data["data"]);
        return C2HttpResponse(C2CodeSuccess, "", respData); 
      }  
      return C2HttpResponse(C2CodeFailure, response.statusMessage ?? response.data as String, {}); 
    } catch (e) { 
      if (e.toString().contains("DioException")) {
        return C2HttpResponse(C2CodeFailure, "Network error while asking grammar or structure", {}); 
      }
      return C2HttpResponse(C2CodeFailure, "$e", {}); 
    }
  }

  // Soumet les données d'achat intégré

  Future<C2HttpResponse> postPreorderData(String genId, String price, String currency, String productID) async {
    try {
      var acc = Account();
      var params = { 
        "tx_gen_id": genId,
        "local_user_id": acc.localUserId,
        "price": price,
        "currency": currency,
        "environment": kDebugMode ? "Sandbox" : "Production",
        "product_id": productID, 
        "user_lang": acc.getLanguageName(),
        "app_platform": acc.appPlatform,
        "bundle_id": acc.bundleID,
        "app_version": acc.appVersion,
      }; 
      String apiDomain = await getApiDomain();
      Response response = await dio.post("$apiDomain/api/iap/preorder", data: params);
      if (response.statusCode == 200) {
        final respData = Map<String, String>.from(response.data["data"]);
        return C2HttpResponse(C2CodeSuccess, "", respData); 
      }  
      return C2HttpResponse(C2CodeFailure, response.statusMessage ?? response.data as String, {}); 
    } catch (e) { 
      if (e.toString().contains("DioException")) {
        return C2HttpResponse(C2CodeFailure, "Network error while preorder", {}); 
      }
      return C2HttpResponse(C2CodeFailure, "$e", {}); 
    }
  }

  Future<C2HttpResponse> postPurchaseData(int transactionDate, String productID, String purchaseID, String verificationData) async {
    try {
      var acc = Account();
      var params = { 
        "local_user_id": acc.localUserId,
        "transaction_date": transactionDate,
        "product_id": productID,
        "purchase_id": purchaseID,
        "user_lang": acc.getLanguageName(),
        "app_platform": acc.appPlatform,
        "bundle_id": acc.bundleID,
        "app_version": acc.appVersion,
        "verification_data": verificationData,
      }; 
      String apiDomain = await getApiDomain();
      Response response = await dio.post("$apiDomain/api/iap/complete", data: params);
      if (response.statusCode == 200) {
        final respData = Map<String, String>.from(response.data["data"]);
        return C2HttpResponse(C2CodeSuccess, "", respData); 
      }  
      return C2HttpResponse(C2CodeFailure, response.statusMessage ?? response.data as String, {}); 
    } catch (e) { 
      if (e.toString().contains("DioException")) {
        return C2HttpResponse(C2CodeFailure, "Network error while completing the purchase", {}); 
      }
      return C2HttpResponse(C2CodeFailure, "$e", {}); 
    }
  }

  Future<C2HttpResponse> queryPurchaseData() async {
    try {
      var params = { 
        "local_user_id": Account().localUserId,
      }; 
      String apiDomain = await getApiDomain();
      Response response = await dio.post("$apiDomain/api/iap/query", data: params);
      if (response.statusCode == 200) {
        final respData = Map<String, int>.from(response.data["data"]);
        return C2HttpResponse(C2CodeSuccess, "", respData); 
      }  
      return C2HttpResponse(C2CodeFailure, response.statusMessage ?? response.data as String, {}); 
    } catch (e) { 
      if (e.toString().contains("DioException")) {
        return C2HttpResponse(C2CodeFailure, "Network error while query the purchase", {}); 
      }
      return C2HttpResponse(C2CodeFailure, "$e", {}); 
    }
  }

}