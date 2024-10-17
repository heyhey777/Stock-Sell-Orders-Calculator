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
                    VStack(spacing: 24) {
                        inputField(title: "Stock Name", placeholder: "Enter stock name (optional)", binding: $tempStock.name, imageName: "tag")
                            .focused($focusedField, equals: .stockName)
                        
                        inputField(title: "Average Price", placeholder: "Enter average price", binding: $averagePriceString, imageName: "dollarsign")
                            .focused($focusedField, equals: .averagePrice)
                            .keyboardType(.decimalPad)
                            .onChange(of: averagePriceString) { newValue in
                                if let value = Double(newValue) {
                                    tempStock.averagePrice = value
                                }
                            }
                        
                        inputField(title: "Shares Amount", placeholder: "Enter shares amount", binding: $sharesAmountString, imageName: "basket")
                            .focused($focusedField, equals: .sharesAmount)
                            .keyboardType(.decimalPad)
                            .onChange(of: sharesAmountString) { newValue in
                                if let value = Double(newValue) {
                                    tempStock.sharesAmount = value
                                }
                            }
                        
                        saveButton
                        
                        clearButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitle("Edit Stock", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Information"),
                      message: Text("Please fill in all required fields (Average Price and Shares Amount)."),
                      dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingPurchaseView) {
                PurchaseView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func inputField(title: String, placeholder: String, binding: Binding<String>, imageName: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
                
                TextField(placeholder, text: binding)
                    .font(.body)
            }
            .padding()
            .background(Color.secondarySystemBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var saveButton: some View {
        Button(action: continueAction) {
            Text("Save Changes")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
        }
        .padding(.top, 20)
    }
    
    private var clearButton: some View {
        Button(action: clearFields) {
            Text("Clear")
                .foregroundColor(.accentColor)
        }
        .padding(.top, 10)
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

extension Color {
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
}
