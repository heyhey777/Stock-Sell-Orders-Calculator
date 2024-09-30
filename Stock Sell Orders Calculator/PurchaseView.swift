//
//  PurchaseView.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 30/09/2024.
//

import SwiftUI

struct PurchaseView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Unlock Full Access")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Get unlimited calculations and remove all restrictions!")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    isPurchasing = true
                    do {
                        try await store.purchase()
                        isPurchasing = false
                        dismiss()
                    } catch {
                        print("Purchase failed: \(error)")
                        isPurchasing = false
                    }
                }
            }) {
                Text(isPurchasing ? "Purchasing..." : "Purchase Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isPurchasing)
            
            Button("Restore Purchase") {
                Task {
                    await store.updatePurchaseStatus()
                    dismiss()
                }
            }
            .padding()
        }
        .padding()
    }
}
