//
//  SwiftUIView.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import SwiftUI

struct StockEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var stock: Stock
    @State private var tempStock: Stock
    @State private var showAlert = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case stockName, averagePrice, sharesAmount
        //case stockName, averagePrice, sharesAmount, notes
    }

    init(stock: Binding<Stock>) {
        self._stock = stock
        self._tempStock = State(initialValue: stock.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    inputField(title: "Stock Name", placeholder: "Enter stock name", binding: $tempStock.name)
                        .focused($focusedField, equals: .stockName)
                    
                    inputField(title: "Average Price *", placeholder: "Enter average price", binding: Binding(
                        get: { String(format: "%.2f", self.tempStock.averagePrice) },
                        set: { if let value = Double($0) { self.tempStock.averagePrice = value } }
                    ))
                    .focused($focusedField, equals: .averagePrice)
                    .keyboardType(.decimalPad)
                    
                    inputField(title: "Shares Amount *", placeholder: "Enter shares amount", binding: Binding(
                        get: { String(self.tempStock.sharesAmount) },
                        set: { if let value = Int($0) { self.tempStock.sharesAmount = value } }
                    ))
                    .focused($focusedField, equals: .sharesAmount)
                    .keyboardType(.numberPad)
                    
//                    VStack(alignment: .leading) {
//                        Text("Notes")
//                            .font(.headline)
//                        TextEditor(text: $tempStock.notes)
//                            .frame(height: 100)
//                            .padding(5)
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .focused($focusedField, equals: .notes)
//                    }
                    
                    Button(action: continueAction) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
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
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
    
    private func inputField(title: String, placeholder: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField(placeholder, text: binding)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .submitLabel(.next)
        }
    }
    
    private func continueAction() {
        if tempStock.averagePrice == 0 || tempStock.sharesAmount == 0 {
            showAlert = true
        } else {
            stock = tempStock
            dismiss()
        }
    }
}

//struct StockEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        StockEditView(stock: .constant(Stock(name: "", averagePrice: 0, sharesAmount: 0, notes: "")))
//    }
//}
