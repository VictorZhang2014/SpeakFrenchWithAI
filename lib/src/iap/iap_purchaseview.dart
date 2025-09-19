import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_c2copine/src/network/requester.dart';
import 'package:flutter_c2copine/src/settings/settings_controller.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/utils/general_webview.dart';
import 'package:flutter_c2copine/src/utils/view_dialog.dart';
import 'package:flutter_c2copine/src/localization/app_localizations.dart'; 
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:notification_centre/notification_centre.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';


class IAPPurchaseView extends StatefulWidget {
  const IAPPurchaseView({super.key, required this.controller});

  static const routeName = '/iap_purchaseview';

  final SettingsController controller;

  @override
  State<StatefulWidget> createState() => _IAPPurchaseViewState();
}

class _IAPPurchaseViewState extends State<IAPPurchaseView> { 
  late VideoPlayerController _videoController;
  
  late bool loadingProducts = false;
  late bool showIndicator = false;
  late bool paymentInProgress = false;

  bool isHiddenAnimatedSubTitle = true;
  bool isYearly = true;
  bool isAgreedTheProtocol = true;
  late List<String> iapCapabilitiesList = [];

  late List<ProductDetails> productList = [];
  late List<PurchaseDetails> purchasedList = [];
  late Set<String> productIds = {
    "macopine.plus.monthly",
    "macopine.plus.annually"
  };
  late Timer? timer;
  late String iapBilledDescription = "";

  @override
  void initState() { 
    super.initState(); 
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse("https://www.qimei.org/assets/video/video_silent_bg1.mp4"),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        setState(() {
          _videoController.setLooping(true);
          _videoController.play();
        });
      }); 
    setup();
  }

  @override
  void dispose() {
    timer?.cancel();
    NotificationCenter().removeObserver(NOTIFICATION_NAME_PURCHASE_COMPLETED, this);
    super.dispose();
    debugPrint("IAPPurchaseView disposed");
  }

  void setup() async {      
    NotificationCenter().addObserver(NOTIFICATION_NAME_PURCHASE_COMPLETED, this, (Map<String, dynamic> data) { 
      if (data["type"] == "error") { 
        ViewDialog.dialogErr(context, content: "Purchase Failed", cancel: "OK", cancelCallback: () { Navigator.pop(context); });
      } 
      if (data["type"] == "completed") {
        listenToPurchaseUpdated(data["data"]);
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        updateIAPCapabilities(); 
      }
    });

    if (Platform.isIOS) {
      setupAppStore();
    } else if (Platform.isAndroid) {
      setupPlayStore();
    }

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (purchasedList.isNotEmpty) {
        for (int a = 0; a < purchasedList.length; a++) {
          if (purchasedList[a].pendingCompletePurchase) {
            completedPurchase(purchasedList[a]);
            purchasedList.removeAt(a);
          }
        }
      }
    }); 
  }

  Future<bool> isStoreAvailable() async {
    return await InAppPurchase.instance.isAvailable(); 
  } 

  void setupAppStore() async {  
    setState(() { loadingProducts = true; });
    try {  
      final purchaseResponse = await InAppPurchase.instance.queryProductDetails(productIds);  
      productList = List.from(purchaseResponse.productDetails);  
      if (productList.isEmpty) {
        var monthlyItem = ProductDetails(id: "macopine.plus.monthly", title: "ParlerAI Plus Monthly", description: "", price: "\$12.99", rawPrice: 12.99, currencyCode: "USD");
        var yearlyItem = ProductDetails(id: "macopine.plus.annually", title: "ParlerAI Plus Annually", description: "", price: "\$99.00", rawPrice: 99.00, currencyCode: "USD");
        productList.add(monthlyItem);
        productList.add(yearlyItem);
      }
      changeTheItemPrice();  
    } catch (e) {
      debugPrint("InAppPurchase AppStore:: $e");
    } 
    Future.delayed(const Duration(seconds: 2), () {
      setState(() { loadingProducts = false; });
    });
  }

  void setupPlayStore() async {  
    setState(() { loadingProducts = true; });
    try {  
      final purchaseResponse = await InAppPurchase.instance.queryProductDetails(productIds); 
      productList = List.from(purchaseResponse.productDetails);  
      changeTheItemPrice();
    } on PlatformException catch (e) { 
      debugPrint("InAppPurchase PlayStore:: '${e.message}'.");
    }
    Future.delayed(const Duration(seconds: 2), () {
      setState(() { loadingProducts = false; });
    });
  }

  void changeTheItemPrice() {
    if (productList.isEmpty) {
      debugPrint("No product list found while changeTheItemPrice!");
      return;
    }
    ProductDetails monthlyItem = productList[0];
    ProductDetails yearlyItem = productList[1];
    for (var product in productList) {
      if (product.id == "macopine.plus.monthly" && !isYearly) {
        monthlyItem = product;
      }
      if (product.id == "macopine.plus.annually" && isYearly) {
        yearlyItem = product;
      }
    }  
    // Locale currentLocale = Localizations.localeOf(context);
    // var formatCurrency = NumberFormat.simpleCurrency(locale: currentLocale.toString()); 
    // formatCurrency.format(yearlyItem.rawPrice) // 99,99 €
    setState(() {
      if (isYearly) { 
        iapBilledDescription = AppLocalizations.of(context)!.iapBilledYearly;
        iapBilledDescription = iapBilledDescription.replaceFirst("\$99.00", yearlyItem.price);
      } else {
        iapBilledDescription = AppLocalizations.of(context)!.iapBilledMonthly;
        iapBilledDescription = iapBilledDescription.replaceFirst("\$12.99", monthlyItem.price);
      }
    });
  }

  void pay() async {
    String promptToSignIn = "Your In-App Purchases are not available or you haven't yet signed in your account in App Store at the moment. Please try again later.";
    if (!await isStoreAvailable()) {
      ViewDialog.dialogErr(context, content: promptToSignIn, cancel: "OK", cancelCallback: () { Navigator.pop(context); });
      return;
    }
    if (productList.isEmpty) {
      debugPrint("No product list found!");
      return;
    }
    hideIndicator(false); 
    ProductDetails selectedItem = productList[0];
    for (var product in productList) {
      if (product.id == "macopine.plus.monthly" && !isYearly) {
        selectedItem = product;
      }
      if (product.id == "macopine.plus.annually" && isYearly) {
        selectedItem = product;
      }
    } 
    HapticFeedback.mediumImpact();
    try {
      String txGenId = const Uuid().v4(); 
      await Requester().postPreorderData(
        txGenId, 
        ((selectedItem.rawPrice * 1000).toInt()).toString(), 
        selectedItem.currencyCode,
        selectedItem.id);
      final purchaseParam = PurchaseParam(productDetails: selectedItem, applicationUserName: txGenId);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) { 
      debugPrint("InAppPurchase Pay:: '${e.message}'.");
      ViewDialog.dialogErr(context, content: promptToSignIn, cancel: "OK", cancelCallback: () { Navigator.pop(context); });
    } 
    hideIndicator(true); 
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async { 
    // debugPrint("listenToPurchaseUpdated=====>${purchaseDetailsList.length}");
    purchasedList = List.from(purchaseDetailsList);
    for (var detail in purchaseDetailsList) {
      var tStatus = detail.status;
      // debugPrint("===>tStatus====>$tStatus==>${PurchaseStatus.purchased}==>${PurchaseStatus.restored}");
      if (Platform.isAndroid) {
        final localData = jsonDecode(detail.verificationData.localVerificationData) as Map<String, dynamic>;
        if (localData["orderId"].length > 0 && localData["purchaseTime"] > 0) {
          tStatus = PurchaseStatus.purchased;
        }
      }
      if (tStatus == PurchaseStatus.pending) { 
        if (mounted) setState(() { showIndicator = true; });
      } else {
        if (tStatus == PurchaseStatus.purchased || tStatus == PurchaseStatus.restored) {
          if (tStatus == PurchaseStatus.purchased) {
            //showMsg(AppLocalizations.of(context)!.iapPurchaseSucceeds);
            await updateDataAfterPurchase(detail); 
          }
          Future.delayed(const Duration(seconds: 3), () { 
            hideIndicator(true); 
            if (detail.pendingCompletePurchase) {  
              completedPurchase(detail);     
              if (mounted && Navigator.canPop(context)) Navigator.pop(context); 
            } else {
              purchasedList.add(detail);
            }
          });  
        } else if (tStatus == PurchaseStatus.canceled) {
            Future.delayed(const Duration(seconds: 3), () { 
              if (showIndicator) hideIndicator(true);
            });
            showMsg(AppLocalizations.of(context)!.iapPurchaseCancelled); 
        } else if (tStatus == PurchaseStatus.error) { 
          hideIndicator(true);
          // var s = detail.error?.message ?? "Unexpected error when the purchase occurred";
          // showMsg("code: ${detail.error?.code} \nmessage: $s");
          debugPrint(detail.error.toString());
        }
      }
    }
  }

  void completedPurchase(PurchaseDetails detail) async { 
    await InAppPurchase.instance.completePurchase(detail); 
    var tStatus = detail.status; 
    if (Platform.isAndroid) {
      final localData = jsonDecode(detail.verificationData.localVerificationData) as Map<String, dynamic>;
      if (localData["orderId"].length > 0 && localData["purchaseTime"] > 0) {
        tStatus = PurchaseStatus.purchased;
      }
    }
    if (tStatus == PurchaseStatus.purchased || tStatus == PurchaseStatus.restored) {
      // NotificationCenter().postNotification(NOTIFICATION_NAME_PURCHASED_SUCCESS, data: {});
    } 
  }

  Future<void> updateDataAfterPurchase(PurchaseDetails detail) async {
    int plusMember = isYearly ? 2 : 1;
    await Account().updatePlusMember(plusMember);
    String verificationData = "";
    if (Platform.isAndroid) {
      verificationData = detail.verificationData.localVerificationData; 
    } else { 
      verificationData = detail.verificationData.serverVerificationData; 
    }
    // debugPrint("detail.verificationData.source=" + detail.verificationData.source);
    int transDate = int.tryParse(detail.transactionDate!) ?? 0; 
    await Requester().postPurchaseData(transDate, detail.productID, detail.purchaseID ?? "", verificationData);
  } 

  void hideIndicator(bool isHidden) {
    if (mounted) {
      setState(() { showIndicator = !isHidden; });
    }
  }

  void showMsg(String msg) {
    ViewDialog.dialogErr(context, content: msg, cancel: "OK", cancelCallback: () { Navigator.pop(context); });
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    double margin = 20;
    double btnWidth = s.width - margin * 2;
    double statusBarHeight = MediaQuery.viewInsetsOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            // margin: const EdgeInsets.only(top: 80),
            child: _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : Container(),
          ), 
          Container(
            color: Colors.black.withAlpha(130),
            width: s.width,
            height: s.height,
          ),
          Container(
            margin: EdgeInsets.only(top: statusBarHeight + 44),
            height: 40, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container( 
                    margin: const EdgeInsets.only(left: 20),
                    height: 40, 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: widget.controller.mColor.divider.withAlpha(40),
                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                          ),
                          child: Icon(Icons.close, color: Colors.white.withAlpha(150), size: 22),
                        ), 
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async { 
                    try {
                      hideIndicator(false); 
                      await InAppPurchase.instance.restorePurchases(); 
                      hideIndicator(true); 
                    } catch (e) { 
                      hideIndicator(true); 
                      showMsg(e.toString()); 
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 15), 
                    child: Text(
                      AppLocalizations.of(context)!.iapRestore,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ), 
              ],
            ),
          ),
          Container( 
            width: s.width,
            height: isHiddenAnimatedSubTitle ? 125 : 170,
            margin: EdgeInsets.only(top: s.height * 0.5 - (isHiddenAnimatedSubTitle ? 125 : 170)), 
            child: Column( 
              children: [ 
                isHiddenAnimatedSubTitle ?
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      AppLocalizations.of(context)!.iapCapabilityTitle, 
                      textStyle: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600),  
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 200),
                    ),
                  ], 
                  totalRepeatCount: 2, 
                  onFinished: () {
                    setState(() { 
                      isHiddenAnimatedSubTitle = false;
                    });
                  },
                ) : 
                Container(
                  child: Text(
                    AppLocalizations.of(context)!.iapCapabilityTitle, 
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600), 
                  ),
                ), 
                isHiddenAnimatedSubTitle ? Container() : Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: s.width,
                  height: 30, 
                  child: Text(
                    AppLocalizations.of(context)!.iapCapabilitySubtitle, 
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: s.width,
              height: s.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), 
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column( 
                children: [ 
                  const SizedBox(height: 10),
                  Container(
                    width: btnWidth, 
                    height: s.height * 0.5 - (10 + 45 + 50 + 56 + 40), 
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: iapCapabilitiesList.length,
                      itemBuilder: (context, position) {
                        return ListTile(
                          // contentPadding: EdgeInsets.zero,
                          minTileHeight: 30,
                          leading: Icon(Icons.check_rounded, color: widget.controller.mColor.primary1, size: 22),
                          title: Text(
                            iapCapabilitiesList[position],
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    ),
                  ),   
                  const Spacer(),
                  Container(
                    width: btnWidth,
                    height: 45, 
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: widget.controller.mColor.divider.withAlpha(120), width: 1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      runAlignment: WrapAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            isYearly = false; 
                            updateIAPCapabilities();
                            changeTheItemPrice();
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            width: btnWidth * 0.45,
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            color: !isYearly ? widget.controller.mColor.tertiary.withAlpha(60) : Colors.transparent,
                            child: Text(
                              AppLocalizations.of(context)!.iapMonthlyBtn, 
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ), 
                        GestureDetector(
                          onTap: () {
                            isYearly = true; 
                            updateIAPCapabilities();
                            changeTheItemPrice();
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            width: btnWidth * 0.45,
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            color: isYearly ? widget.controller.mColor.tertiary.withAlpha(60) : Colors.transparent,
                            child: Text(
                              AppLocalizations.of(context)!.iapYearlyBtn,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),   
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: btnWidth, 
                    height: 25,
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Center(
                      child: Text(
                        iapBilledDescription,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),  
                  GestureDetector(
                    onTap: () {
                      if (loadingProducts) return;
                      setState(() { isAgreedTheProtocol = true; }); 
                      pay();
                    },
                    child: Container(
                      width: btnWidth,
                      height: 56, 
                      decoration: BoxDecoration(
                        color: loadingProducts ? Colors.transparent : widget.controller.mColor.primary1,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: loadingProducts ? const CupertinoActivityIndicator(radius: 15, color: Colors.white)
                          : Text(
                          getPayButtonText(), 
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ), 
                  ), 
                  
                  Container(
                    width: btnWidth,
                    margin: const EdgeInsets.only(top: 5),
                    // padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() { isAgreedTheProtocol = !isAgreedTheProtocol; }); 
                          },
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: isAgreedTheProtocol ? widget.controller.mColor.primary1 : Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: createAgreementLinks(),
                        ),
                      ],
                    ),
                  ),  

                  const SizedBox(height: 20),
                ]
              ),
            ),
          ),

          showIndicator ? Container(width: double.infinity, height: double.infinity, color: Colors.black.withAlpha(70)) : Container(),
          showIndicator ? const Center(child: CupertinoActivityIndicator(radius: 20, color: Colors.white)) : Container(),
        ],
      ),
    );
  }

  Widget createAgreementLinks() {
    List<String> termsOfUseArr = AppLocalizations.of(context)!.iapIHaveReadAndConsentedTermsOfUse("TermsOfUse", "PrivacyPolicy", "EULA").split("TermsOfUse");
    String termsOfUse = termsOfUseArr[0];
    List<String> privacyPolicyArr = termsOfUseArr[1].split("PrivacyPolicy");
    String privacyPolicy = privacyPolicyArr[0];
    List<String> EULAArr = privacyPolicyArr[1].split("EULA");
    String EULA = EULAArr[0];
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(text: termsOfUse), 
          TextSpan(
            text: AppLocalizations.of(context)!.termsofService,
            style: const TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).pushNamed(GeneralWebView.routeName, arguments: "https://www.qimei.org/terms-of-use.html");
              },
          ), 
          TextSpan(text: privacyPolicy), 
          TextSpan(
            text: AppLocalizations.of(context)!.privacyPolicy,
            style: const TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).pushNamed(GeneralWebView.routeName, arguments: "https://www.qimei.org/privacy-policy.html");
              },
          ), 
          TextSpan(text: EULA), 
          TextSpan(
            text: AppLocalizations.of(context)!.appleTermsOfUse,
            style: const TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).pushNamed(GeneralWebView.routeName, arguments: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/");
              },
          ), 
          const TextSpan(text: "."), 
        ],
      ),
    );
  }

  updateIAPCapabilities() {
    iapCapabilitiesList = [
      AppLocalizations.of(context)!.iapCapability1,
      AppLocalizations.of(context)!.iapCapability2,
      AppLocalizations.of(context)!.iapCapability3,
      AppLocalizations.of(context)!.iapCapability4, 
    ]; 
    if (isYearly) {
      iapCapabilitiesList.add(AppLocalizations.of(context)!.iapCapability8);
      iapCapabilitiesList.add(AppLocalizations.of(context)!.iapCapability5);
      iapCapabilitiesList.add(AppLocalizations.of(context)!.iapCapability6);
    } else {
      iapCapabilitiesList.add(AppLocalizations.of(context)!.iapCapability7);
    }
    setState(() { });
  } 

  String getPayButtonText() {
    String suffixText = "";
    if (isYearly) {
      suffixText = AppLocalizations.of(context)!.iapYearlyBtn;
    } else {
      suffixText = AppLocalizations.of(context)!.iapMonthlyBtn;
    }
    return "${AppLocalizations.of(context)!.iapPayButton.replaceFirst("ParlerAI", "")} $suffixText";
  }

}
