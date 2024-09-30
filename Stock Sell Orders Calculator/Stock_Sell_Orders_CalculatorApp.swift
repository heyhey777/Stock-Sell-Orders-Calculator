import SwiftUI

@main
struct Stock_Sell_Orders_CalculatorApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var strategySettingsManager = StrategySettingsManager()
    
    var body: some Scene {
        WindowGroup {
            
            
            ContentView(stock: $appState.stock, strategySettingsManager: strategySettingsManager)
                .background(Color.appBackground)
        }
    }
}
//
//        WindowGroup {
//            if appState.isFirstLaunch {
//                StockEditView(stock: $appState.stock)
//                    .background(Color.appBackground)
//                    .onDisappear {
//                        appState.isFirstLaunch = false
//                    }
//            } else {
//                ContentView(stock: $appState.stock, strategySettingsManager: strategySettingsManager)
//                    .background(Color.appBackground)
//            }
//        }



class AppState: ObservableObject {
    @Published var isFirstLaunch: Bool
    @Published var stock: Stock
    
    init() {
        self.isFirstLaunch = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == false
        self.stock = Stock(name: "", averagePrice: 0.0, sharesAmount: 0)
        
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}
