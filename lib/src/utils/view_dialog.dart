import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 


class ViewDialog {
  
  static void showConfirmDialog(BuildContext context, { 
      required String title, 
      required String content, 
      String btnCancelText = "", 
      String btnConfirmText = "", 
      Function? onCancelFunc,
      Function? onConfirmFunc
      }) {  
    if (btnCancelText.isEmpty) btnCancelText = AppLocalizations.of(context)!.cancel;
    if (btnConfirmText.isEmpty) btnConfirmText = AppLocalizations.of(context)!.confirm;
    if (Platform.isIOS) {
      showCupertinoDialog(context: context, builder: (BuildContext context) { 
        return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () { 
                  if (onCancelFunc != null) onCancelFunc(); 
                  Navigator.of(context).pop();
                },
                child: Text(btnCancelText),
              ),
              TextButton(
                onPressed: () {  
                  if (onConfirmFunc != null) onConfirmFunc(); 
                  Navigator.of(context).pop();
                },
                child: Text(btnConfirmText),
              ),
            ],
          );
        }
      );
    } else if (Platform.isAndroid) {
      showDialog(context: context, builder: (BuildContext context) { 
        return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () { 
                  if (onCancelFunc != null) onCancelFunc(); 
                  Navigator.of(context).pop();
                },
                child: Text(btnCancelText),
              ),
              TextButton(
                onPressed: () {  
                  if (onConfirmFunc != null) onConfirmFunc(); 
                  Navigator.of(context).pop();
                },
                child: Text(btnConfirmText),
              ),
            ],
          );
        }
      );
    }
  }

  static void showPermissionDialog(BuildContext context) {  
    if (Platform.isIOS) {
      showCupertinoDialog(context: context, builder: (BuildContext context) { 
        return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.microphonePermission),
            content: Text(AppLocalizations.of(context)!.microphonePermissionRequest),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () { 
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.goToSettings),
              ),
            ],
          );
        }
      );
    } else if (Platform.isAndroid) {
      showDialog(context: context, builder: (BuildContext context) { 
        return AlertDialog(
            title: Text(AppLocalizations.of(context)!.microphonePermission),
            content: Text(AppLocalizations.of(context)!.microphonePermissionRequest),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () { 
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.goToSettings),
              ),
            ],
          );
        }
      );
    }
  }

  static dialogErr(BuildContext context,
      {String title = "",
      required String content,
      String cancel = "Cancel",
      required VoidCallback cancelCallback}) {
    Widget cancelButton = TextButton(
      onPressed: () => cancelCallback(),
      child: Text(cancel),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return AlertDialog(
            title: title.isEmpty ? null : Text(title),
            content: Text(content),
            actions: [
              cancelButton,
            ],
          );
        }
        return CupertinoAlertDialog(
          title: title.isEmpty ? null : Text(title),
          content: Text(content),
          actions: [
            cancelButton,
          ],
        );
      },
    );
  }

  static Future<void> dialogDislikeOrReport(
    BuildContext context,
    VoidCallback dislikeCB,
    VoidCallback reportCB,
    VoidCallback? closeCB
    ) async { 
    if (Platform.isIOS) {
      switch (await showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: null, 
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, "Dislike"); },
                child: Wrap( 
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.sentiment_dissatisfied_outlined),
                    const SizedBox(width: 7),
                    Text(AppLocalizations.of(context)!.dislike, style: const TextStyle(fontSize: 17),),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, "Report"); },
                child: Wrap( 
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.report_outlined),
                    const SizedBox(width: 7),
                    Text(AppLocalizations.of(context)!.report, style: const TextStyle(fontSize: 17),),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, "Close"); },
                child: Wrap( 
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.cancel_outlined),
                    const SizedBox(width: 7),
                    Text(AppLocalizations.of(context)!.close, style: const TextStyle(fontSize: 17),),
                  ],
                ),
              ),
            ],
          );
        }
      )) {
        case "Dislike": dislikeCB(); break;
        case "Report": reportCB(); break;
        case "Close": if (closeCB != null) closeCB(); break;
      }
      return;
    }
    // Pour l'Android seul
    switch (await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: null, 
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, "Dislike"); },
              child: Wrap( 
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.sentiment_dissatisfied_outlined, size: 19),
                  const SizedBox(width: 7),
                  Text(AppLocalizations.of(context)!.dislike),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, "Report"); },
              child: Wrap( 
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.report_outlined, size: 19),
                  const SizedBox(width: 7),
                  Text(AppLocalizations.of(context)!.report),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, "Close"); },
              child: Wrap( 
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.cancel_outlined, size: 19),
                  const SizedBox(width: 7),
                  Text(AppLocalizations.of(context)!.close),
                ],
              ),
            ),
          ],
        );
      }
    )) {
      case "Dislike": dislikeCB(); break;
      case "Report": reportCB(); break;
      case "Close": if (closeCB != null) closeCB(); break;
    }
  }
  
}

