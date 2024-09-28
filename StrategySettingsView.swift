//
//  StrategySettingsView.swift
//  Stock Sell Orders Calculator
//
//  Created by Kate on 28/09/2024.
//

import SwiftUI

struct StrategySettingsView: View {
    @Binding var settings: StrategySettings
    @Environment(\.dismiss) private var dismiss
    @State private var totalAllocation: Double = 0
    @State private var showingAllocationWarning = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Stop Loss Targets")) {
                    ForEach($settings.stopLossTargets) { $target in
                        HStack {
                            TextField("Loss %", text: Binding(
                                get: { String(format: "%.2f", target.percentage) },
                                set: { target.percentage = Double($0) ?? 0 }
                            ))
                            .keyboardType(.decimalPad)
                            Text("%")
                            Spacer()
                            TextField("Allocation", text: Binding(
                                get: { String(format: "%.2f", target.allocation) },
                                set: {
                                    target.allocation = Double($0) ?? 0
                                    updateTotalAllocation()
                                }
                            ))
                            .keyboardType(.decimalPad)
                            Text("%")
                            if settings.stopLossTargets.count > 1 {
                                Button(action: {
                                    if let index = settings.stopLossTargets.firstIndex(where: { $0.id == target.id }) {
                                        settings.stopLossTargets.remove(at: index)
                                        updateTotalAllocation()
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    if settings.stopLossTargets.count < 3 {
                        Button("Add Stop Loss Target") {
                            settings.stopLossTargets.append(StrategySettings.Target(percentage: 0, allocation: 0))
                        }
                    }
                }
                
                Section(header: Text("Profit Taking Targets")) {
                    ForEach($settings.profitTakingTargets) { $target in
                        HStack {
                            TextField("Gain %", text: Binding(
                                get: { String(format: "%.2f", target.percentage) },
                                set: { target.percentage = Double($0) ?? 0 }
                            ))
                            .keyboardType(.decimalPad)
                            Text("%")
                            Spacer()
                            TextField("Allocation", text: Binding(
                                get: { String(format: "%.2f", target.allocation) },
                                set: {
                                    target.allocation = Double($0) ?? 0
                                    updateTotalAllocation()
                                }
                            ))
                            .keyboardType(.decimalPad)
                            Text("%")
                            if settings.profitTakingTargets.count > 1 {
                                Button(action: {
                                    if let index = settings.profitTakingTargets.firstIndex(where: { $0.id == target.id }) {
                                        settings.profitTakingTargets.remove(at: index)
                                        updateTotalAllocation()
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    if settings.profitTakingTargets.count < 3 {
                        Button("Add Profit Taking Target") {
                            settings.profitTakingTargets.append(StrategySettings.Target(percentage: 0, allocation: 0))
                        }
                    }
                }
                
                Section {
                    Text("Total Allocation: \(totalAllocation, specifier: "%.2f")%")
                        .foregroundColor(totalAllocation > 100 ? .red : .primary)
                }
            }
            .navigationTitle("Strategy Settings")
            .navigationBarItems(trailing: Button("Save") {
                if totalAllocation <= 100 {
                    dismiss()
                } else {
                    showingAllocationWarning = true
                }
            })
            .alert(isPresented: $showingAllocationWarning) {
                Alert(
                    title: Text("Invalid Allocation"),
                    message: Text("Total allocation exceeds 100%. Please adjust your allocations."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                updateTotalAllocation()
            }
        }
    }
    
    private func updateTotalAllocation() {
        totalAllocation = settings.stopLossTargets.reduce(0) { $0 + $1.allocation } +
                          settings.profitTakingTargets.reduce(0) { $0 + $1.allocation }
    }
}

struct StrategySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StrategySettingsView(settings: .constant(StrategySettings.default))
    }
}
