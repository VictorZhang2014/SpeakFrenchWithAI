import 'package:flutter/material.dart'; 
import 'package:flutter_c2copine/src/localization/app_localizations.dart';  
import 'package:webview_flutter/webview_flutter.dart';


class GeneralWebView extends StatefulWidget {
  const GeneralWebView({super.key, required this.url});

  static const routeName = '/general_webview';

  final String url;

  @override
  State<StatefulWidget> createState() => _GeneralWebAccess();
}

class _GeneralWebAccess extends State<GeneralWebView> {
  late WebViewController webViewController;

  late String title = "";
  late double progressBar = 5;

  @override
  void initState() {
    super.initState(); 

     webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) { 
          },
          onProgress: (int progress) { 
            setState(() {
              progressBar = progress * 1.0;
            });
          },
          onPageFinished: (String url) async { 
            if (mounted) {
              await fetchDocTitle();
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
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() { 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double ecranWidth = MediaQuery.of(context).size.width; 
    return Scaffold(
      appBar: AppBar(
        title: Text(
            title.isEmpty ? 
            AppLocalizations.of(context)!.loading : 
            title,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          progressBar == 100 ? Container() : Container( 
            height: 1.5,
            width: progressBar / 100.0 * ecranWidth,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  fetchDocTitle() async {
    var docTitle = await webViewController.runJavaScriptReturningResult("document.title");
    if (mounted) {
      setState(() {
        title = docTitle.toString();
      });
    }
  }

}
