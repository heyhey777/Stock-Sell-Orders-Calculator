import SwiftUI
import StoreKit

struct ContentView: View {
    @Binding var stock: Stock
    @ObservedObject var strategySettingsManager: StrategySettingsManager
    @State private var showingEditView = false
    @State private var showingStrategySettingsView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                logoArea
                    .background(Color.appBackground)
                    .zIndex(1)
                
                ScrollView {
                    VStack(spacing: 20) {
                        header
                        priceTargetsArea
                        Spacer(minLength: 20)
                        restorePurchaseButton
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            StockEditView(stock: $stock)
        }
        .sheet(isPresented: $showingStrategySettingsView) {
            StrategySettingsView(settingsManager: strategySettingsManager)
        }
    }
    
    private var logoArea: some View {
        Image("logo-brown")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 40)
            .padding(.top, 15)
            .padding(.bottom, 10)
            .background(
                Rectangle()
                    .fill(Color.appBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // Shadow with offset
                    .clipped() // Ensures the shadow doesn't extend beyond the bottom
            )

    }
    
    private var header: some View {
        VStack(spacing: 15) {
            Text(stock.name.isEmpty ? "Your Stock" : stock.name)
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                infoCard(title: "Average Price", value: String(format: "%.2f", stock.averagePrice), imageName: "dollarsign.circle.fill", color: .green)
                infoCard(title: "Shares Amount", value: "\(stock.sharesAmount)", imageName: "basket.fill", color: .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.customBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .onTapGesture {
            showingEditView = true
        }
    }
    
    private func infoCard(title: String, value: String, imageName: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: imageName)
                .imageScale(.large)
                .foregroundColor(color)
                .padding(10)
                .background(Circle().fill(color.opacity(0.1)))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.customRectangleFill)
        )
    }
    
    private var priceTargetsArea: some View {
        VStack(spacing: 15) {
            priceTargetsPanel
            
            VStack(spacing: 10) {
                sectionHeader(title: "Profit Taking")
                profitTakingTargets
            }
            
            VStack(spacing: 10) {
                sectionHeader(title: "Stop Loss")
                stopLossTargets
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.customBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    private var priceTargetsPanel: some View {
        HStack {
            Image(systemName: "pencil.circle.fill")
                .foregroundColor(.primary)
                .imageScale(.large)
            
            Text("Strategy settings")
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.customRectangleFill)
        )
        .onTapGesture {
            showingStrategySettingsView = true
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.regular)
                .foregroundColor(.primary)
            Spacer()
        }
    }

    private var profitTakingTargets: some View {
        VStack(spacing: 8) {
            ForEach(strategySettingsManager.currentSettings.profitTakingTargets) { target in
                targetRow(for: target, isProfit: true)
            }
        }
    }

    private var stopLossTargets: some View {
        VStack(spacing: 8) {
            ForEach(strategySettingsManager.currentSettings.stopLossTargets) { target in
                targetRow(for: target, isProfit: false)
            }
        }
    }
    
    private func targetRow(for target: StrategySettings.Target, isProfit: Bool) -> some View {
        let targetPrice = isProfit ? stock.averagePrice * (1 + target.percentage / 100) : stock.averagePrice * (1 - target.percentage / 100)
        let sharesToSell = Int(Double(stock.sharesAmount) * target.allocation / 100)
        
        return VStack(alignment: .leading, spacing: 4) {
            Text("Sell \(sharesToSell) shares at $\(String(format: "%.2f", targetPrice))")
                .font(.title3)
                .fontWeight(.medium)
            Text("\(String(format: "%.1f", target.percentage))% \(isProfit ? "gain" : "loss"), \(String(format: "%.1f", target.allocation))% of position")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.customRectangleFill)
        )
    }
    
    private var restorePurchaseButton: some View {
        Button(action: {
            // Commented out implementation for restore purchase
            /*
            Task {
                do {
                    try await AppStore.sync()
                } catch {
                    print("Failed to restore purchases: \(error)")
                }
            }
            */
        }) {
            Text("Restore Purchase")
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.customBackground)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
