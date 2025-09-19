import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_c2copine/firebase_options.dart';
import 'package:flutter_c2copine/src/iap/iap_handler.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; 
import 'src/settings/settings_controller.dart'; 
import 'src/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Account().setup();
  final settingsController = SettingsController();
  await settingsController.loadSettings(); 
  
  if (Platform.isIOS /*|| Platform.isAndroid*/) { 
    IAPHandler(InAppPurchase.instance).subscribe();
  }
  
  runApp(MyApp(settingsController: settingsController));
}
