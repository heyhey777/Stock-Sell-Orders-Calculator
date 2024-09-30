//
//  Store.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 30/09/2024.
//

import StoreKit

@MainActor
class Store: ObservableObject {
    @Published private(set) var calculationsRemaining = 30
    @Published private(set) var isPurchased = false
    
    private let productId = "com.yourdomain.StockSellOrdersCalculator.FullAccess"
    private var transactionListener: Task<Void, Error>?
    
    
    
    init() {
        transactionListener = listenForTransactions()
        Task {
            await updatePurchaseStatus()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.updatePurchaseStatus()
            }
        }
    }
    
    func updatePurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                self.isPurchased = transaction.productID == self.productId
                self.calculationsRemaining = self.isPurchased ? Int.max : 30
            }
        }
    }
    
    func purchase() async throws {
        guard let product = try? await Product.products(for: [productId]).first else {
            print("Failed to get product info")
            return
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                await updatePurchaseStatus()
            }
        case .userCancelled:
            print("User cancelled")
        case .pending:
            print("Purchase pending")
        @unknown default:
            break
        }
    }
    
    func useCalculation() {
        if !isPurchased && calculationsRemaining > 0 {
            calculationsRemaining -= 1
        }
    }
}

