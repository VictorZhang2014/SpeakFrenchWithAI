import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/utils/images.dart'; 
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart';  


class CallAIView extends StatefulWidget {
  const CallAIView({super.key, required this.controller});

  static const routeName = '/call_ai_view'; 

  final SettingsController controller;

  @override
  State<StatefulWidget> createState() => _CallAIViewState();

}

class _CallAIViewState extends State<CallAIView> {
  late WebViewController controller; 
 
  late String url = "https://staging.die53lifgn22o.amplifyapp.com/callcopine";

  bool isLoading = true; 

  @override
  void initState() {
    super.initState();  

    controller = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams(), 
      onPermissionRequest: (resources) async {
        return resources.grant(); 
      }) 
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) { 
          },
          onPageFinished: (String url) async {  
            if (mounted) {
              debugPrint("onPageFinished>>>>>>>>>");
              setState(() {
                isLoading = false;
              });
            } 
          },
          onHttpError: (HttpResponseError error) {
            debugPrint("onHttpError: ${error}");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("onWebResourceError: ${error}");
          }, 
        ),
      )
      ..loadRequest(Uri.parse(url));
  } 

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar( 
        backgroundColor: Colors.transparent, 
        iconTheme: const IconThemeData(color: Colors.white), // 设置返回按钮颜色
        title: Wrap(
          direction: Axis.vertical, 
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.appParlerAI, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            isLoading ? Text(
              "${AppLocalizations.of(context)!.connecting}...", 
              style: const TextStyle(color: Colors.orange, fontSize: 11),
            ) : Text(
              "● ${AppLocalizations.of(context)!.active}", 
              style: const TextStyle(color: Colors.green, fontSize: 11),
            ) 
          ],
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          isLoading ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Images.local("bg-beauty-blur-in-radical", s.width, fit: BoxFit.cover),
          ) : Container(),
          isLoading ? const Center(
            child: CircularProgressIndicator(color: Colors.white,),
          ) : Container(),
        ],
      )
    );
  }

}
 