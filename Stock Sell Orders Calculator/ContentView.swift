//
//  ContentView.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import SwiftUI

struct ContentView: View {
    @Binding var stock: Stock
    @State private var showingEditView = false

    var body: some View {
        VStack {
            Text("~Stock price calc~").font(.footnote)
            
            header
            priceTargetsPanel

            VStack {
                HStack {
                    Text("Profit taking").font(.title3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 45)
           
            profitTakingTargets
            
            VStack {
                HStack {
                    Text("Stop loss").font(.title3)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 45)
            
            stopLossTargets
        }
        .sheet(isPresented: $showingEditView) {
            StockEditView(stock: $stock)
        }
    }
    
    private var header: some View {
        ZStack {
            Rectangle().fill(.purple.opacity(0.1))
            
            Text(stock.name.isEmpty ? "No stock selected" : stock.name).font(.subheadline)
            
            HStack {
                VStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                    Text("Average price").font(.subheadline)
                    Text(String(format: "%.2f", stock.averagePrice)).font(.body)
                }
                .onTapGesture {
                    showingEditView = true
                }
                
                VStack {
                    Image(systemName: "basket.fill")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                    Text("Shares amount").font(.subheadline)
                    Text("\(stock.sharesAmount)").font(.body)
                }
            }
        }
    }

    private var priceTargetsPanel: some View {
        HStack {
            Button(action: { showingEditView = true }) {
                Image(systemName: "gearshape.fill")
            }
            .labelStyle(.iconOnly)
            
            Text("Price targets:").font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var profitTakingTargets: some View {
        VStack {
            Text(String(format: "%.2f", stock.averagePrice * 1.025)).font(.title3)
            Text("2.5% of gain, 25% of the position size").font(.footnote)
            
            Spacer()
                .frame(height: 10)
            
            Text(String(format: "%.2f", stock.averagePrice * 1.05)).font(.title3)
            Text("5% of gain, 25% of the position size").font(.footnote)
        }
        .padding()
    }

    private var stopLossTargets: some View {
        VStack {
            Text(String(format: "%.2f", stock.averagePrice * 0.98)).font(.title3)
            Text("2% of loss, 50% of the position size").font(.footnote)
        }
        .padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
