import 'dart:async'; 
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:notification_centre/notification_centre.dart';  

class IAPHandler { 

  InAppPurchase inAppPurchaseInstance; 
  IAPHandler(this.inAppPurchaseInstance);

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<bool> buy(String productId) async {
    if (!await inAppPurchaseInstance.isAvailable()) {
      return false;
    }
    final response = await inAppPurchaseInstance.queryProductDetails({productId}); 
    if (response.error != null) {
      return false;
    }
    if (response.productDetails.length != 1) {
      return false;
    }
    final productDetails = response.productDetails.single;

    final purchaseParam = PurchaseParam(productDetails: productDetails);
    try {
      final success = await inAppPurchaseInstance.buyNonConsumable(
          purchaseParam: purchaseParam);
      return success;
    } catch (e) { 
      if (kDebugMode) {
        print("Failed to pay with error => $e");
      }
      return false;
    }
  } 
 
  Future<void> restorePurchases() async {
    if (!await inAppPurchaseInstance.isAvailable()) {
      return;
    }
    try {
      await inAppPurchaseInstance.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not restore in-app purchases: $e');
      }
    }
  }

  void subscribe() {
    _subscription?.cancel();
    _subscription = inAppPurchaseInstance.purchaseStream.listen((purchaseDetailsList) {
      NotificationCenter().postNotification(NOTIFICATION_NAME_PURCHASE_COMPLETED, data: {"data": purchaseDetailsList, "type": "completed"});
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (dynamic error) {
      NotificationCenter().postNotification(NOTIFICATION_NAME_PURCHASE_COMPLETED, data: {"type": "error"});
    });
  } 
  
}
