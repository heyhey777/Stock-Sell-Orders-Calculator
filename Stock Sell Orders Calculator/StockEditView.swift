import SwiftUI

struct StockEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var stock: Stock
    @EnvironmentObject var store: Store
    @State private var tempStock: Stock
    @State private var showAlert = false
    @FocusState private var focusedField: Field?
    @State private var showingPurchaseView = false
    @State private var averagePriceString: String
    @State private var sharesAmountString: String

    enum Field: Hashable {
        case stockName, averagePrice, sharesAmount
    }

    init(stock: Binding<Stock>) {
        self._stock = stock
        self._tempStock = State(initialValue: stock.wrappedValue)
        self._averagePriceString = State(initialValue: stock.wrappedValue.averagePrice == 0 ? "" : String(format: "%.2f", stock.wrappedValue.averagePrice))
        self._sharesAmountString = State(initialValue: stock.wrappedValue.sharesAmount == 0 ? "" : "\(stock.wrappedValue.sharesAmount)")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        inputField(title: "Stock Name", placeholder: "Enter stock name (not mandatory)", binding: $tempStock.name)
                            .focused($focusedField, equals: .stockName)
                        
                        inputField(title: "Average Price, $", placeholder: "Enter average price", binding: $averagePriceString)
                            .focused($focusedField, equals: .averagePrice)
                            .keyboardType(.decimalPad)
                            .onChange(of: averagePriceString) { newValue in
                                if let value = Double(newValue) {
                                    tempStock.averagePrice = value
                                }
                            }
                        
                        inputField(title: "Shares Amount", placeholder: "Enter shares amount", binding: $sharesAmountString)
                            .focused($focusedField, equals: .sharesAmount)
                            .keyboardType(.decimalPad)
                            .onChange(of: sharesAmountString) { newValue in
                                if let value = Double(newValue) {
                                    tempStock.sharesAmount = value
                                }
                            }
                        
                        Button(action: continueAction) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                        
                        Button(action: clearFields) {
                            Text("Clear")
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Edit Stock", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Information"), message: Text("Please fill in all required fields (Average Price and Shares Amount)."), dismissButton: .default(Text("OK")))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func inputField(title: String, placeholder: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextField(placeholder, text: binding)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
        }
    }
    
    private func continueAction() {
        if tempStock.averagePrice <= 0 || tempStock.sharesAmount <= 0 {
            showAlert = true
        } else {
            if store.isPurchased || store.calculationsRemaining > 0 {
                stock = tempStock
                store.useCalculation()
                saveStockToUserDefaults()
                dismiss()
            } else {
                showingPurchaseView = true
            }
        }
    }

    private func clearFields() {
        tempStock.name = ""
        averagePriceString = ""
        sharesAmountString = ""
        tempStock.averagePrice = 0
        tempStock.sharesAmount = 0
    }
    
    private func saveStockToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(stock.name, forKey: "stockName")
        defaults.set(stock.averagePrice, forKey: "stockAveragePrice")
        defaults.set(stock.sharesAmount, forKey: "stockSharesAmount")
    }
}
