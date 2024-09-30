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
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        inputField(title: "Stock Name", placeholder: "Enter stock name (not mandatory)", binding: $tempStock.name)
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
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
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
                .background(Color.customRectangleFill)
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
            stock = tempStock
            dismiss()
        }
    }
}
