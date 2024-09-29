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
            Image("logo1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(0.5)
            header
            priceTargetsArea

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
//            Image("briefcase").resizable()
//                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.blue)
            
            VStack {
                Text(stock.name.isEmpty ? "Your stock" : stock.name).font(.subheadline)
                    .padding(.horizontal)
                
                HStack {
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.orange)
                        Text("Average price").font(.subheadline)
                        Text(String(format: "%.2f", stock.averagePrice)).font(.body)
                    }
                    
                    
                    VStack {
                        Image(systemName: "basket.fill")
                            .imageScale(.large)
                            .foregroundColor(.orange)
                        Text("Shares amount").font(.subheadline)
                        Text("\(stock.sharesAmount)").font(.body)
                    }
                }
                .onTapGesture {
                    showingEditView = true
                }
            }
        }
    }
    
    private var priceTargetsArea: some View {
        ZStack {
            RoundedRectangle(cornerSize: /*@START_MENU_TOKEN@*/CGSize(width: 20, height: 10)/*@END_MENU_TOKEN@*/).fill(.purple.opacity(0.1))
            
            VStack {
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
