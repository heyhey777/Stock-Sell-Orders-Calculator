import SwiftUI

struct StockEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var stock: Stock
    @State private var tempStock: Stock
    @State private var showAlert = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case stockName, averagePrice, sharesAmount
    }

    init(stock: Binding<Stock>) {
        self._stock = stock
        self._tempStock = State(initialValue: stock.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CustomBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        inputField(title: "Stock Name", placeholder: "Enter stock name", binding: $tempStock.name)
                            .focused($focusedField, equals: .stockName)
                        
                        inputField(title: "Average Price, $", placeholder: "Enter average price", binding: Binding(
                            get: { String(format: "%.2f", self.tempStock.averagePrice) },
                            set: { if let value = Double($0) { self.tempStock.averagePrice = value } }
                        ))
                        .focused($focusedField, equals: .averagePrice)
                        .keyboardType(.decimalPad)
                        
                        inputField(title: "Shares Amount", placeholder: "Enter shares amount", binding: Binding(
                            get: { String(self.tempStock.sharesAmount) },
                            set: { if let value = Double($0) { self.tempStock.sharesAmount = Int(value) } }
                        ))
                        .focused($focusedField, equals: .sharesAmount)
                        .keyboardType(.decimalPad)
                        
                        Button(action: continueAction) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                }
                .navigationBarTitle("Edit Stock", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    dismiss()
                })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Missing Information"), message: Text("Please fill in all required fields (Average Price and Shares Amount)."), dismissButton: .default(Text("OK")))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func inputField(title: String, placeholder: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField(placeholder, text: binding)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .accentColor(.white)
                .submitLabel(.next)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
    }
    
    private func continueAction() {
        if tempStock.averagePrice <= 0 || tempStock.sharesAmount <= 0 {
            showAlert = true
        } else {
            stock = tempStock
            dismiss()
        }
    }
}

struct CustomBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}
