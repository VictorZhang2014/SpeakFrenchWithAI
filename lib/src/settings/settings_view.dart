import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_c2copine/src/iap/iap_purchaseview.dart';
import 'package:flutter_c2copine/src/network/requester.dart'; 
import 'package:flutter_c2copine/src/settings/appversion_view.dart';
import 'package:flutter_c2copine/src/settings/privacy_data_view.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/utils/time_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'settings_controller.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 


class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings_view';

  final SettingsController controller;

  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool showIndicator = false;
  late String plusMemberStartTime = "";
  late String plusMemberExpiresDate = "";

  @override
  void initState() { 
    super.initState(); 
    queryData();
  } 

  Future<void> queryData() async { 
    String sExpiredTime = await Account().readSubscribeExpiredTime();
    if (sExpiredTime.isNotEmpty) {
      String formattedDate = TimeUtils.yMMMMd(int.parse(sExpiredTime), Account().languageCode);
      if (mounted) {
        setState(() {
          plusMemberExpiresDate = formattedDate;
        });
      }
    }
    var response = await Requester().queryPurchaseData(); 
    if (response.isSuccess) { 
      int expiresDate = response.data["expires_date"] * 1000; 
      if (expiresDate == 0) return;
      String formattedDate = TimeUtils.yMMMMd(expiresDate, Account().languageCode);
      if (mounted) {
        setState(() {
          plusMemberExpiresDate = formattedDate;
        });
      }
      Account().updateSubscribeExpiredTime(expiresDate.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double margin = 20;
    Color bgColor = Colors.grey[100]!;
    double cardHeight = 55;
    bool isNotPlusMember = Account().isNotPlusMember();  
    return Scaffold( 
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings), 
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle( 
          statusBarColor: Colors.black,   
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
      ),
      backgroundColor: widget.controller.mColor.background,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(margin * 1.5),
            child: Column(
              children: [

                Platform.isAndroid ? Container() : Container(
                  width: s.width,
                  height: 30, 
                  child: Text(
                    AppLocalizations.of(context)!.account.toUpperCase(), 
                    style: const TextStyle(
                      fontSize: 14, 
                      color: Colors.grey),
                    )
                ),
                // Container(
                //   width: s.width,
                //   height: cardHeight,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: const BorderRadius.only(
                //       topLeft: Radius.circular(6), 
                //       topRight: Radius.circular(6),
                //     ),
                //     border: Border(
                //       bottom: BorderSide(
                //         color: bgColor,
                //         width: 1,
                //       ),
                //     ),
                //   ),
                //   child: ListTile(
                //     leading: const Icon(Icons.mail_lock_rounded, color: Colors.black),
                //     title: Text(AppLocalizations.of(context)!.email),
                //     trailing: const Text("abc@aa.com", style: TextStyle(fontSize: 14),),
                //   ),
                // ),
                Platform.isAndroid ? Container() : GestureDetector(
                  onTap: () {
                    // if (isNotPlusMember) {
                      Navigator.of(context).pushNamed(IAPPurchaseView.routeName);  
                      // return;
                    // } 
                  },
                  child: Container(
                    width: s.width,
                    height: cardHeight,
                    color: Colors.white, 
                    child: isNotPlusMember ? ListTile(
                      leading: const Icon(Icons.add_box_rounded, color: Colors.black),
                      title: Text(AppLocalizations.of(context)!.subscription),
                      trailing: Text(AppLocalizations.of(context)!.parlerAIPlus, style: const TextStyle(fontSize: 14),),
                    ) : ListTile(
                      leading: const Icon(Icons.add_box_rounded, color: Colors.black),
                      title: Text(AppLocalizations.of(context)!.subscription), 
                      trailing: Text(
                        AppLocalizations.of(context)!.parlerAIPlus, 
                        style: TextStyle(
                          fontSize: 14, 
                          color: widget.controller.mColor.primary,
                        ),
                      ),
                    ),
                  ), 
                ),
                isNotPlusMember ? Container() : Container(
                  width: s.width,
                  height: cardHeight * 0.5,
                  padding: const EdgeInsets.only(left: 60),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: bgColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.iapValidUntilTheDate(plusMemberExpiresDate),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ), 
                ),
                Platform.isAndroid ? Container() : GestureDetector(
                  onTap: () async {
                    try {
                      setState(() { showIndicator = true; }); 
                      await InAppPurchase.instance.restorePurchases(); 
                      setState(() { showIndicator = false; }); 
                    } catch (e) {   
                      setState(() { showIndicator = false; }); 
                      await EasyLoading.showError(e.toString());
                    }
                  },
                  child: Container(
                    width: s.width,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: bgColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.refresh_rounded, color: Colors.black),
                      title: Text(AppLocalizations.of(context)!.restorePurchase),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                    ),
                  ),
                ),
                // Container(
                //   width: s.width,
                //   height: cardHeight,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: const BorderRadius.only(
                //       bottomLeft: Radius.circular(6), 
                //       bottomRight: Radius.circular(6),
                //     ),
                //     border: Border(
                //       bottom: BorderSide(
                //         color: bgColor,
                //         width: 1,
                //       ),
                //     ),
                //   ),
                //   child: ListTile(
                //     leading: const Icon(Icons.chat_rounded, color: Colors.black),
                //     title: Text(AppLocalizations.of(context)!.chatHistory),
                //     trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                //   ),
                // ),

                SizedBox(height: Platform.isAndroid ? 0 : margin),

                Container(
                  width: s.width,
                  height: cardHeight,
                  // margin: EdgeInsets.only(bottom: margin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6), 
                      topRight: Radius.circular(6),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: bgColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.timer_rounded, color: Colors.black),
                    title: Text(AppLocalizations.of(context)!.maximumRecording),
                    trailing: const Text("20s", style: TextStyle(fontSize: 14),),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6), 
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.language_rounded, color: Colors.black),
                    title: Text(AppLocalizations.of(context)!.changeLanguage),
                    trailing: DropdownButton<String>( 
                      value: widget.controller.appLanguage, 
                      onChanged: changeLanguage,
                      items: List.generate(getLanguagePairs().keys.length, (i) {
                          String key = getLanguagePairs().keys.elementAt(i);
                          String value = getLanguagePairs()[key]!;
                          return DropdownMenuItem(
                            value: key,
                            child: Text(value, style: const TextStyle(fontSize: 17),),
                          );
                        })
                    ),
                    onTap: () { }
                  ),
                ),


                /*
                Container(
                  width: s.width,
                  height: cardHeight,
                  margin: EdgeInsets.only(top: margin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    border: Border(
                      bottom: BorderSide(
                        color: bgColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.bubble_chart),
                    title: Text(AppLocalizations.of(context)!.aiEngine),
                    trailing: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(getAIEnginName(), style: const TextStyle(fontSize: 16),),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                      ],
                    ),
                    // trailing: DropdownButton<String>( 
                    //   value: controller.aiEngine, 
                    //   onChanged: changeAIEngine,
                    //   items: const [
                    //     DropdownMenuItem(
                    //       value: "openai",
                    //       child: Text('OpenAI'),
                    //     ),
                    //     DropdownMenuItem(
                    //       value: "deepseek",
                    //       child: Text('DeepSeek'),
                    //     ),
                    //     DropdownMenuItem(
                    //       value: "lechat",
                    //       child: Text('LeChat'),
                    //     ),
                    //   ],
                    // ), 
                    onTap: () { 
                      Navigator.of(context).pushNamed(AIEngineChooseView.routeName);
                    }
                  ),
                ), 
                Container(
                  width: s.width, 
                  margin: const EdgeInsets.all(10),
                  color: Colors.transparent,
                  child: Text(
                    getAIEnginHint(context),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                */
                
                Container(
                  width: s.width,
                  height: cardHeight,
                  margin: EdgeInsets.only(top: margin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                    border: Border(
                      bottom: BorderSide(
                        color: bgColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(AppLocalizations.of(context)!.privacyData), 
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                    onTap: () => Navigator.of(context).pushNamed(PrivacyDataView.routeName),
                  ),
                ),
                Container(
                  width: s.width,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                    border: Border(
                      bottom: BorderSide(
                        color: bgColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(AppLocalizations.of(context)!.about),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17), 
                    onTap: () => Navigator.of(context).pushNamed(AppVersionView.routeName),
                  ),
                ),
              ],
            ),
          ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16), 
      //   child: DropdownButton<ThemeMode>( 
      //     value: controller.themeMode, 
      //     onChanged: controller.updateThemeMode,
      //     items: const [
      //       DropdownMenuItem(
      //         value: ThemeMode.system,
      //         child: Text('System Theme'),
      //       ),
      //       DropdownMenuItem(
      //         value: ThemeMode.light,
      //         child: Text('Light Theme'),
      //       ),
      //       DropdownMenuItem(
      //         value: ThemeMode.dark,
      //         child: Text('Dark Theme'),
      //       )
      //     ],
      //   ),
      // ),

          showIndicator ? Container(width: double.infinity, height: double.infinity, color: Colors.black.withAlpha(30)) : Container(),
          showIndicator ? const Center(child: CupertinoActivityIndicator(radius: 20, color: Colors.white)) : Container(),
        ],
      ),
    );
  }

  Map<String, String> getLanguagePairs() {
    return {
      "en": "🌏 English",
      "fr": "🇫🇷 Français",
      "zh": "🇨🇳 简体中文",
      "zh_hant": "🇭🇰 繁体中文",
      "de": "🇩🇪 Deutsch",
      "it": "🇮🇹 Italiano", // Italian
      "ru": "🇷🇺 Русский", // Russian
      "es": "🇪🇸 Español", // Spanish
      "pl": "🇵🇱 Polski", // Polish
      "pt": "🇵🇹 Português", // Portuguese (Portugal)
      "hu": "🇭🇺 Magyar", // Hungarian
      "el": "🇬🇷 Ελληνικά", // Greek
      "ro": "🇷🇴 Română", // Romanian
      "ja": "🇯🇵 日本語",
      "ko": "🇰🇷 한국어",
      "id": "🇮🇩 Indonesia",
      "vi": "🇻🇳 Tiếng Việt",
      "ms": "🇲🇾 Melayu", // Malay
      "th": "🇹🇭 ภาษาไทย", // Thai
      "tr": "🇹🇷 Türkçe", // Turkish
      "uk": "🇺🇦 Українська", // Ukrainian
      "hi": "🇮🇳 हिन्दी", // Hindi
    };
  }

  String getAIEnginName() {
    if (widget.controller.aiEngine == "openai") {
      return "OpenAI";
    } else if (widget.controller.aiEngine == "deepseek") {
      return "DeepSeek";
    } else if (widget.controller.aiEngine == "lechat") {
      return "LeChat";
    } else if (widget.controller.aiEngine == "grok") {
      return "Grok";
    } else {
      return "";
    }
  }

  String getAIEnginHint(BuildContext c) {
    if (widget.controller.aiEngine == "openai") {
      return AppLocalizations.of(c)!.openaiIntro;
    } else if (widget.controller.aiEngine == "deepseek") {
      return AppLocalizations.of(c)!.deepseekIntro;
    } else if (widget.controller.aiEngine == "lechat") {
      return AppLocalizations.of(c)!.lechatIntro;
    } else if (widget.controller.aiEngine == "grok") {
      return AppLocalizations.of(c)!.grokIntro;
    } else {
      return "";
    }
  }

  void changeLanguage(String? v) {  
    widget.controller.changeAppLanguage(v!);
  }

  void changeAIEngine(String? v) {  
    widget.controller.changeAIEngine(v!);
  }

}
