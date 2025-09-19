import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/utils/view_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'settings_controller.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 


class PrivacyDataView extends StatelessWidget {
  const PrivacyDataView({super.key, required this.controller});

  static const routeName = '/privacydata_view';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double margin = 20;
    Color bgColor = Colors.grey[100]!;
    double cardHeight = 55;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacyData), 
        backgroundColor: Colors.white,
      ),
      backgroundColor: bgColor,
      body: Container(
        margin: EdgeInsets.all(margin),
        child: Column(
          children: [
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
                title: Text(AppLocalizations.of(context)!.deleteAllMyData), 
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                onTap: () {
                  ViewDialog.showConfirmDialog(
                    context,
                    title: AppLocalizations.of(context)!.deleteAllMyData,
                    content: AppLocalizations.of(context)!.deleteAllMyDataHints,
                    onConfirmFunc: () {
                      EasyLoading.showSuccess(AppLocalizations.of(context)!.operationCompleted, duration: const Duration(seconds: 1));
                    },
                  );
                },
              ), 
            ),
            Container(
              width: s.width, 
              margin: const EdgeInsets.all(7),
              color: Colors.transparent,
              child: Text(
                AppLocalizations.of(context)!.deleteAllMyDataHints,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            // Container(
            //   width: s.width,
            //   height: cardHeight,
            //   margin: const EdgeInsets.only(top: 20),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: const BorderRadius.all(Radius.circular(6)),
            //     border: Border(
            //       bottom: BorderSide(
            //         color: bgColor,
            //         width: 1,
            //       ),
            //     ),
            //   ),
            //   child: ListTile(
            //     title: Text(AppLocalizations.of(context)!.deleteMyAccount), 
            //     trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
            //     onTap: () {
            //       ViewDialog.showConfirmDialog(
            //         context,
            //         title: AppLocalizations.of(context)!.deleteMyAccount,
            //         content: AppLocalizations.of(context)!.deleteMyAccount,
            //         onConfirmFunc: () {
            //           EasyLoading.showSuccess(AppLocalizations.of(context)!.operationCompleted, duration: const Duration(seconds: 1));
            //         },
            //       );
            //     },
            //   ), 
            // ),
            // Container(
            //   width: s.width, 
            //   margin: const EdgeInsets.all(7),
            //   color: Colors.transparent,
            //   child: Text(
            //     AppLocalizations.of(context)!.deleteMyAccountHints,
            //     style: const TextStyle(fontSize: 12, color: Colors.grey),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

}
