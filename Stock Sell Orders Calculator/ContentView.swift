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
    @State private var showingStrategySettingsView = false
    @State private var strategySettings = StrategySettings.default
    
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
        .sheet(isPresented: $showingStrategySettingsView) {
            StrategySettingsView(settings: $strategySettings)
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
            Button(action: { showingStrategySettingsView = true }) {
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
            ForEach(strategySettings.profitTakingTargets, id: \.percentage) { target in
                let targetPrice = stock.averagePrice * (1 + target.percentage / 100)
                Text(String(format: "%.2f", targetPrice)).font(.title3)
                Text("\(String(format: "%.1f", target.percentage))% of gain, \(String(format: "%.1f", target.allocation))% of the position size").font(.footnote)
                
                Spacer().frame(height: 10)
            }
        }
        .padding()
    }

    private var stopLossTargets: some View {
        VStack {
            ForEach(strategySettings.stopLossTargets, id: \.percentage) { target in
                let targetPrice = stock.averagePrice * (1 - target.percentage / 100)
                Text(String(format: "%.2f", targetPrice)).font(.title3)
                Text("\(String(format: "%.1f", target.percentage))% of loss, \(String(format: "%.1f", target.allocation))% of the position size").font(.footnote)
                
                Spacer().frame(height: 10)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(stock: .constant(Stock(name: "", averagePrice: 0.0, sharesAmount: 0)))
    }
}
