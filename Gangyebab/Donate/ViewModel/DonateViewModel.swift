//
//  DonateViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/25/24.
//

import Foundation
import StoreKit

final class DonateViewModel: ViewModel {
    enum Input {
        case buy(_ id: String)
    }
    
    private var products: [SKProduct] = []
    private let iapManager = IAPManager()
    
    init(viewController: DonateViewController) {
        iapManager.delegate = viewController
        iapManager.loadProductsRequest({ success, products in
            if success {
                guard let products = products else { return }
                self.products = products
            } else {
                print("상품 목록 불러오기 실패")
            }
        })
    }
    
    func action(_ input: Input) {
        switch input {
        case .buy(let id):
            buy(id)
        }
    }
}

extension DonateViewModel {
    private func buy(_ id: String) {
        for product in products {
            if product.productIdentifier == id {
                iapManager.buyProduct(product)
                break
            }
        }
    }
}
