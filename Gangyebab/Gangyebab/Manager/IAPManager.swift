//
//  IAPManager.swift
//  Gangyebab
//
//  Created by 이동현 on 3/25/24.
//

import Foundation
import StoreKit

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

protocol IAPDelegate: AnyObject {
    func showResult(_ result: Bool)
}

final class IAPManager: NSObject {
    private let productIdentifiers: Set<String>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    weak var delegate: IAPDelegate?
    
    override init() {
        self.productIdentifiers = [
            DonateProduct.ball.id,
            DonateProduct.snack.id,
            DonateProduct.cake.id,
            DonateProduct.cloth.id
        ]
        super.init()
        SKPaymentQueue.default().add(self)
        addNotificationCenter()
    }
    
    deinit {
        removeNotificationCenter()
    }
    
    func loadProductsRequest(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    //상품 목록 로드 성공
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
    }
    //상품 목록 로드 실패
    func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - notification
extension IAPManager {
    private func addNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseNotification),
            name: .iapServicePurchaseNotification,
            object: nil
        )
    }
    
    private func removeNotificationCenter() {
        NotificationCenter.default.removeObserver(
            self,
            name: .iapServicePurchaseNotification,
            object: nil
        )
    }
    
    @objc private func handlePurchaseNotification(_ notification: Notification) {
        guard let result = notification.object as? Bool else { return }
        
        delegate?.showResult(result)
    }

}

// MARK: - 구매
extension IAPManager {
    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .deferred, .purchasing:
                break
            case .restored:
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    // 구입 성공
    private func complete(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // 구매 실패
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription,
           transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let id = identifier else {
            NotificationCenter.default.post(
                name: .iapServicePurchaseNotification,
                object: false
            )
            return
        }
        
        NotificationCenter.default.post(
            name: .iapServicePurchaseNotification,
            object: true
        )
    }
}

enum DonateProduct {
    case ball
    case snack
    case cake
    case cloth
    
    var id: String {
        switch self {
        case .ball:
            return "3000"
        case .snack:
            return "5000"
        case .cake:
            return "10000"
        case .cloth:
            return "15000"
        }
    }
}

extension Notification.Name {
    static let iapServicePurchaseNotification = Notification.Name("IAPServicePurchaseNotification")
}
