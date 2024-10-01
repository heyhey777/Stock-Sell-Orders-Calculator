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
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Image("logo-brown")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Text("Unlock Full Access")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Get unlimited calculations and strategy saves!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    FeatureRow(icon: "infinity", text: "Unlimited calculations")
                    FeatureRow(icon: "square.stack.3d.up", text: "Unlimited strategy saves")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.customBackground)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                
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
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(isPurchasing)
                
                Button("Restore Purchase") {
                    Task {
                        await store.updatePurchaseStatus()
                        dismiss()
                    }
                }
                .foregroundColor(.brown)
                .padding()
            }
            .padding()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.system(size: 24))
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
