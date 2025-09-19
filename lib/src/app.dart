import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/home/aiengine_choose_view.dart';
import 'package:flutter_c2copine/src/home/call_ai_view.dart';
import 'package:flutter_c2copine/src/home/home_audio_view.dart';
import 'package:flutter_c2copine/src/home/home_grammar_view.dart';
import 'package:flutter_c2copine/src/home/user_guide_view.dart';
import 'package:flutter_c2copine/src/home/user_permission_view.dart';
import 'package:flutter_c2copine/src/iap/iap_purchaseview.dart';
import 'package:flutter_c2copine/src/settings/appversion_view.dart';
import 'package:flutter_c2copine/src/settings/privacy_data_view.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/user/login_view.dart';
import 'package:flutter_c2copine/src/utils/general_webview.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';


class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp( 
          restorationScopeId: 'app',
          debugShowCheckedModeBanner: false,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: settingsController.appLanguage == "zh_hant" ? 
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant') : 
            Locale(settingsController.appLanguage), 
          supportedLocales: AppLocalizations.supportedLocales,

          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appParlerAI,

          theme: ThemeData(),
          darkTheme: ThemeData.light(),
          themeMode: settingsController.themeMode,

          onGenerateRoute: (RouteSettings routeSettings) { 
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                
                switch (routeSettings.name) {
                  case HomeAudioView.routeName:
                    return HomeAudioView(controller: settingsController);
                  case AIEngineChooseView.routeName:
                    return AIEngineChooseView(controller: settingsController);
                  case CallAIView.routeName:
                    return CallAIView(controller: settingsController);
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case AppVersionView.routeName:
                    return AppVersionView(controller: settingsController);
                  case PrivacyDataView.routeName:
                    return PrivacyDataView(controller: settingsController); 
                  case GeneralWebView.routeName:
                    return GeneralWebView(url: routeSettings.arguments.toString());
                  case LoginView.routeName:
                    return LoginView(controller: settingsController);
                  case IAPPurchaseView.routeName:
                    return IAPPurchaseView(controller: settingsController);
                  case UserPermissionView.routeName:
                    return UserPermissionView(controller: settingsController);
                  default: { 
                    if (Platform.isIOS && !Account().isHiddenUserPermission) { 
                      return UserPermissionView(controller: settingsController);
                    } 
                    if (!Account().isHiddenUserGuide) { 
                      return UserGuideView(controller: settingsController);
                    }
                    return HomeGrammarView(controller: settingsController);
                  } 
                }
              },
            );
          }, 

          builder: EasyLoading.init(), 
        );
      },
    );
  }
}
