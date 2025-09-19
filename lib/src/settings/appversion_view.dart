import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/utils/Images.dart';
import 'package:flutter_c2copine/src/utils/general_webview.dart';
import 'settings_controller.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 


class AppVersionView extends StatelessWidget {
  const AppVersionView({super.key, required this.controller});

  static const routeName = '/appversion_view';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double margin = 20;
    Color bgColor = Colors.grey[100]!;
    double cardHeight = 55;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.about), 
        backgroundColor: Colors.white,
      ),
      backgroundColor: bgColor,
      body: Container(
        margin: EdgeInsets.all(margin),
        child: Column(
          children: [ 
            Container(
              margin: const EdgeInsets.only(top: 100, bottom: 20), 
              clipBehavior: Clip.antiAlias,
              decoration:  BoxDecoration(
                borderRadius: BorderRadius.circular(17)  
              ),
              child: Images.local("logo", 150),
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
                title: Text(AppLocalizations.of(context)!.version), 
                trailing: Text(
                  Platform.isAndroid ? "v1.0.0" : "v1.0.1+10", 
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
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
                title: Text(AppLocalizations.of(context)!.privacyPolicy), 
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                onTap: () => Navigator.of(context).pushNamed(GeneralWebView.routeName, arguments: "https://www.qimei.org/privacy-policy.html"),
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
                title: Text(AppLocalizations.of(context)!.termsofService), 
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                onTap: () => Navigator.of(context).pushNamed(GeneralWebView.routeName, arguments: "https://www.qimei.org/terms-of-use.html"),
              ), 
            ),
          ],
        ),
      ),
    );
  }

}
