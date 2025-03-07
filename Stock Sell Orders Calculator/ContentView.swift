import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var stock: Stock
    @ObservedObject var strategySettingsManager: StrategySettingsManager
    @EnvironmentObject var store: Store
    @State private var showingEditView = false
    @State private var showingStrategySettingsView = false
    @State private var showingPurchaseView = false
    
    init(strategySettingsManager: StrategySettingsManager) {
        self.strategySettingsManager = strategySettingsManager
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "stockName") ?? ""
        let averagePrice = defaults.double(forKey: "stockAveragePrice")
        let sharesAmount = defaults.double(forKey: "stockSharesAmount")
        self._stock = State(initialValue: Stock(name: name, averagePrice: averagePrice, sharesAmount: sharesAmount))
    }
    
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
                        purchaseArea
                        Disclaimer
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
        .sheet(isPresented: $showingPurchaseView) {
            PurchaseView()
                .environmentObject(store)
        }
    }
    
    private var purchaseArea: some View {
        VStack {
            if !store.isPurchased {
                Text("Calculations remaining: \(store.calculationsRemaining)")
                    .font(.headline)
                
                Button("Purchase Full Access") {
                    showingPurchaseView = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
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
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .clipped()
            )
    }
    
    private var header: some View {
        VStack(spacing: 15) {
            Text(stock.name.isEmpty ? "Your Stock" : stock.name)
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                infoCard(title: "Average Price", value: "$\(String(format: "%.2f", stock.averagePrice))", imageName: "dollarsign.circle.fill", color: .accentColor)
                infoCard(title: "Shares Amount", value: "\(stock.sharesAmount.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(stock.sharesAmount)) : String(stock.sharesAmount))", imageName: "basket.fill", color: .accentColor)
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
            Text(value.hasSuffix(".00") ? String(value.dropLast(3)) : value)
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
            Image(systemName: "pencil")
                .foregroundColor(.accentColor)
              //  .imageScale(.large)
            
            Text("Strategy settings")
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.customRectangleFill)
                .frame(maxWidth: .infinity)
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
    
    private var Disclaimer: some View {
        VStack{
            Text("Disclaimer: The calculations provided by this app are for informational purposes only and do not constitute financial advice. Users should consult with a qualified financial advisor before making any investment decisions. The app developers are not responsible for any losses or decisions made based on the information provided.")
                .font(.caption2)
                .foregroundStyle(.gray)
                .padding()
        }
    }
    
    private func targetRow(for target: StrategySettings.Target, isProfit: Bool) -> some View {
        let targetPrice: Double
        if let percentage = target.percentage {
            targetPrice = isProfit ? stock.averagePrice * (1 + percentage / 100) : stock.averagePrice * (1 - percentage / 100)
        } else {
            targetPrice = stock.averagePrice
        }
        
        let sharesToSell: Double
        if let allocation = target.allocation {
            sharesToSell = Double(stock.sharesAmount) * allocation / 100
        } else {
            sharesToSell = 0
        }
        
        let sharesToSellFormatted = sharesToSell.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(sharesToSell)) : String(sharesToSell)

        return VStack(alignment: .leading, spacing: 4) {
            Text("Sell \(sharesToSellFormatted) shares at $\(String(format: "%.2f", targetPrice))")
                .font(.title3)
                .fontWeight(.medium)
            Text("\(target.percentage.map { $0.truncatingRemainder(dividingBy: 1) == 0 ? String(Int($0)) : String($0) } ?? "N/A")% \(isProfit ? "gain" : "loss"), \(target.allocation.map { $0.truncatingRemainder(dividingBy: 1) == 0 ? String(Int($0)) : String($0) } ?? "N/A")% of the shares amount")
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
}
