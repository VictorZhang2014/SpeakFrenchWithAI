//
//  StoreManager.swift
//  Runner
//
//  Créé le 7 mai 2025.
//

import StoreKit


class StoreManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var products: [SKProduct] = []
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func requestInAppPurchasesProducts(_ productIDs: Set<String>) {
        // AppsFlyerLib.shared().logEvent("ios_in_app_purchases", withValues: ["status":"requested_product_ids"])
        let productRequest = SKProductsRequest(productIdentifiers: productIDs)
        productRequest.delegate = self
        productRequest.start()
    }

    /// SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        print("products=\(products)")
    }
 
    func buy(_ productID: String, quantity: Int, applicationUsername: String) {
        guard let product = products.first(where: { $0.productIdentifier == productID }) else {
            return
        }
        // AppsFlyerLib.shared().logEvent("ios_in_app_purchases", withValues: ["status":"requested_payment"])
        let payment = SKMutablePayment(product: product)
        payment.quantity = quantity
        payment.applicationUsername = applicationUsername
        SKPaymentQueue.default().add(payment)
    }
 
    
    // SKPaymentTransactionObserver methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                case .purchased: completeTransaction(transaction)
                case .failed: failedTransaction(transaction)
                default: break
            }
        }
    }

    func completeTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
         // let receiptString = getReceiptDataStr()
         // print("swift.receiptString=\(receiptString)");
        // AppsFlyerLib.shared().logEvent("ios_in_app_purchases", withValues: ["status":"completed"])
    }

    func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as NSError? {
            if error.code != SKError.paymentCancelled.rawValue {
                // AppsFlyerLib.shared().logEvent("ios_in_app_purchases", withValues: ["status":"failed", "error": error.localizedDescription])
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func getReceiptDataStr() -> String {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                return receiptData.base64EncodedString(options: [])
            } catch {
                print("Parse Receipt Data Error: \(error.localizedDescription)")
            }
        }
        return ""
    }
    
//    func fetchSubscriptionDates() async {
//        do {
//            if #available(iOS 15.0, *) {
//                let products = try await Product.products(for: ["com.example.app.subscription"])
//            } else {
//                // Fallback on earlier versions
//            }
//            if let product = products.first,
//               let subscriptionInfo = product.subscription {
//                let renewalDate = subscriptionInfo.renewalInfo?.renewalDate
//                let startDate = subscriptionInfo.renewalInfo?.recentSubscriptionStartDate
//
//                print("Date de début : \(startDate?.description ?? "N/A")")
//                print("Date de renouvellement : \(renewalDate?.description ?? "N/A")")
//            }
//        } catch {
//            print("Erreur lors de la récupération des informations d'abonnement : \(error)")
//        }
//    }
    
}

